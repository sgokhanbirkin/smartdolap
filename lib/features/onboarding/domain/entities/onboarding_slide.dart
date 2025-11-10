import 'package:flutter/material.dart';

/// Onboarding slide data model
class OnboardingSlide {
  /// Creates an onboarding slide
  const OnboardingSlide({
    this.lottieUrl,
    required this.titleKey,
    required this.descriptionKey,
    required this.fallbackIcon,
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
