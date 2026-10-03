import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/location_provider.dart';
import 'providers/map_provider.dart';
import 'providers/places_provider.dart';
import 'screens/map_screen.dart';
import 'services/location_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FavMapApp());
}

class FavMapApp extends StatelessWidget {
  const FavMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlacesProvider>(create: (_) => PlacesProvider()),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(const GeolocatorLocationService()),
        ),
        ChangeNotifierProvider<MapProvider>(create: (_) => MapProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FavMap',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MapScreen(),
      ),
    );
  }
}
