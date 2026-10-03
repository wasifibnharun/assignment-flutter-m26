import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/favorite_location.dart';
import '../services/location_service.dart';

enum LocationStatus {
  idle,
  loading,
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  error,
}

class LocationProvider extends ChangeNotifier {
  LocationProvider(this._locationService);

  final LocationService _locationService;
  LatLng? _userPosition;
  bool _myLocationEnabled = false;
  LocationStatus _status = LocationStatus.idle;

  LatLng? get userPosition => _userPosition;
  bool get myLocationEnabled => _myLocationEnabled;
  LocationStatus get status => _status;

  Future<LocationStatus> locateUser() async {
    _setState(status: LocationStatus.loading);
    try {
      if (!await _locationService.isServiceEnabled()) {
        return _finish(LocationStatus.serviceDisabled);
      }

      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return _finish(LocationStatus.permissionDeniedForever);
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return _finish(LocationStatus.permissionDenied);
      }

      final position = await _locationService.getCurrentPosition();
      _setState(
        status: LocationStatus.success,
        position: LatLng(position.latitude, position.longitude),
        myLocationEnabled: true,
      );
      return LocationStatus.success;
    } on TimeoutException {
      return _finish(LocationStatus.timeout);
    } catch (_) {
      return _finish(LocationStatus.error);
    }
  }

  Future<void> checkPermissionSilently() async {
    try {
      final permission = await _locationService.checkPermission();
      final granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      _setState(myLocationEnabled: granted);
    } catch (_) {
      _setState(myLocationEnabled: false);
    }
  }

  double? distanceInMetersTo(FavoriteLocation place) {
    final position = _userPosition;
    if (position == null) {
      return null;
    }
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      place.latitude,
      place.longitude,
    );
  }

  String? distanceTo(FavoriteLocation place) {
    final meters = distanceInMetersTo(place);
    if (meters == null) {
      return null;
    }
    return meters < 1000
        ? '${meters.round()} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  LocationStatus _finish(LocationStatus nextStatus) {
    _setState(status: nextStatus);
    return nextStatus;
  }

  void _setState({
    LocationStatus? status,
    LatLng? position,
    bool? myLocationEnabled,
  }) {
    final nextStatus = status ?? _status;
    final nextPosition = position ?? _userPosition;
    final nextMyLocationEnabled = myLocationEnabled ?? _myLocationEnabled;
    if (nextStatus == _status &&
        nextPosition == _userPosition &&
        nextMyLocationEnabled == _myLocationEnabled) {
      return;
    }
    _status = nextStatus;
    _userPosition = nextPosition;
    _myLocationEnabled = nextMyLocationEnabled;
    notifyListeners();
  }
}
