import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';

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
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_) => const _ProfileContent(),
            unauthenticated: () => const _ProfileContent(),
            authenticated: (domain.User user) => _ProfileContent(user: user),
          ),
        ),
      ),
    ),
  );
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({this.user});

  final domain.User? user;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SizedBox(height: AppSizes.verticalSpacingL),
      CircleAvatar(radius: 40, child: Icon(Icons.person, size: AppSizes.iconL)),
      SizedBox(height: AppSizes.verticalSpacingM),
      Text(
        user?.email ?? tr('guest'),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: AppSizes.text),
      ),
      SizedBox(height: AppSizes.verticalSpacingXL),
      Text(tr('language'), style: TextStyle(fontSize: AppSizes.textM)),
      SizedBox(height: AppSizes.verticalSpacingS),
      Wrap(
        spacing: AppSizes.spacingM,
        children: <Widget>[
          OutlinedButton(
            onPressed: () => context.setLocale(const Locale('tr', 'TR')),
            child: const Text('Türkçe'),
          ),
          OutlinedButton(
            onPressed: () => context.setLocale(const Locale('en', 'US')),
            child: const Text('English'),
          ),
        ],
      ),
      SizedBox(height: AppSizes.verticalSpacingXL),
      ElevatedButton.icon(
        onPressed: () => context.read<AuthCubit>().logout(),
        icon: const Icon(Icons.logout),
        label: Text(tr('logout')),
      ),
    ],
  );
}
