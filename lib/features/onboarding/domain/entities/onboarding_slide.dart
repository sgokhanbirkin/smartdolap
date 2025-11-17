import 'package:flutter/material.dart';

/// Onboarding slide data model
class OnboardingSlide {
  /// Creates an onboarding slide
  const OnboardingSlide({
    required this.titleKey,
    required this.descriptionKey,
    required this.fallbackIcon,
    this.lottieUrl,
  });

  /// Lottie animation URL
  final String? lottieUrl;

  /// Fallback icon if Lottie fails
  final IconData fallbackIcon;

  /// Translation key for title
  final String titleKey;

  /// Translation key for description
  final String descriptionKey;
}
