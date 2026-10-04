import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/favorite_location.dart';

class MapProvider extends ChangeNotifier {
  static const Duration _controllerActionTimeout = Duration(seconds: 1);

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
    await _runControllerAction(
      (controller) =>
          controller.animateCamera(CameraUpdate.newLatLngZoom(position, zoom)),
    );
  }

  Future<void> showInfoWindow(int id) async {
    await _runControllerAction(
      (controller) => controller.showMarkerInfoWindow(MarkerId(id.toString())),
    );
  }

  Future<void> runIntroAnimation(FavoriteLocation place) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await _runControllerAction(
      (activeController) => activeController.moveCamera(
        CameraUpdate.newLatLngZoom(place.position, 12),
      ),
    );
    await _runControllerAction(
      (activeController) => activeController.animateCamera(
        CameraUpdate.newLatLngZoom(place.position, 15),
      ),
    );
  }

  Future<void> _runControllerAction(
    Future<void> Function(GoogleMapController controller) action,
  ) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await action(controller).timeout(_controllerActionTimeout);
    } catch (_) {
      // Platform-view callbacks can be dropped on slow or interrupted devices.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isMapReady = false;
    super.dispose();
  }
}
