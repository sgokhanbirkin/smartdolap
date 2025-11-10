import 'package:flutter/material.dart';
import 'package:smartdolap/core/services/onboarding_service.dart';
import 'package:smartdolap/features/onboarding/domain/entities/onboarding_slide.dart';

/// Controller for onboarding page - manages state and navigation
/// TODO(SOLID-SRP): Extract slide management to OnboardingSlideService
/// TODO(RESPONSIVE): Add responsive breakpoints for tablet/desktop
/// TODO(LOCALIZATION): Ensure all slide content is localization-ready
class OnboardingPageController {
  /// Creates an onboarding page controller
  OnboardingPageController({required this.onboardingService});

  final OnboardingService onboardingService;
  final PageController pageController = PageController();
  int currentPage = 0;

  /// Slides data
  static const List<OnboardingSlide> slides = <OnboardingSlide>[
    OnboardingSlide(
      lottieUrl: 'assets/animations/Cooking.json',
      titleKey: 'onboarding.welcome.title',
      descriptionKey: 'onboarding.welcome.description',
      fallbackIcon: Icons.restaurant_menu,
    ),
    OnboardingSlide(
      lottieUrl: 'assets/animations/Food_Carousel.json',
      titleKey: 'onboarding.pantry.title',
      descriptionKey: 'onboarding.pantry.description',
      fallbackIcon: Icons.kitchen,
    ),
    OnboardingSlide(
      lottieUrl: 'assets/animations/Recipe_Book.json',
      titleKey: 'onboarding.recipes.title',
      descriptionKey: 'onboarding.recipes.description',
      fallbackIcon: Icons.auto_awesome,
    ),
    OnboardingSlide(
      lottieUrl: 'assets/animations/Notification_Bell.json',
      titleKey: 'onboarding.notifications.title',
      descriptionKey: 'onboarding.notifications.description',
      fallbackIcon: Icons.notifications_active,
    ),
    OnboardingSlide(
      lottieUrl: 'assets/animations/Rocket_Lunch.json',
      titleKey: 'onboarding.ready.title',
      descriptionKey: 'onboarding.ready.description',
      fallbackIcon: Icons.rocket_launch,
    ),
  ];

  /// Navigate to next page
  void nextPage() {
    if (currentPage < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await onboardingService.completeOnboarding();
  }

  /// Dispose resources
  void dispose() {
    pageController.dispose();
  }
}
