import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/guards/auth_guard.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_page.dart';
import 'package:smartdolap/features/profile/presentation/view/profile_page.dart';
import 'package:smartdolap/features/recipes/presentation/view/recipes_page.dart';

/// App shell with bottom navigation
/// Prevents back navigation - user must logout to exit
/// TODO(RESPONSIVE): Add tablet/desktop navigation (drawer or side navigation)
/// TODO(LOCALIZATION): Ensure all navigation labels are localization-ready
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
    // Responsive: Use drawer for tablet/desktop, bottom nav for phone
    final bool isTablet = context.isTablet;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          debugPrint('[AppShell] Back button pressed - preventing navigation');
        }
      },
      child: Scaffold(
        body: AuthGuardWidget(
          child: _pages[_idx],
        ),
        // Responsive navigation: Drawer for tablet/desktop, bottom nav for phone
        drawer: isTablet ? _buildDrawer(context) : null,
        bottomNavigationBar: isTablet
            ? null
            : NavigationBar(
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

  /// Build drawer navigation for tablet/desktop
  Widget _buildDrawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                tr('app_name'),
                style: TextStyle(
                  fontSize: AppSizes.textXL,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.kitchen_outlined, size: AppSizes.icon),
          title: Text(tr('pantry_title')),
          selected: _idx == 0,
          onTap: () {
            setState(() {
              _idx = 0;
            });
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: Icon(Icons.restaurant_menu, size: AppSizes.icon),
          title: Text(tr('recipes_title')),
          selected: _idx == 1,
          onTap: () {
            setState(() {
              _idx = 1;
            });
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: Icon(Icons.person_outline, size: AppSizes.icon),
          title: Text(tr('profile_title')),
          selected: _idx == 2,
          onTap: () {
            setState(() {
              _idx = 2;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
