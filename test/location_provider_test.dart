import 'dart:async';

import 'package:favmap/providers/location_provider.dart';
import 'package:favmap/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('LocationProvider.locateUser', () {
    test('stores position, enables blue dot, and returns success', () async {
      final service = FakeLocationService(
        permission: LocationPermission.whileInUse,
      );
      final provider = LocationProvider(service);

      final status = await provider.locateUser();

      expect(status, LocationStatus.success);
      expect(provider.status, LocationStatus.success);
      expect(provider.userPosition, const LatLng(22.8, 89.5));
      expect(provider.myLocationEnabled, isTrue);
    });

    test('returns serviceDisabled when device location is off', () async {
      final provider = LocationProvider(
        FakeLocationService(serviceEnabled: false),
      );

      expect(await provider.locateUser(), LocationStatus.serviceDisabled);
    });

    test('returns permissionDenied after a denied request', () async {
      final service = FakeLocationService(
        permission: LocationPermission.denied,
        requestedPermission: LocationPermission.denied,
      );

      expect(
        await LocationProvider(service).locateUser(),
        LocationStatus.permissionDenied,
      );
      expect(service.requestPermissionCalls, 1);
    });

    test('returns permissionDeniedForever when permanently blocked', () async {
      final service = FakeLocationService(
        permission: LocationPermission.denied,
        requestedPermission: LocationPermission.deniedForever,
      );

      expect(
        await LocationProvider(service).locateUser(),
        LocationStatus.permissionDeniedForever,
      );
    });

    test('returns timeout when position lookup times out', () async {
      final service = FakeLocationService(
        permission: LocationPermission.always,
        positionError: TimeoutException('test timeout'),
      );

      expect(
        await LocationProvider(service).locateUser(),
        LocationStatus.timeout,
      );
    });

    test('returns error without exposing generic failures', () async {
      final service = FakeLocationService(
        permission: LocationPermission.always,
        positionError: StateError('test failure'),
      );

      expect(
        await LocationProvider(service).locateUser(),
        LocationStatus.error,
      );
    });
  });

  test('checkPermissionSilently never requests permission', () async {
    final service = FakeLocationService(
      permission: LocationPermission.denied,
      requestedPermission: LocationPermission.whileInUse,
    );
    final provider = LocationProvider(service);

    await provider.checkPermissionSilently();

    expect(service.requestPermissionCalls, 0);
    expect(provider.myLocationEnabled, isFalse);
    expect(provider.status, LocationStatus.idle);
  });
}

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.serviceEnabled = true,
    this.permission = LocationPermission.denied,
    this.requestedPermission = LocationPermission.denied,
    this.positionError,
  });

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission requestedPermission;
  final Object? positionError;
  int requestPermissionCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<Position> getCurrentPosition() async {
    final error = positionError;
    if (error != null) throw error;
    return Position(
      longitude: 89.5,
      latitude: 22.8,
      timestamp: DateTime(2026),
      accuracy: 3,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalls++;
    return requestedPermission;
  }
}
