import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_page.dart';
import 'package:smartdolap/features/profile/presentation/view/profile_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipes_page.dart';

/// App shell with bottom navigation
/// Prevents back navigation - user must logout to exit
class AppShell extends StatefulWidget {
  /// App shell constructor
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;

  final List<Widget> _pages = const <Widget>[
    PantryPage(),
    RecipesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('[AppShell] AppShell initialized');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          debugPrint('[AppShell] Back button pressed - preventing navigation');
        }
      },
      child: Scaffold(
        body: _pages[_idx],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _idx,
          height: AppSizes.bottomNavHeight,
          onDestinationSelected: (int i) {
            debugPrint('[AppShell] Navigation changed: $_idx -> $i');
            setState(() {
              _idx = i;
            });
          },
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined, size: AppSizes.icon),
              label: tr('pantry_title'),
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu, size: AppSizes.icon),
              label: tr('recipes_title'),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: AppSizes.icon),
              label: tr('profile_title'),
            ),
          ],
        ),
      ),
    );
  }
}
