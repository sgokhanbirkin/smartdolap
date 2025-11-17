import 'package:flutter/material.dart';
import 'package:smartdolap/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:smartdolap/features/onboarding/domain/services/i_onboarding_slide_service.dart';

/// Service for managing onboarding slides
/// Follows Single Responsibility Principle - only handles slide data management
class OnboardingSlideService implements IOnboardingSlideService {
  /// Factory constructor to return singleton instance
  factory OnboardingSlideService() => _instance;

  OnboardingSlideService._();

  /// Singleton instance
  static final OnboardingSlideService _instance = OnboardingSlideService._();

  /// All onboarding slides
  static const List<OnboardingSlide> _slides = <OnboardingSlide>[
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

  @override
  List<OnboardingSlide> getSlides() => _slides;

  @override
  int getSlideCount() => _slides.length;

  @override
  bool isLastSlide(int index) => index == _slides.length - 1;

  @override
  bool isFirstSlide(int index) => index == 0;
}
