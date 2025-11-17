import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/i_onboarding_service.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/onboarding/presentation/controllers/onboarding_page_controller.dart';
import 'package:smartdolap/features/onboarding/presentation/widgets/onboarding_slide_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/custom_button.dart';

/// Onboarding page - Shows app introduction slides with vertical scrolling
/// Responsive: Adapts layout for tablet/desktop screens
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
      onboardingService: sl<IOnboardingService>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_controller.isLastPage) {
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
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    // Responsive: Use horizontal scroll for tablet/desktop, vertical for phone
    final bool isTablet = context.isTablet;

    // Responsive padding: More padding on larger screens
    final double horizontalPadding = isTablet
        ? AppSizes.padding * 2
        : AppSizes.padding;
    final double verticalPadding = isTablet
        ? AppSizes.padding * 1.5
        : AppSizes.padding;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppColors.redToBlueDark
              : AppColors.redToBlue,
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              // PageView - Responsive scroll direction
              PageView.builder(
                controller: _controller.pageController,
                scrollDirection: isTablet ? Axis.horizontal : Axis.vertical,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    _controller.currentPage = index;
                  });
                },
                itemCount: _controller.slides.length,
                itemBuilder: (BuildContext context, int index) =>
                    OnboardingSlideWidget(
                      slide: _controller.slides[index],
                      index: index,
                    ),
              ),
              // Skip button - Responsive positioning
              Positioned(
                top: verticalPadding,
                left: horizontalPadding,
                child: _buildSkipButton(),
              ),
              // Next button - Responsive positioning
              Positioned(
                bottom: verticalPadding,
                right: horizontalPadding,
                child: _buildActionButton(isTablet),
              ),
              // Swipe indicator hint - Responsive positioning and visibility
              if (!_controller.isLastPage)
                Positioned(
                  bottom: AppSizes.buttonHeight + verticalPadding * 2,
                  left: 0,
                  right: 0,
                  child: _buildSwipeHint(isTablet),
                ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildSwipeHint(bool isTablet) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      // Responsive icon: Right arrow for tablet, down arrow for phone
      Icon(
            isTablet ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down,
            color: AppColors.textLight.withValues(alpha: 0.6),
            size: isTablet ? 32.w : 24.w,
          )
          .animate(
            onPlay: (AnimationController controller) {
              controller.repeat(reverse: true);
            },
          )
          .move(
            begin: Offset.zero,
            end: isTablet ? const Offset(8, 0) : const Offset(0, 8),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          ),
      SizedBox(height: AppSizes.spacingXS),
      Text(
        tr('onboarding.swipe_hint'),
        style: TextStyle(
          fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
          color: AppColors.textLight.withValues(alpha: 0.6),
        ),
      ),
    ],
  );

  Widget _buildActionButton(bool isTablet) {
    // Responsive button size: Larger on tablet/desktop
    final double buttonWidth = isTablet
        ? (_controller.isLastPage ? 180.w : 140.w)
        : (_controller.isLastPage ? 140.w : 100.w);
    final double buttonHeight = isTablet ? 56.h : 48.h;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: CustomButton(
        text: _controller.isLastPage
            ? tr('onboarding.get_started')
            : tr('onboarding.next'),
        onPressed: _handleNext,
      ),
    );
  }
}
