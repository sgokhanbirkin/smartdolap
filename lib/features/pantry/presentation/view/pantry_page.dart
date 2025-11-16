// ignore_for_file: directives_ordering, prefer_const_constructors, lines_longer_than_80_chars

import 'dart:async';
import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_header_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_dismissible_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_group_widget.dart';
import 'package:smartdolap/features/pantry/data/services/pantry_notification_coordinator.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/error_state.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Layout modes for pantry listings.
enum PantryViewMode {
  /// Renders pantry items as a simple flat list.
  flat,

  /// Groups pantry items under category headers.
  grouped,
}

/// Pantry page - Shows user's pantry items
/// TODO(SOLID-SRP): Notification scheduling logic should be extracted to a service
/// TODO(RESPONSIVE): Add tablet/desktop layouts using ResponsiveGrid
/// TODO(LOCALIZATION): Ensure all category names are localization-ready
class PantryPage extends StatefulWidget {
  /// Pantry page constructor
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<PantryViewMode> _viewMode = ValueNotifier<PantryViewMode>(
    PantryViewMode.grouped,
  );
  Timer? _searchDebounce;
  PantryItem? _lastDeletedItem;
  String? _lastDeletedUserId;

  // Debounce for notification scheduling
  Timer? _notificationDebounceTimer;
  DateTime? _lastNotificationSchedule;
  List<String> _lastScheduledItemIds = <String>[];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery.value != _searchController.text) {
        _searchQuery.value = _searchController.text;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _notificationDebounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    _viewMode.dispose();
    super.dispose();
  }

  Future<void> _scheduleNotificationsDebounced(List<PantryItem> items) async {
    // Create a hash of item IDs to check if items actually changed
    final List<String> currentItemIds =
        items
            .map(
              (PantryItem item) =>
                  '${item.id}_${item.expiryDate?.millisecondsSinceEpoch ?? 0}',
            )
            .toList()
          ..sort();
    final String currentHash = currentItemIds.join('|');

    // Check if items actually changed
    final List<String> lastHash = _lastScheduledItemIds;
    if (lastHash.join('|') == currentHash) {
      // Items haven't changed, skip scheduling
      return;
    }

    _lastScheduledItemIds = currentItemIds;

    // Debounce: Wait 2 seconds before scheduling
    final DateTime now = DateTime.now();
    _notificationDebounceTimer?.cancel();

    if (_lastNotificationSchedule != null &&
        now.difference(_lastNotificationSchedule!).inSeconds < 2) {
      _notificationDebounceTimer = Timer(const Duration(seconds: 2), () async {
        if (mounted) {
          final PantryNotificationCoordinator coordinator =
              sl<PantryNotificationCoordinator>();
          await coordinator.scheduleForItems(items);
          _lastNotificationSchedule = DateTime.now();
        }
      });
      return;
    }

    _lastNotificationSchedule = now;
    final PantryNotificationCoordinator coordinator =
        sl<PantryNotificationCoordinator>();
    await coordinator.scheduleForItems(items);
  }

  Widget _buildHeader(BuildContext context) => PantryHeaderWidget(
    searchController: _searchController,
    searchQuery: _searchQuery,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context),
            SizedBox(height: AppSizes.verticalSpacingL),
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (BuildContext context, AuthState state) => state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => Center(
                    child: CustomLoadingIndicator(
                      type: LoadingType.wave,
                      size: 50,
                    ),
                  ),
                  error: (_) => EmptyState(messageKey: 'auth_error'),
                  unauthenticated: () => EmptyState(messageKey: 'auth_error'),
                  authenticated: (domain.User user) => BlocProvider<PantryCubit>(
                    create: (BuildContext _) =>
                        sl<PantryCubit>()..watch(user.id),
                    child: BlocListener<PantryCubit, PantryState>(
                      listener: (BuildContext context, PantryState state) async {
                        if (state is PantryLoaded) {
                          // Schedule expiry notifications when items are loaded
                          // Use debounced version to avoid excessive calls
                          await _scheduleNotificationsDebounced(state.items);
                        }
                      },
                      child: BlocBuilder<PantryCubit, PantryState>(
                        builder: (BuildContext context, PantryState s) {
                          if (s is PantryLoading || s is PantryInitial) {
                            return EmptyState(
                              messageKey: 'pantry_empty_message',
                              lottieAsset:
                                  'assets/animations/Food_Carousel.json',
                            );
                          }
                          if (s is PantryFailure) {
                            return ErrorState(
                              messageKey: 'pantry_empty_message',
                              onRetry: () =>
                                  context.read<PantryCubit>().watch(user.id),
                              lottieAsset:
                                  'assets/animations/Food_Carousel.json',
                            );
                          }
                          final PantryLoaded loaded = s as PantryLoaded;
                          if (loaded.items.isEmpty) {
                            return EmptyState(
                              messageKey: 'pantry_empty_message',
                              actionLabelKey: 'pantry_empty_cta',
                              onAction: () => _addItem(context, user.id),
                              lottieAsset:
                                  'assets/animations/Food_Carousel.json',
                            );
                          }

                          return ValueListenableBuilder<String>(
                            valueListenable: _searchQuery,
                            builder: (BuildContext context, String query, Widget? child) {
                              final List<PantryItem> filtered = _filterItems(
                                loaded.items,
                              );
                              return ValueListenableBuilder<PantryViewMode>(
                                valueListenable: _viewMode,
                                builder:
                                    (
                                      BuildContext context,
                                      PantryViewMode mode,
                                      Widget? child3,
                                    ) => RefreshIndicator(
                                      onRefresh: () async {
                                        await context
                                            .read<PantryCubit>()
                                            .refresh(user.id);
                                      },
                                      child: filtered.isEmpty
                                          ? ListView(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              children: <Widget>[
                                                SizedBox(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.4,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.search_off,
                                                          size:
                                                              AppSizes.iconXXL *
                                                              1.14,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                        SizedBox(
                                                          height: AppSizes
                                                              .verticalSpacingM,
                                                        ),
                                                        Text(
                                                          tr('no_items_found'),
                                                          style: TextStyle(
                                                            fontSize:
                                                                AppSizes.textM,
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : mode == PantryViewMode.flat
                                          ? _buildFlatList(
                                              context,
                                              filtered,
                                              user.id,
                                            )
                                          : _buildGroupedList(
                                              context,
                                              filtered,
                                              user.id,
                                            ),
                                    ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _addItem(BuildContext context, String userId) async {
    final bool? created = await Navigator.of(
      context,
    ).pushNamed<bool>(AppRouter.pantryAdd, arguments: userId);
    if (created == true) {
      // no-op, stream will update list
    }
  }

  List<PantryItem> _filterItems(List<PantryItem> items) {
    final String query = _searchQuery.value.toLowerCase();
    return items.where((PantryItem item) {
      final String normalizedCategory = PantryCategoryHelper.normalize(
        item.category,
      );
      final bool matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          normalizedCategory.toLowerCase().contains(query);
      return matchesSearch;
    }).toList();
  }

  Future<void> _openDetail(
    BuildContext context,
    String userId,
    PantryItem item,
  ) async {
    final bool? updated = await Navigator.of(context).pushNamed<bool>(
      AppRouter.pantryDetail,
      arguments: <String, dynamic>{'item': item, 'userId': userId},
    );
    if (updated == true) {
      // no-op, stream will update list
    }
  }

  Widget _buildFlatList(
    BuildContext context,
    List<PantryItem> items,
    String userId,
  ) => ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    itemCount: items.length,
    separatorBuilder: (_, __) => SizedBox(height: AppSizes.verticalSpacingS),
    itemBuilder: (BuildContext _, int i) {
      _lastDeletedItem = items[i];
      _lastDeletedUserId = userId;
      return _buildDismissibleCard(
        context,
        items[i],
        userId,
        () => _openDetail(context, userId, items[i]),
        i,
      );
    },
  );

  Widget _buildDismissibleCard(
    BuildContext context,
    PantryItem item,
    String userId,
    VoidCallback onTap,
    int index,
  ) => PantryItemDismissibleWidget(
    item: item,
    userId: userId,
    index: index,
    onTap: onTap,
    onUndo: () {
      if (_lastDeletedItem != null && _lastDeletedUserId != null) {
        context.read<PantryCubit>().add(_lastDeletedUserId!, _lastDeletedItem!);
        _lastDeletedItem = null;
        _lastDeletedUserId = null;
      }
    },
  );

  Widget _buildGroupedList(
    BuildContext context,
    List<PantryItem> items,
    String userId,
  ) {
    final Map<String, List<PantryItem>> grouped = _groupByCategory(items);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: grouped.entries
          .map(
            (MapEntry<String, List<PantryItem>> entry) => PantryItemGroupWidget(
              category: entry.key,
              items: entry.value,
              userId: userId,
              onItemTap: (PantryItem item) =>
                  _openDetail(context, userId, item),
              onQuantityChanged: (PantryItem updatedItem) {
                context.read<PantryCubit>().update(userId, updatedItem);
              },
              buildDismissibleCard:
                  (
                    BuildContext ctx,
                    PantryItem item,
                    String uid,
                    VoidCallback tap,
                    int index,
                  ) {
                    _lastDeletedItem = item;
                    _lastDeletedUserId = uid;
                    return _buildDismissibleCard(ctx, item, uid, tap, index);
                  },
            ),
          )
          .toList(),
    );
  }

  Map<String, List<PantryItem>> _groupByCategory(List<PantryItem> items) {
    final Map<String, List<PantryItem>> grouped = <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      final String key = PantryCategoryHelper.normalize(item.category);
      grouped.putIfAbsent(key, () => <PantryItem>[]).add(item);
    }
    final List<MapEntry<String, List<PantryItem>>> sorted =
        grouped.entries.toList()..sort(
          (
            MapEntry<String, List<PantryItem>> a,
            MapEntry<String, List<PantryItem>> b,
          ) => PantryCategoryHelper.categories
              .indexOf(a.key)
              .compareTo(PantryCategoryHelper.categories.indexOf(b.key)),
        );
    return LinkedHashMap<String, List<PantryItem>>.fromEntries(sorted);
  }
}
