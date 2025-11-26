import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/services/avatar_service.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_view_model.dart';
import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_state.dart';
import 'package:smartdolap/features/household/presentation/widgets/qr_code_scanner_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Household setup page - Create or join a household
class HouseholdSetupPage extends StatefulWidget {
  /// Household setup page constructor
  const HouseholdSetupPage({super.key});

  @override
  State<HouseholdSetupPage> createState() => _HouseholdSetupPageState();
}

class _HouseholdSetupPageState extends State<HouseholdSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  String? _selectedAvatarId;
  bool _isCreating = true; // true = create, false = join

  @override
  void dispose() {
    _nameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackgroundWrapper(
    child: Scaffold(
      appBar: AppBar(title: Text(tr('household_setup_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Welcome message
              Text(
                tr('household_setup_welcome'),
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Info icon and description
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        tr('household_setup_description'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Toggle between create and join
              _buildModeToggle(),
              SizedBox(height: 24.h),
              // Create mode
              if (_isCreating) _buildCreateForm(),
              // Join mode
              if (!_isCreating) _buildJoinForm(),
              SizedBox(height: 24.h),
              // Leave info
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 18.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        tr('household_setup_leave_info'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildModeToggle() => Container(
    padding: EdgeInsets.all(4.w),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: _buildToggleButton(
            label: tr('create_household'),
            isSelected: _isCreating,
            onTap: () => setState(() => _isCreating = true),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildToggleButton(
            label: tr('join_household'),
            isSelected: !_isCreating,
            onTap: () => setState(() => _isCreating = false),
          ),
        ),
      ],
    ),
  );

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );

  Widget _buildCreateForm() => BlocConsumer<HouseholdCubit, HouseholdState>(
    listener: (BuildContext context, HouseholdState state) {
      state.when(
        initial: () {},
        loading: () {},
        loaded: (Household household) async {
          // Debug: Log household creation
          debugPrint('[HouseholdSetup] Household created: ${household.id}');
          debugPrint(
            '[HouseholdSetup] Members count: ${household.members.length}',
          );
          for (final HouseholdMember member in household.members) {
            debugPrint(
              '[HouseholdSetup] Member: ${member.userId} - ${member.userName}',
            );
          }
          // Refresh user data to get updated householdId
          // Wait a bit for Firestore write to complete
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (!context.mounted) {
            return;
          }
          await context.read<AuthViewModel>().refreshUser();
          if (!context.mounted) {
            return;
          }
          // Navigate to food preferences onboarding after successful household creation/join
          unawaited(
            Navigator.of(context).pushReplacementNamed(
              AppRouter.foodPreferencesOnboarding,
            ),
          );
        },
        noHousehold: () {},
        error: (String message) {
          debugPrint('[HouseholdSetup] Error: $message');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    },
    builder: (BuildContext context, HouseholdState state) {
      final bool isLoading = state.maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Avatar selection
          Text(
            tr('select_avatar'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          AvatarSelectorWidget(
            selectedAvatarId: _selectedAvatarId,
            onAvatarSelected: (String avatarId) {
              setState(() => _selectedAvatarId = avatarId);
            },
          ),
          SizedBox(height: 24.h),
          // Household name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: tr('household_name'),
              hintText: tr('household_name_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Create button
          ElevatedButton(
            onPressed: isLoading ? null : _handleCreate,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    tr('create_household'),
                    style: TextStyle(fontSize: 16.sp),
                  ),
          ),
        ],
      );
    },
  );

  Widget _buildJoinForm() => BlocConsumer<HouseholdCubit, HouseholdState>(
    listener: (BuildContext context, HouseholdState state) {
      state.when(
        initial: () {},
        loading: () {},
        loaded: (Household household) async {
          // Debug: Log household creation
          debugPrint('[HouseholdSetup] Household created: ${household.id}');
          debugPrint(
            '[HouseholdSetup] Members count: ${household.members.length}',
          );
          for (final HouseholdMember member in household.members) {
            debugPrint(
              '[HouseholdSetup] Member: ${member.userId} - ${member.userName}',
            );
          }
          // Refresh user data to get updated householdId
          // Wait a bit for Firestore write to complete
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (!context.mounted) {
            return;
          }
          await context.read<AuthViewModel>().refreshUser();
          if (!context.mounted) {
            return;
          }
          // Navigate to food preferences onboarding after successful household creation/join
          unawaited(
            Navigator.of(context).pushReplacementNamed(
              AppRouter.foodPreferencesOnboarding,
            ),
          );
        },
        noHousehold: () {},
        error: (String message) {
          debugPrint('[HouseholdSetup] Error: $message');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    },
    builder: (BuildContext context, HouseholdState state) {
      final bool isLoading = state.maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Avatar selection
          Text(
            tr('select_avatar'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          AvatarSelectorWidget(
            selectedAvatarId: _selectedAvatarId,
            onAvatarSelected: (String avatarId) {
              setState(() => _selectedAvatarId = avatarId);
            },
          ),
          SizedBox(height: 24.h),
          // Invite code input
          TextField(
            controller: _inviteCodeController,
            decoration: InputDecoration(
              labelText: tr('invite_code'),
              hintText: tr('invite_code_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Join button
          ElevatedButton(
            onPressed: isLoading ? null : _handleJoin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(tr('join_household'), style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      );
    },
  );

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('household_name_required'))));
      return;
    }

    final AuthState authState = context.read<AuthCubit>().state;
    final HouseholdCubit householdCubit = context.read<HouseholdCubit>();
    final User? user = authState.maybeWhen(
      authenticated: (User user) => user,
      orElse: () => null,
    );
    if (user == null) {
      return;
    }

    await householdCubit.createHousehold(
      name: _nameController.text.trim(),
      ownerId: user.id,
      ownerName: user.displayName ?? user.email,
      ownerAvatarId: _selectedAvatarId ?? AvatarService.getDefaultAvatar(),
    );
  }

  Future<void> _handleJoin() async {
    final String inviteCode = _inviteCodeController.text.trim().toUpperCase();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('invite_code_required'))));
      return;
    }

    final AuthState authState = context.read<AuthCubit>().state;
    final HouseholdCubit householdCubit = context.read<HouseholdCubit>();
    final User? user = authState.maybeWhen(
      authenticated: (User user) => user,
      orElse: () => null,
    );
    if (user == null) {
      return;
    }

    await householdCubit.joinHouseholdWithCode(
      inviteCode: inviteCode,
      userId: user.id,
      userName: user.displayName ?? user.email,
      avatarId: _selectedAvatarId ?? AvatarService.getDefaultAvatar(),
    );
  }

  void _scanQRCode() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QrCodeScannerWidget(
          onCodeScanned: (String code) {
            setState(() {
              _inviteCodeController.text = code;
            });
          },
        ),
      ),
    );
  }
}
