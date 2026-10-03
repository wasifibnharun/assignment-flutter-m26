import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;

  LatLng get position => LatLng(latitude, longitude);
}
