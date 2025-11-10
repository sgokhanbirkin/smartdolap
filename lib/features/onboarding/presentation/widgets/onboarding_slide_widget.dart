import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:smartdolap/core/constants/app_colors.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/onboarding/domain/entities/onboarding_slide.dart';

/// Onboarding slide widget - displays a single onboarding slide
class OnboardingSlideWidget extends StatefulWidget {
  /// Creates an onboarding slide widget
  const OnboardingSlideWidget({
    required this.slide,
    required this.index,
    super.key,
  });

  /// Slide data
  final OnboardingSlide slide;

  /// Slide index for animation delay
  final int index;

  @override
  State<OnboardingSlideWidget> createState() => _OnboardingSlideWidgetState();
}

class _OnboardingSlideWidgetState extends State<OnboardingSlideWidget> {
  bool _lottieError = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.padding * 2,
      vertical: AppSizes.padding,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Animation widget
        _buildAnimationWidget(),
        SizedBox(height: AppSizes.verticalSpacingXL),
        // Title
        _buildTitle(),
        SizedBox(height: AppSizes.verticalSpacingM),
        // Description
        _buildDescription(),
      ],
    ),
  );

  Widget _buildAnimationWidget() {
    final String? lottieUrl = widget.slide.lottieUrl;

    if (lottieUrl != null && !_lottieError) {
      return SizedBox(
        width: 240.w,
        height: 240.w,
        child: _buildLottieAnimation(lottieUrl),
      );
    }

    return SizedBox(width: 240.w, height: 240.w, child: _buildFallbackIcon());
  }

  Widget _buildLottieAnimation(String path) {
    // Check if it's an asset path (starts with 'assets/') or a network URL
    final bool isAsset = path.startsWith('assets/');

    final Widget lottieWidget = isAsset
        ? Lottie.asset(
            path,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              Future<void>.microtask(() {
                if (mounted) {
                  setState(() {
                    _lottieError = true;
                  });
                }
              });
              return _buildFallbackIcon();
            },
          )
        : Lottie.network(
            path,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              Future<void>.microtask(() {
                if (mounted) {
                  setState(() {
                    _lottieError = true;
                  });
                }
              });
              return _buildFallbackIcon();
            },
          );

    return lottieWidget
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildFallbackIcon() =>
      Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.textLight.withValues(alpha: 0.25),
                  AppColors.textLight.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: AppColors.textLight.withValues(alpha: 0.1),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Icon(
              widget.slide.fallbackIcon,
              size: 100.w,
              color: AppColors.textLight,
            ),
          )
          .animate()
          .fadeIn(
            duration: 600.ms,
            delay: (widget.index * 100).ms,
            curve: Curves.easeOut,
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 600.ms,
            delay: (widget.index * 100).ms,
            curve: Curves.easeOutBack,
          )
          .shimmer(
            duration: 2000.ms,
            delay: (widget.index * 100 + 600).ms,
            color: AppColors.textLight.withValues(alpha: 0.3),
          )
          .then()
          .animate(
            onPlay: (AnimationController controller) {
              controller.repeat(reverse: true);
            },
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1, 1),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          );

  Widget _buildTitle() =>
      Text(
            tr(widget.slide.titleKey),
            style: TextStyle(
              fontSize: AppSizes.textHeading,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              shadows: <Shadow>[
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(
            duration: 500.ms,
            delay: (widget.index * 100 + 300).ms,
            curve: Curves.easeOut,
          )
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 500.ms,
            delay: (widget.index * 100 + 300).ms,
            curve: Curves.easeOutCubic,
          );

  Widget _buildDescription() => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
    child:
        Text(
              tr(widget.slide.descriptionKey),
              style: TextStyle(
                fontSize: AppSizes.textL,
                color: AppColors.textLight.withValues(alpha: 0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: (widget.index * 100 + 500).ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 500.ms,
              delay: (widget.index * 100 + 500).ms,
              curve: Curves.easeOutCubic,
            ),
  );
}
