import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart'
    as domain;
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_grid_widget.dart';

/// Badges page - Shows all badges
class BadgesPage extends StatefulWidget {
  /// Badges page constructor
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  List<domain.Badge> _badges = <domain.Badge>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final BuildContext authContext = context;
    final AuthState authState = authContext.read<AuthCubit>().state;
    await authState.whenOrNull(
      authenticated: (domain.User user) async {
        final BadgeService badgeService = BadgeService(
          statsService: sl<IProfileStatsService>(),
          badgeRepository: sl<IBadgeRepository>(),
          userId: user.id,
        );
        final List<domain.Badge> badges = await badgeService
            .getAllBadgesWithStatus();
        if (mounted) {
          setState(() {
            _badges = badges;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => BackgroundWrapper(
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0), // Mor renk (rozet teması)
        foregroundColor: Colors.white,
        title: Row(
          children: <Widget>[
            Icon(Icons.emoji_events, size: AppSizes.icon),
            SizedBox(width: AppSizes.spacingS),
            Flexible(
              child: Text(
                tr('badges_title'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.padding * 2),
                child: const CustomLoadingIndicator(
                  type: LoadingType.pulsingGrid,
                  size: 50,
                ),
              ),
            )
          : _badges.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.padding * 2),
                child: Text(
                  tr('no_badges'),
                  style: TextStyle(
                    fontSize: AppSizes.textM,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(AppSizes.padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveGrid.getCrossAxisCount(context),
                crossAxisSpacing: AppSizes.spacingS,
                mainAxisSpacing: AppSizes.verticalSpacingS,
                childAspectRatio: ResponsiveGrid.getChildAspectRatio(context),
              ),
              itemCount: _badges.length,
              itemBuilder: (BuildContext context, int index) {
                final domain.Badge badge = _badges[index];
                return BadgeCardWidget(
                  badge: badge,
                  index: index,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => BadgeDetailDialogWidget(badge: badge),
                    );
                  },
                );
              },
            ),
    ),
  );
}
