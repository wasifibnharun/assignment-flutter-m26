import 'package:favmap/data/favorite_locations_data.dart';
import 'package:favmap/models/favorite_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('FavoriteLocation', () {
    test('stores fields and exposes its LatLng position', () {
      const place = FavoriteLocation(
        id: 7,
        name: 'Test Place',
        latitude: 22.5,
        longitude: 89.5,
      );

      expect(place.id, 7);
      expect(place.name, 'Test Place');
      expect(place.latitude, 22.5);
      expect(place.longitude, 89.5);
      expect(place.position, const LatLng(22.5, 89.5));
    });

    test('sample data contains at least three entries with unique IDs', () {
      expect(favoriteLocations.length, greaterThanOrEqualTo(3));
      expect(
        favoriteLocations.map((place) => place.id).toSet().length,
        favoriteLocations.length,
      );
    });

    test('all sample coordinates are in valid ranges', () {
      for (final place in favoriteLocations) {
        expect(place.latitude, inInclusiveRange(-90, 90));
        expect(place.longitude, inInclusiveRange(-180, 180));
      }
    });
  });
}
