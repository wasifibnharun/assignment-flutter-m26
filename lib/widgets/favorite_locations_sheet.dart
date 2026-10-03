import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/favorite_location.dart';

Future<void> showFavoriteLocationsSheet(
  BuildContext context, {
  required List<FavoriteLocation> places,
  required Future<void> Function(FavoriteLocation place) onSelected,
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
        FavoriteLocationsSheet(places: places, onSelected: onSelected),
  );
}

class FavoriteLocationsSheet extends StatefulWidget {
  const FavoriteLocationsSheet({
    super.key,
    required this.places,
    required this.onSelected,
  });

  final List<FavoriteLocation> places;
  final Future<void> Function(FavoriteLocation place) onSelected;

  @override
  State<FavoriteLocationsSheet> createState() => _FavoriteLocationsSheetState();
}

class _FavoriteLocationsSheetState extends State<FavoriteLocationsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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

  Future<void> _select(FavoriteLocation place) async {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    await widget.onSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              'Favorite Locations',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final place = widget.places[index];
                final start = index * 0.095;
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    start,
                    (start + 0.58).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ),
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: ListTile(
                      minTileHeight: 56,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh,
                      title: Text(
                        '⭐ ${place.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${place.latitude.toStringAsFixed(4)}, '
                        '${place.longitude.toStringAsFixed(4)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: () => _select(place),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
