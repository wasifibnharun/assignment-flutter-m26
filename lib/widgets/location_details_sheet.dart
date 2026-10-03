import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/favorite_location.dart';
import '../utils/snackbars.dart';

Future<void> showLocationDetailsSheet(
  BuildContext context, {
  required FavoriteLocation place,
  required Future<void> Function() onGoToLocation,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 200),
          ),
    builder: (_) =>
        LocationDetailsSheet(place: place, onGoToLocation: onGoToLocation),
  );
}

class LocationDetailsSheet extends StatefulWidget {
  const LocationDetailsSheet({
    super.key,
    required this.place,
    required this.onGoToLocation,
  });

  final FavoriteLocation place;
  final Future<void> Function() onGoToLocation;

  @override
  State<LocationDetailsSheet> createState() => _LocationDetailsSheetState();
}

class _LocationDetailsSheetState extends State<LocationDetailsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyCoordinates() async {
    HapticFeedback.lightImpact();
    final coordinates =
        '${widget.place.latitude.toStringAsFixed(4)}, '
        '${widget.place.longitude.toStringAsFixed(4)}';
    await Clipboard.setData(ClipboardData(text: coordinates));
    if (!mounted) return;
    AppSnackbars.show(
      context,
      icon: Icons.check_circle_rounded,
      message: 'Coordinates copied',
    );
  }

  Future<void> _goToLocation() async {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    await widget.onGoToLocation();
  }

  Widget _animatedRow({
    required int index,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final start = 0.08 + index * 0.12;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        (start + 0.46).clamp(0, 1),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 12),
              SizedBox(
                width: 86,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Favorite Location',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _animatedRow(
            index: 0,
            icon: Icons.tag_rounded,
            label: 'ID',
            value: place.id.toString(),
          ),
          _animatedRow(
            index: 1,
            icon: Icons.place_rounded,
            label: 'Name',
            value: place.name,
          ),
          _animatedRow(
            index: 2,
            icon: Icons.north_rounded,
            label: 'Latitude',
            value: place.latitude.toStringAsFixed(4),
          ),
          _animatedRow(
            index: 3,
            icon: Icons.east_rounded,
            label: 'Longitude',
            value: place.longitude.toStringAsFixed(4),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _copyCoordinates,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy coordinates'),
              ),
              FilledButton.icon(
                onPressed: _goToLocation,
                icon: const Icon(Icons.near_me_rounded),
                label: const Text('Go to location'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
