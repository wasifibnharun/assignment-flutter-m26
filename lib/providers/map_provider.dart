import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/favorite_location.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _controller;
  bool _isMapReady = false;

  bool get isMapReady => _isMapReady;

  void onMapCreated(GoogleMapController controller) {
    if (identical(_controller, controller) && _isMapReady) {
      return;
    }
    _controller = controller;
    _isMapReady = true;
    notifyListeners();
  }

  Future<void> animateToPlace(FavoriteLocation place, {double zoom = 16}) =>
      animateToLatLng(place.position, zoom: zoom);

  Future<void> animateToLatLng(LatLng position, {double zoom = 16}) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  Future<void> showInfoWindow(int id) async {
    await _controller?.showMarkerInfoWindow(MarkerId(id.toString()));
  }

  Future<void> runIntroAnimation(FavoriteLocation place) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.moveCamera(CameraUpdate.newLatLngZoom(place.position, 12));
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(place.position, 15),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isMapReady = false;
    super.dispose();
  }
}
