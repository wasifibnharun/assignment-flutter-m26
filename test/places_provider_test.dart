import 'package:favmap/providers/places_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlacesProvider', () {
    test('starts with no selection', () {
      final provider = PlacesProvider();

      expect(provider.selectedId, isNull);
      expect(provider.selectedPlace, isNull);
    });

    test('selectPlace updates selection and notifies exactly once', () {
      final provider = PlacesProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.selectPlace(2);

      expect(provider.selectedId, 2);
      expect(provider.selectedPlace?.id, 2);
      expect(provider.indexOf(2), 1);
      expect(notifications, 1);
    });

    test('clearSelection resets an existing selection', () {
      final provider = PlacesProvider()..selectPlace(1);
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.clearSelection();

      expect(provider.selectedId, isNull);
      expect(provider.selectedPlace, isNull);
      expect(notifications, 1);
    });

    test('unknown IDs are ignored safely', () {
      final provider = PlacesProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.selectPlace(999);

      expect(provider.selectedId, isNull);
      expect(provider.indexOf(999), -1);
      expect(notifications, 0);
    });
  });
}
