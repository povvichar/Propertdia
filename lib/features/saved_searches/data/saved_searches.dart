import 'package:flutter/foundation.dart';

import '../../../shared/models/property.dart';
import '../../force_sale/data/force_sale.dart';

// Re-export usd()/date helpers for screens importing this data file.
export '../../../shared/utils/format.dart';

/// Where a saved search lives. Drives the badge + which module it reopens.
enum SearchSource { forceSale, mapPrice }

extension SearchSourceX on SearchSource {
  String get label => switch (this) {
        SearchSource.forceSale => 'Force Sale',
        SearchSource.mapPrice => 'Map Price',
      };

  String get route => switch (this) {
        SearchSource.forceSale => '/force-sale',
        SearchSource.mapPrice => '/map-price',
      };

  String get asset => switch (this) {
        SearchSource.forceSale => 'assets/icons/base/tag_price.svg',
        SearchSource.mapPrice => 'assets/icons/base/map_point.svg',
      };
}

/// Map Price listing scope mirrored as a serialisable string so a saved search
/// can re-seed the map screen without importing its private enum.
const kMapScopeAll = 'all';
const kMapScopeSale = 'sale';
const kMapScopeRent = 'rent';

/// A user-defined search whose criteria are re-applied when reopened, and which
/// can raise mock "new match / price drop" alerts (see Notifications).
class SavedSearch {
  SavedSearch({
    required this.id,
    required this.name,
    required this.source,
    this.alertsOn = true,
    this.forceSaleFilter,
    this.saleType,
    this.mapScope = kMapScopeAll,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final SearchSource source;
  bool alertsOn;

  // Force Sale criteria.
  final ForceSaleFilter? forceSaleFilter;
  final SaleType? saleType;

  // Map Price criteria.
  final String mapScope;

  final DateTime createdAt;

  /// Human-readable one-line summary of the criteria.
  String get summary {
    switch (source) {
      case SearchSource.mapPrice:
        return switch (mapScope) {
          kMapScopeSale => 'Properties for sale',
          kMapScopeRent => 'Properties for rent',
          _ => 'All listings near you',
        };
      case SearchSource.forceSale:
        final parts = <String>[];
        if (saleType != null) parts.add(saleType!.label);
        final f = forceSaleFilter;
        if (f != null) {
          if (f.propertyTypes.isNotEmpty) parts.add(f.propertyTypes.join(' / '));
          if (f.minDiscount > 0) parts.add('${f.minDiscount}%+ off');
          if (f.minBeds > 0) parts.add('${f.minBeds}+ beds');
          parts.add(switch (f.priceBucket) {
            'lt100' => 'under \$100k',
            'mid' => '\$100k–300k',
            'gt300' => 'over \$300k',
            _ => '',
          });
        }
        parts.removeWhere((p) => p.isEmpty);
        return parts.isEmpty ? 'All distressed listings' : parts.join(' · ');
    }
  }

  /// Live count of mock listings currently matching this search.
  int get matchCount {
    switch (source) {
      case SearchSource.mapPrice:
        return mockMapProperties.where((p) {
          if (mapScope == kMapScopeSale) return !p.isRent;
          if (mapScope == kMapScopeRent) return p.isRent;
          return true;
        }).length;
      case SearchSource.forceSale:
        return mockForceSale
            .where((p) =>
                (saleType == null || p.saleType == saleType) &&
                (forceSaleFilter?.matches(p) ?? true))
            .length;
    }
  }
}

/// Global store of saved searches (mirrors the favorites/savedForceSale pattern).
class SavedSearchStore extends ChangeNotifier {
  final List<SavedSearch> _items = [
    SavedSearch(
      id: 's_seed_1',
      name: 'Villas under \$100k',
      source: SearchSource.forceSale,
      forceSaleFilter: const ForceSaleFilter(
        propertyTypes: {'Villa', 'Borey House'},
        priceBucket: 'lt100',
      ),
      createdAt: DateTime(2026, 6, 12),
    ),
    SavedSearch(
      id: 's_seed_2',
      name: 'For sale near me',
      source: SearchSource.mapPrice,
      mapScope: kMapScopeSale,
      alertsOn: false,
      createdAt: DateTime(2026, 6, 9),
    ),
  ];

  List<SavedSearch> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  int get alertingCount => _items.where((s) => s.alertsOn).length;

  void add(SavedSearch s) {
    _items.insert(0, s);
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleAlerts(String id) {
    final s = _items.firstWhere((e) => e.id == id);
    s.alertsOn = !s.alertsOn;
    notifyListeners();
  }
}

final savedSearchStore = SavedSearchStore();
