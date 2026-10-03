import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/favorite_location.dart';
import '../providers/location_provider.dart';

class LocationCarousel extends StatefulWidget {
  const LocationCarousel({
    super.key,
    required this.places,
    required this.selectedId,
    required this.animation,
    required this.onPageSelected,
    required this.onCardTap,
  });

  final List<FavoriteLocation> places;
  final int? selectedId;
  final Animation<double> animation;
  final ValueChanged<FavoriteLocation> onPageSelected;
  final ValueChanged<FavoriteLocation> onCardTap;

  @override
  State<LocationCarousel> createState() => _LocationCarouselState();
}

class _LocationCarouselState extends State<LocationCarousel> {
  late final PageController _pageController;
  int _visibleIndex = 0;
  int? _selectionFromSwipeId;

  Duration get _duration => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    final selectedIndex = widget.places.indexWhere(
      (place) => place.id == widget.selectedId,
    );
    _visibleIndex = selectedIndex < 0 ? 0 : selectedIndex;
    _pageController = PageController(
      initialPage: _visibleIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  void didUpdateWidget(LocationCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId == oldWidget.selectedId ||
        widget.selectedId == null) {
      return;
    }
    if (_selectionFromSwipeId == widget.selectedId) {
      _selectionFromSwipeId = null;
      return;
    }
    final index = widget.places.indexWhere(
      (place) => place.id == widget.selectedId,
    );
    if (index < 0 || index == _visibleIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        index,
        duration: _duration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_visibleIndex != index) {
      setState(() => _visibleIndex = index);
    }
    final place = widget.places[index];
    _selectionFromSwipeId = place.id;
    HapticFeedback.selectionClick();
    widget.onPageSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    context.select<LocationProvider, LatLng?>(
      (provider) => provider.userPosition,
    );
    final locationProvider = context.read<LocationProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: widget.animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.32),
          end: Offset.zero,
        ).animate(widget.animation),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.places.length,
          onPageChanged: _onPageChanged,
          padEnds: true,
          itemBuilder: (context, index) {
            final place = widget.places[index];
            final active = index == _visibleIndex;
            final distance = locationProvider.distanceTo(place);
            return AnimatedScale(
              scale: active ? 1 : 0.94,
              duration: _duration,
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: active ? 1 : 0.72,
                duration: _duration,
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  child: Semantics(
                    button: true,
                    label: '${place.name}, favorite ${place.id}',
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onCardTap(place);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: active
                                      ? colorScheme.primary
                                      : colorScheme.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${place.id}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: active
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${place.latitude.toStringAsFixed(4)}, '
                                      '${place.longitude.toStringAsFixed(4)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    if (distance != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        '$distance away',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
