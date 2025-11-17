import 'package:smartdolap/features/onboarding/domain/entities/onboarding_slide.dart';

/// Interface for managing onboarding slides
/// Follows Dependency Inversion Principle (DIP)
abstract class IOnboardingSlideService {
  /// Get all onboarding slides
  List<OnboardingSlide> getSlides();

  /// Get total number of slides
  int getSlideCount();

  /// Check if given index is the last slide
  bool isLastSlide(int index);

  /// Check if given index is the first slide
  bool isFirstSlide(int index);
}
