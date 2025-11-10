import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/onboarding_service.dart';
import 'package:smartdolap/features/onboarding/presentation/controllers/onboarding_page_controller.dart';
import 'package:smartdolap/features/onboarding/presentation/widgets/onboarding_slide_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/custom_button.dart';

/// Onboarding page - Shows app introduction slides with vertical scrolling
class OnboardingPage extends StatefulWidget {
  /// Onboarding page constructor
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingPageController(
      onboardingService: sl<OnboardingService>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_controller.currentPage < OnboardingPageController.slides.length - 1) {
      _controller.nextPage();
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await _controller.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? AppColors.redToBlueDark
            : AppColors.redToBlue,
      ),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            // PageView - Vertical scroll
            PageView.builder(
              controller: _controller.pageController,
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (int index) {
                setState(() {
                  _controller.currentPage = index;
                });
              },
              itemCount: OnboardingPageController.slides.length,
              itemBuilder: (BuildContext context, int index) =>
                  OnboardingSlideWidget(
                    slide: OnboardingPageController.slides[index],
                    index: index,
                  ),
            ),
            // Skip button - sol üst
            Positioned(top: 0, left: 0, child: _buildSkipButton()),
            // Next button - sağ alt
            Positioned(
              bottom: AppSizes.padding,
              right: AppSizes.padding,
              child: _buildActionButton(),
            ),
            // Swipe indicator hint - alt ortada
            if (_controller.currentPage <
                OnboardingPageController.slides.length - 1)
              Positioned(
                bottom: AppSizes.buttonHeight + AppSizes.padding * 2,
                left: 0,
                right: 0,
                child: _buildSwipeHint(),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSkipButton() => Padding(
    padding: EdgeInsets.all(AppSizes.padding),
    child: TextButton(
      onPressed: _skipOnboarding,
      child: Text(
        tr('onboarding.skip'),
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: AppSizes.textM,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _buildSwipeHint() => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textLight.withValues(alpha: 0.6),
            size: 24.w,
          )
          .animate(
            onPlay: (AnimationController controller) {
              controller.repeat(reverse: true);
            },
          )
          .moveY(begin: 0, end: 8, duration: 1000.ms, curve: Curves.easeInOut),
      SizedBox(height: AppSizes.spacingXS),
      Text(
        tr('onboarding.swipe_hint'),
        style: TextStyle(
          fontSize: AppSizes.textS,
          color: AppColors.textLight.withValues(alpha: 0.6),
        ),
      ),
    ],
  );

  Widget _buildActionButton() {
    final bool isLastPage =
        _controller.currentPage == OnboardingPageController.slides.length - 1;
    return SizedBox(
      width: isLastPage ? 140.w : 100.w,
      height: 48.h,
      child: CustomButton(
        text: isLastPage ? tr('onboarding.get_started') : tr('onboarding.next'),
        onPressed: _handleNext,
      ),
    );
  }
}
