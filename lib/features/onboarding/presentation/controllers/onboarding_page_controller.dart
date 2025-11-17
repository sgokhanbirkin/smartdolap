import 'package:flutter/material.dart';
import 'package:smartdolap/core/services/i_onboarding_service.dart';
import 'package:smartdolap/features/onboarding/data/services/onboarding_slide_service.dart';
import 'package:smartdolap/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:smartdolap/features/onboarding/domain/services/i_onboarding_slide_service.dart';

/// Controller for onboarding page - manages state and navigation
/// Follows Single Responsibility Principle - delegates slide management to OnboardingSlideService
class OnboardingPageController {
  /// Creates an onboarding page controller
  OnboardingPageController({
    required this.onboardingService,
    IOnboardingSlideService? slideService,
  }) : slideService = slideService ?? OnboardingSlideService();

  /// Service for managing onboarding state
  final IOnboardingService onboardingService;

  /// Service for managing onboarding slides
  final IOnboardingSlideService slideService;

  /// Page controller for managing slide navigation
  final PageController pageController = PageController();

  /// Current page index (0-based)
  int currentPage = 0;

  /// Get all slides (delegated to slide service)
  List<OnboardingSlide> get slides => slideService.getSlides();

  /// Navigate to next page
  void nextPage() {
    if (!slideService.isLastSlide(currentPage)) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Check if current page is the last slide
  bool get isLastPage => slideService.isLastSlide(currentPage);

  /// Check if current page is the first slide
  bool get isFirstPage => slideService.isFirstSlide(currentPage);

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await onboardingService.completeOnboarding();
  }

  /// Dispose resources
  void dispose() {
    pageController.dispose();
  }
}
