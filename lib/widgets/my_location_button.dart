import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/location_provider.dart';

class MyLocationButton extends StatefulWidget {
  const MyLocationButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  final LocationStatus status;
  final VoidCallback onPressed;

  @override
  State<MyLocationButton> createState() => _MyLocationButtonState();
}

class _MyLocationButtonState extends State<MyLocationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(MyLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == LocationStatus.success &&
        oldWidget.status != LocationStatus.success) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _pulseController.value = 1;
      } else {
        _pulseController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.status == LocationStatus.loading) return;
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return Semantics(
      button: true,
      label: 'Find my location',
      child: Tooltip(
        message: 'My Location',
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = Curves.easeOutCubic.transform(_pulseController.value);
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 1 - pulse,
                  child: Container(
                    width: 56 + 22 * pulse,
                    height: 56 + 22 * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 3 * (1 - pulse),
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: Material(
              elevation: 5,
              color: colorScheme.primaryContainer,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _handleTap,
                onHighlightChanged: (value) {
                  if (_pressed != value) setState(() => _pressed = value);
                },
                child: SizedBox.square(
                  dimension: 56,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: widget.status == LocationStatus.loading
                          ? SizedBox.square(
                              key: const ValueKey('loading'),
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : Icon(
                              Icons.my_location_rounded,
                              key: const ValueKey('location'),
                              color: colorScheme.onPrimaryContainer,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
