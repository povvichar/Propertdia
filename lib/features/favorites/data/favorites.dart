import 'package:flutter/foundation.dart';

import '../../../shared/models/property.dart';
import '../../invest/data/invest.dart';

/// Saved properties + investment opportunities (global, mirrors savedForceSale).
class FavoritesStore extends ChangeNotifier {
  final List<Property> _properties = [mockBestPrice[0], mockBestPrice[1]];
  final List<InvestProject> _projects = [mockProjects[0]];

  List<Property> get properties => List.unmodifiable(_properties);
  List<InvestProject> get projects => List.unmodifiable(_projects);

  int get total => _properties.length + _projects.length;

  bool hasProperty(String id) => _properties.any((p) => p.id == id);
  bool hasProject(String id) => _projects.any((p) => p.id == id);

  void toggleProperty(Property p) {
    hasProperty(p.id)
        ? _properties.removeWhere((e) => e.id == p.id)
        : _properties.insert(0, p);
    notifyListeners();
  }

  void toggleProject(InvestProject p) {
    hasProject(p.id)
        ? _projects.removeWhere((e) => e.id == p.id)
        : _projects.insert(0, p);
    notifyListeners();
  }
}

final favoritesStore = FavoritesStore();
