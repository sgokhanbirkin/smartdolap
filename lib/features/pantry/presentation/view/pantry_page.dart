import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Pantry page - Shows user's pantry items
class PantryPage extends StatelessWidget {
  /// Pantry page constructor
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('pantry_title'),
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
            tr('pantry_empty_message'),
            style: TextStyle(fontSize: AppSizes.text),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
