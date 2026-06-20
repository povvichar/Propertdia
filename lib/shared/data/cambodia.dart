import 'package:latlong2/latlong.dart';

/// Geographic centre of Cambodia — default map-picker view.
const kCambodiaCenter = LatLng(12.5657, 104.9910);

/// `11.5564, 104.9282` style label for a coordinate.
String formatLatLng(LatLng p) =>
    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';

/// Demo set of Cambodian provinces/cities offered in location pickers. The
/// first three already appear in the seeded valuation history. Listed roughly
/// by market size (Phnom Penh first) — the estimate pricing table keys off these.
const kCambodiaProvinces = <String>[
  'Phnom Penh',
  'Siem Reap',
  'Preah Sihanouk',
  'Battambang',
  'Kandal',
  'Kampot',
  'Kep',
  'Takeo',
  'Kampong Cham',
  'Banteay Meanchey',
];
