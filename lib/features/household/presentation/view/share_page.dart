import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/household/presentation/view/household_analytics_page.dart';
import 'package:smartdolap/features/household/presentation/view/messages_tab_page.dart';
import 'package:smartdolap/features/household/presentation/view/shared_recipes_tab_page.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/share_cubit.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/share_state.dart';
import 'package:smartdolap/features/household/presentation/widgets/qr_code_generator_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Share page - Recipe sharing and messaging with tabs
class SharePage extends StatefulWidget {
  /// Share page constructor
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState authState) {
        return authState.maybeWhen(
          authenticated: (domain.User user) {
            if (user.householdId == null) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(tr('share_title')),
                ),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.group_outlined,
                          size: 64.sp,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          tr('household_setup_required'),
                          style: TextStyle(
                            fontSize: AppSizes.textL,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          tr('household_setup_description'),
                          style: TextStyle(
                            fontSize: AppSizes.textM,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.householdSetup,
                            );
                          },
                          icon: const Icon(Icons.add_home),
                          label: Text(tr('household_setup_title')),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return BlocProvider<HouseholdCubit>(
              create: (_) => sl<HouseholdCubit>(),
              child: Builder(
                builder: (BuildContext scaffoldContext) => Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: Text(tr('share_title')),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.person_add_outlined),
                        tooltip: tr('invite_member'),
                        onPressed: () => _showInviteDialog(scaffoldContext, user.householdId!),
                      ),
                    ],
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(
                          icon: Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                          ),
                          text: tr('messages'),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                          ),
                          text: tr('shared_recipes'),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                          ),
                          text: tr('statistics'),
                        ),
                      ],
                    ),
                  ),
                  body: Container(
                    color: Colors.white,
                    child: BlocProvider<ShareCubit>(
                      create: (_) => sl<ShareCubit>()..watchShare(user.householdId!),
                      child: BlocBuilder<ShareCubit, ShareState>(
                        builder: (BuildContext context, ShareState state) {
                          return state.when(
                            initial: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            loaded: (List<HouseholdMessage> messages, List<SharedRecipe> sharedRecipes) => TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                MessagesTabPage(
                                  messages: messages,
                                  householdId: user.householdId!,
                                  userId: user.id,
                                  userName: user.displayName ?? user.email,
                                  avatarId: user.avatarId,
                                ),
                                SharedRecipesTabPage(
                                  sharedRecipes: sharedRecipes,
                                ),
                                HouseholdAnalyticsPage(
                                  householdId: user.householdId!,
                                ),
                              ],
                            ),
                            error: (String message) => Center(
                              child: Text(message),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          orElse: () => Scaffold(
            appBar: AppBar(
              title: Text(tr('share_title')),
            ),
            body: const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Future<void> _showInviteDialog(
    BuildContext context,
    String householdId,
  ) async {
    final HouseholdCubit householdCubit = context.read<HouseholdCubit>();

    // Generate invite code
    final String? inviteCode = await householdCubit.generateInviteCode(
      householdId,
    );

    if (!context.mounted || inviteCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('error_generating_invite_code'))),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('invite_member')),
        contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tr('invite_code_description'),
                style: TextStyle(fontSize: AppSizes.textM),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  inviteCode,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              QrCodeGeneratorWidget(
                inviteCode: inviteCode,
                size: 200.w,
              ),
              SizedBox(height: 16.h),
              Text(
                tr('invite_code_instructions'),
                style: TextStyle(
                  fontSize: AppSizes.textS,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
        ],
      ),
    );
  }
}

