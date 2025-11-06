import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Recipes page - Shows available recipes
class RecipesPage extends StatelessWidget {
  /// Recipes page constructor
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('recipes_title'),
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
            tr('recipes_empty_message'),
            style: TextStyle(fontSize: AppSizes.text),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
