import 'package:flutter/foundation.dart';

import '../data/favorite_locations_data.dart';
import '../models/favorite_location.dart';

class PlacesProvider extends ChangeNotifier {
  PlacesProvider({List<FavoriteLocation> places = favoriteLocations})
    : _places = List<FavoriteLocation>.unmodifiable(places);

  final List<FavoriteLocation> _places;
  int? _selectedId;

  List<FavoriteLocation> get places => _places;
  int? get selectedId => _selectedId;

  FavoriteLocation? get selectedPlace {
    final selectedIndex = indexOf(_selectedId);
    return selectedIndex == -1 ? null : _places[selectedIndex];
  }

  int indexOf(int? id) => id == null
      ? -1
      : _places.indexWhere((FavoriteLocation place) => place.id == id);

  void selectPlace(int id) {
    if (_selectedId == id || indexOf(id) == -1) {
      return;
    }
    _selectedId = id;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedId == null) {
      return;
    }
    _selectedId = null;
    notifyListeners();
  }
}
