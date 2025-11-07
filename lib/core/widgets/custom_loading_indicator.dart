// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Custom loading indicator with SpinKit animations
class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({
    this.size,
    this.color,
    this.type = LoadingType.fadingCircle,
    super.key,
  });

  final double? size;
  final Color? color;
  final LoadingType type;

  double get _effectiveSize => size ?? AppSizes.iconXL;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    switch (type) {
      case LoadingType.fadingCircle:
        return SpinKitFadingCircle(color: effectiveColor, size: _effectiveSize);
      case LoadingType.pulsingGrid:
        return SpinKitPulsingGrid(color: effectiveColor, size: _effectiveSize);
      case LoadingType.wave:
        return SpinKitWave(color: effectiveColor, size: _effectiveSize);
      case LoadingType.chasingDots:
        return SpinKitChasingDots(color: effectiveColor, size: _effectiveSize);
      case LoadingType.threeBounce:
        return SpinKitThreeBounce(color: effectiveColor, size: _effectiveSize);
      case LoadingType.foldingCube:
        return SpinKitFoldingCube(color: effectiveColor, size: _effectiveSize);
      case LoadingType.ring:
        return SpinKitRing(color: effectiveColor, size: _effectiveSize);
      case LoadingType.ripple:
        return SpinKitRipple(color: effectiveColor, size: _effectiveSize);
      case LoadingType.spinningCircle:
        return SpinKitSpinningCircle(
          color: effectiveColor,
          size: _effectiveSize,
        );
      case LoadingType.dancingSquare:
        return SpinKitDancingSquare(
          color: effectiveColor,
          size: _effectiveSize,
        );
    }
  }
}

/// Loading indicator types
enum LoadingType {
  fadingCircle,
  pulsingGrid,
  wave,
  chasingDots,
  threeBounce,
  foldingCube,
  ring,
  ripple,
  spinningCircle,
  dancingSquare,
}

/// Animated loading button with pulse effect
class AnimatedLoadingButton extends StatelessWidget {
  const AnimatedLoadingButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: AppSizes.iconS,
                height: AppSizes.iconS,
                child: CustomLoadingIndicator(
                  size: AppSizes.iconS,
                  type: LoadingType.threeBounce,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(label),
      )
          .animate(
            target: isLoading ? 1 : 0,
            onPlay: (AnimationController controller) {
              if (isLoading) {
                controller.repeat(reverse: true);
              }
            },
          )
          .scaleXY(
            begin: 1,
            end: 0.98,
            duration: 200.ms,
            curve: Curves.easeInOut,
          );
}
