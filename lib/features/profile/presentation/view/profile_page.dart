import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Profile page - User profile and settings
class ProfilePage extends StatelessWidget {
  /// Profile page constructor
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('profile_title'),
        style: TextStyle(fontSize: AppSizes.textL),
      ),
      automaticallyImplyLeading: false,
      elevation: AppSizes.appBarElevation,
      toolbarHeight: AppSizes.appBarHeight,
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Center(
          child: Text(
            tr('profile_welcome_message'),
            style: TextStyle(fontSize: AppSizes.text),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
