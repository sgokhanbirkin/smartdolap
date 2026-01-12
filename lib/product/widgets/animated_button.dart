// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:smartdolap/core/utils/haptics.dart';

/// Animated button with scale effect and haptic feedback
/// Provides tactile and visual feedback for button interactions
/// 
/// Usage:
/// ```dart
/// AnimatedButton(
///   onPressed: () => doSomething(),
///   child: Text('Click Me'),
/// )
/// ```
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool enableHaptics;

  const AnimatedButton({
    required this.child,
    this.onPressed,
    this.style,
    this.enableHaptics = true,
    super.key,
  });

  /// Create an elevated animated button
  factory AnimatedButton.elevated({
    required Widget child,
    VoidCallback? onPressed,
    ButtonStyle? style,
    bool enableHaptics = true,
    Key? key,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      style: style,
      enableHaptics: enableHaptics,
      key: key,
      child: child,
    );
  }

  /// Create an outlined animated button
  factory AnimatedButton.outlined({
    required Widget child,
    VoidCallback? onPressed,
    ButtonStyle? style,
    bool enableHaptics = true,
    Key? key,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      style: style,
      enableHaptics: enableHaptics,
      key: key,
      child: child,
    );
  }

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onPressed != null) {
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        if (widget.enableHaptics) {
          Haptics.medium();
        }
        widget.onPressed?.call();
      });
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: ElevatedButton(
          onPressed: null, // Disabled, using gesture detector
          style: widget.style,
          child: widget.child,
        ),
      ),
    );
  }
}

