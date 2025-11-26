// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';

/// Adaptive scaffold that adjusts layout based on screen size
/// Follows SOLID principles - Single Responsibility (only scaffold layout)
class AdaptiveScaffold extends StatelessWidget {
  /// Adaptive scaffold constructor
  const AdaptiveScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  /// Main body content
  final Widget body;

  /// App bar (optional)
  final PreferredSizeWidget? appBar;

  /// Floating action button (optional)
  final Widget? floatingActionButton;

  /// Drawer for tablet/desktop (optional)
  final Widget? drawer;

  /// End drawer for tablet/desktop (optional)
  final Widget? endDrawer;

  /// Bottom navigation bar for phone (optional)
  final Widget? bottomNavigationBar;

  /// Resize to avoid bottom inset
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    return Scaffold(
      appBar: appBar,
      body: isTablet
          ? _buildTabletLayout(context)
          : _buildPhoneLayout(context),
      floatingActionButton: floatingActionButton,
      drawer: isTablet ? drawer : null,
      endDrawer: isTablet ? endDrawer : null,
      bottomNavigationBar: isTablet ? null : bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildPhoneLayout(BuildContext context) => SafeArea(
      child: body,
    );

  Widget _buildTabletLayout(BuildContext context) => SafeArea(
      child: Row(
        children: <Widget>[
          // Left panel for drawer (if provided)
          if (drawer != null)
            SizedBox(
              width: 280.w,
              child: drawer,
            ),
          // Main content
          Expanded(
            child: body,
          ),
          // Right panel for end drawer (if provided)
          if (endDrawer != null)
            SizedBox(
              width: 280.w,
              child: endDrawer,
            ),
        ],
      ),
    );
}

