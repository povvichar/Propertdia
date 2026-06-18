import 'valuation.dart';

/// Result of the instant (indicative) valuation engine.
class EstimateResult {
  const EstimateResult({
    required this.value,
    required this.low,
    required this.high,
    required this.comparables,
    required this.pricePerSqm,
    required this.basis,
  });

  /// Mid-point estimated market value, USD, rounded to the nearest $1,000.
  final int value;

  /// Lower / upper bound of the confidence range (±6%), rounded to $1,000.
  final int low;
  final int high;

  /// Number of comparable listings the figure is "based on" (demo only).
  final int comparables;

  /// Effective price applied per m² after all adjustments.
  final int pricePerSqm;

  /// Human-readable basis line, e.g. `Phnom Penh · Condo · $1,750/m²`.
  final String basis;
}

/// Base market price (USD per m²) by property type, anchored to Phnom Penh and
/// reverse-engineered from the seeded map_price listings (see
/// `lib/shared/models/property.dart`). Land is the entry under [_landKey].
const _basePerSqm = <String, int>{
  'Land': 900,
  'Villa': 1150,
  'Condo': 1750,
  'Apartment': 1400,
  'Shophouse': 1300,
  'Townhouse': 1050,
};

const _landKey = 'Land';
const _defaultBasePerSqm = 1000;

/// Relative price level of each province vs. Phnom Penh (1.0). Provinces not
/// listed fall back to [_defaultProvinceFactor].
const _provinceFactor = <String, double>{
  'Phnom Penh': 1.00,
  'Siem Reap': 0.55,
  'Preah Sihanouk': 0.70,
  'Battambang': 0.42,
  'Kandal': 0.65,
  'Kampot': 0.48,
  'Kep': 0.45,
  'Takeo': 0.38,
  'Kampong Cham': 0.40,
  'Banteay Meanchey': 0.38,
};

const _defaultProvinceFactor = 0.50;

/// Land-title quality factor — Hard Title commands a premium over Soft Title.
const _titleFactor = <String, double>{
  'Hard Title': 1.00,
  'LMAP Title': 0.92,
  'Soft Title': 0.82,
};

int _round1k(double v) => (v / 1000).round() * 1000;

/// Computes an indicative property value from size, location and attributes.
///
/// Deterministic by design — the same inputs always yield the same figure so
/// the demo is reproducible. This is a transparent `$/m²` model, NOT a real
/// appraisal; the result is always labelled "indicative" in the UI.
EstimateResult estimateValue({
  required ValuationType type,
  required String province,
  required String propertyType,
  required double sizeSqm,
  int? beds,
  int? baths,
  String? landTitle,
  ValuationPurpose? purpose,
}) {
  final isLand = type == ValuationType.land;
  final base = _basePerSqm[isLand ? _landKey : propertyType] ?? _defaultBasePerSqm;
  final provFactor = _provinceFactor[province] ?? _defaultProvinceFactor;

  // Per-m² price after location.
  var perSqm = base * provFactor;

  // Building rooms nudge the figure around the 2bd/2ba baseline.
  if (!isLand) {
    final roomFactor =
        1 + ((beds ?? 2) - 2) * 0.03 + ((baths ?? 2) - 2) * 0.02;
    perSqm *= roomFactor.clamp(0.85, 1.30);
  } else {
    perSqm *= _titleFactor[landTitle] ?? 1.0;
  }

  // Mortgage valuations are quoted conservatively.
  if (purpose == ValuationPurpose.mortgage) perSqm *= 0.97;

  final raw = perSqm * sizeSqm;
  final value = _round1k(raw);

  return EstimateResult(
    value: value,
    low: _round1k(raw * 0.94),
    high: _round1k(raw * 1.06),
    comparables: _comparables(province, propertyType),
    pricePerSqm: perSqm.round(),
    basis: '$province · ${isLand ? 'Land' : propertyType} · '
        '\$${perSqm.round()}/m²',
  );
}

/// Deterministic 4–8 "comparables used", stable per province + type so the
/// number doesn't flicker between rebuilds.
int _comparables(String province, String propertyType) =>
    (province.hashCode ^ propertyType.hashCode).abs() % 5 + 4;
