import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/favorite_location.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/places_provider.dart';
import '../utils/map_styles.dart';
import '../utils/snackbars.dart';
import '../widgets/favorite_locations_sheet.dart';
import '../widgets/location_details_sheet.dart';
import '../widgets/my_location_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _defaultZoom = 13;
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationProvider>().checkPermissionSilently();
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final mapProvider = context.read<MapProvider>();
    mapProvider.onMapCreated(controller);
    if (_introStarted) return;
    _introStarted = true;
    final places = context.read<PlacesProvider>();
    if (places.places.isNotEmpty) {
      await mapProvider.runIntroAnimation(places.places.first);
    }
  }

  Set<Marker> _markers(List<FavoriteLocation> places, int? selectedId) {
    return places.map((place) {
      final selected = place.id == selectedId;
      return Marker(
        markerId: MarkerId(place.id.toString()),
        position: place.position,
        zIndexInt: selected ? 2 : 1,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selected ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueCyan,
        ),
        infoWindow: InfoWindow(title: place.name),
        onTap: () => _onMarkerTap(place),
      );
    }).toSet();
  }

  Future<void> _onMarkerTap(FavoriteLocation place) async {
    HapticFeedback.selectionClick();
    context.read<PlacesProvider>().selectPlace(place.id);
    final mapProvider = context.read<MapProvider>();
    await mapProvider.animateToPlace(place);
    await mapProvider.showInfoWindow(place.id);
    if (!mounted) return;
    await showLocationDetailsSheet(
      context,
      place: place,
      onGoToLocation: () async {
        await mapProvider.animateToPlace(place);
        await mapProvider.showInfoWindow(place.id);
      },
    );
  }

  Future<void> _locateUser() async {
    final locationProvider = context.read<LocationProvider>();
    final mapProvider = context.read<MapProvider>();
    final status = await locationProvider.locateUser();
    if (!mounted) return;

    switch (status) {
      case LocationStatus.success:
        final position = locationProvider.userPosition;
        if (position != null) {
          await mapProvider.animateToLatLng(position);
        }
      case LocationStatus.serviceDisabled:
        AppSnackbars.show(
          context,
          icon: Icons.location_off_rounded,
          message: 'Turn on location services to find your position.',
          actionLabel: 'SETTINGS',
          onAction: locationProvider.openLocationSettings,
        );
      case LocationStatus.permissionDenied:
        AppSnackbars.show(
          context,
          icon: Icons.location_disabled_rounded,
          message: 'Location access is needed to show you on the map.',
          actionLabel: 'TRY AGAIN',
          onAction: _locateUser,
        );
      case LocationStatus.permissionDeniedForever:
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.settings_rounded),
            title: const Text('Location permission blocked'),
            content: const Text(
              'Enable location access for FavMap in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Open App Settings'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (openSettings ?? false) {
          await locationProvider.openAppSettings();
        }
      case LocationStatus.timeout:
        AppSnackbars.show(
          context,
          icon: Icons.timer_off_rounded,
          message: 'Finding your location took too long. Please try again.',
        );
      case LocationStatus.error:
        AppSnackbars.show(
          context,
          icon: Icons.error_outline_rounded,
          message: 'Your location could not be found right now.',
        );
      case LocationStatus.idle:
      case LocationStatus.loading:
        break;
    }
  }

  Future<void> _showFavorites() async {
    HapticFeedback.lightImpact();
    final placesProvider = context.read<PlacesProvider>();
    final mapProvider = context.read<MapProvider>();
    await showFavoriteLocationsSheet(
      context,
      places: placesProvider.places,
      onSelected: (place) async {
        placesProvider.selectPlace(place.id);
        await mapProvider.animateToPlace(place);
        await mapProvider.showInfoWindow(place.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = context.select<PlacesProvider, List<FavoriteLocation>>(
      (provider) => provider.places,
    );
    final selectedId = context.select<PlacesProvider, int?>(
      (provider) => provider.selectedId,
    );
    final myLocationEnabled = context.select<LocationProvider, bool>(
      (provider) => provider.myLocationEnabled,
    );
    final isMapReady = context.select<MapProvider, bool>(
      (provider) => provider.isMapReady,
    );
    final locationStatus = context.select<LocationProvider, LocationStatus>(
      (provider) => provider.status,
    );
    final brightness = Theme.of(context).brightness;
    final initialPosition = places.first.position;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: _defaultZoom,
            ),
            markers: _markers(places, selectedId),
            myLocationEnabled: myLocationEnabled,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
            padding: const EdgeInsets.fromLTRB(16, 112, 16, 216),
            style: brightness == Brightness.dark
                ? MapStyles.dark
                : MapStyles.light,
            onMapCreated: _onMapCreated,
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: isMapReady ? 0 : 1,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 224 + MediaQuery.paddingOf(context).bottom,
            child: MyLocationButton(
              status: locationStatus,
              onPressed: _locateUser,
            ),
          ),
          Positioned(
            left: 16,
            bottom: 224 + MediaQuery.paddingOf(context).bottom,
            child: Semantics(
              button: true,
              label: 'Open favorite locations',
              child: FilledButton.tonal(
                onPressed: _showFavorites,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: const Text('📍 Favorite Locations'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
