import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/favorite_location.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/places_provider.dart';
import '../utils/map_styles.dart';

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
        ],
      ),
    );
  }
}
