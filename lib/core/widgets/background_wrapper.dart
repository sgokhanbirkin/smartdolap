import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {

  const BackgroundWrapper({
    required this.child, super.key,
    this.useSafeArea = true,
  });
  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}
