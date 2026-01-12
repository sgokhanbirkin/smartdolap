import 'dart:async';
import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/analytics/domain/services/i_smart_notification_service.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/services/i_pantry_notification_scheduler.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_view_model.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_header_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_dismissible_widget.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_grid_card.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/pantry_item_group_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/error_state.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/add_item_options_sheet.dart';

/// Layout modes for pantry listings.
enum PantryViewMode {
  /// Renders pantry items as a simple flat list.
  flat,

  /// Groups pantry items under category headers.
  grouped,
}

/// Pantry page - Shows user's pantry items
///
/// Follows MVVM pattern:
/// - View: This widget (UI rendering only)
/// - ViewModel: PantryViewModel (business logic)
/// - Cubit: PantryCubit (state management)
///
/// Responsive: Adapts layout for tablet/desktop screens using ResponsiveGrid
/// Localization: All strings use tr() for i18n support
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
  String? _lastDeletedHouseholdId;

  // Services
  late final IPantryNotificationScheduler _notificationScheduler;

  // MVVM: ViewModel and Cubit
  PantryViewModel? _viewModel;
  PantryCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _notificationScheduler = sl<IPantryNotificationScheduler>();
  }

  void _initializeViewModel(String householdId) {
    if (_viewModel != null) {
      return;
    }

    _cubit = sl<PantryCubit>();
    _viewModel = PantryViewModel(
      cubit: _cubit!,
      listPantryItems: sl(),
      addPantryItem: sl(),
      updatePantryItem: sl(),
      deletePantryItem: sl(),
      notificationCoordinator: sl(),
    );

    // Start watching pantry items
    _viewModel!.watch(householdId);
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
    _notificationScheduler.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    _viewMode.dispose();
    _viewModel?.dispose();
    _cubit?.close();
    super.dispose();
  }

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
            Expanded(child: _buildAuthenticatedContent()),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) => PantryHeaderWidget(
    searchController: _searchController,
    searchQuery: _searchQuery,
  );

  Widget _buildAuthenticatedContent() => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) => state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(
        child: CustomLoadingIndicator(type: LoadingType.wave, size: 50),
      ),
      error: (_) => const EmptyState(messageKey: 'auth_error'),
      unauthenticated: () => const EmptyState(messageKey: 'auth_error'),
      authenticated: (domain.User user) {
        if (user.householdId == null) {
          return _buildHouseholdSetupRequired(context);
        }
        _initializeViewModel(user.householdId!);
        return _buildPantryContent(user);
      },
    ),
  );

  Widget _buildHouseholdSetupRequired(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.group_outlined,
            size: 64.w,
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
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.householdSetup),
            icon: const Icon(Icons.add_home),
            label: Text(tr('household_setup_title')),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildPantryContent(domain.User user) {
    if (_cubit == null) {
      return const SizedBox.shrink();
    }

    return BlocProvider<PantryCubit>.value(
      value: _cubit!,
      child: RepositoryProvider<PantryViewModel>.value(
        value: _viewModel!,
        child: BlocListener<PantryCubit, PantryState>(
          listener: (BuildContext context, PantryState state) async {
            await _handleStateChange(state, user.householdId!);
          },
          child: BlocBuilder<PantryCubit, PantryState>(
            builder: (BuildContext context, PantryState state) =>
                _buildStateContent(context, state, user),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStateChange(PantryState state, String householdId) async {
    if (state.isLoaded) {
      // Schedule expiry notifications
      await _notificationScheduler.scheduleDebounced(state.itemsOrEmpty);

      // Schedule smart notifications
      try {
        await sl<ISmartNotificationService>().scheduleSmartNotifications(
          householdId: householdId,
        );
      } on Exception catch (e) {
        debugPrint('[PantryPage] Error scheduling smart notifications: $e');
      }
    }
  }

  Widget _buildStateContent(
    BuildContext context,
    PantryState state,
    domain.User user,
  ) => state.when(
    initial: () => _buildEmptyState(user),
    loading: () => _buildEmptyState(user),
    loaded: (List<PantryItem> items) =>
        _buildLoadedContent(context, items, user),
    failure: (String messageKey) => _buildErrorState(user),
  );

  Widget _buildEmptyState(domain.User user) => const EmptyState(
    messageKey: 'pantry_empty_message',
    lottieAsset: 'assets/animations/Food_Carousel.json',
  );

  Widget _buildErrorState(domain.User user) => ErrorState(
    messageKey: 'pantry_load_error',
    onRetry: () => _viewModel?.refresh(user.householdId!),
    lottieAsset: 'assets/animations/Food_Carousel.json',
  );

  Widget _buildLoadedContent(
    BuildContext context,
    List<PantryItem> items,
    domain.User user,
  ) {
    if (items.isEmpty) {
      return EmptyState(
        messageKey: 'pantry_empty_message',
        actionLabelKey: 'pantry_empty_cta',
        onAction: () => _navigateToAddItem(
          context,
          user.householdId!,
          user.id,
          user.avatarId,
        ),
        lottieAsset: 'assets/animations/Food_Carousel.json',
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (BuildContext context, String query, Widget? child) {
        final List<PantryItem> filtered = _filterItems(items);
        return ValueListenableBuilder<PantryViewMode>(
          valueListenable: _viewMode,
          builder: (BuildContext context, PantryViewMode mode, Widget? child) =>
              RefreshIndicator(
                onRefresh: () async => _viewModel?.refresh(user.householdId!),
                child: filtered.isEmpty
                    ? _buildNoSearchResults(context)
                    : _buildResponsiveLayout(
                        context,
                        filtered,
                        mode,
                        user.householdId!,
                        user.id,
                        user.avatarId,
                      ),
              ),
        );
      },
    );
  }

  Widget _buildNoSearchResults(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    children: <Widget>[
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search_off,
                size: AppSizes.iconXXL * 1.14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Text(
                tr('no_items_found'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Future<void> _navigateToAddItem(
    BuildContext context,
    String householdId,
    String userId,
    String? avatarId,
  ) async {
    final method = await AddItemOptionsSheet.show(context);
    if (method == null || !context.mounted) return;

    switch (method) {
      case AddItemMethod.manual:
        await Navigator.of(context).pushNamed<bool>(
          AppRouter.pantryAdd,
          arguments: <String, dynamic>{
            'householdId': householdId,
            'userId': userId,
            'avatarId': avatarId,
          },
        );

      case AddItemMethod.barcodeScan:
        await Navigator.of(context).pushNamed<bool>(
          AppRouter.serialBarcodeScanner,
          arguments: <String, dynamic>{
            'householdId': householdId,
            'userId': userId,
          },
        );

      case AddItemMethod.receiptScan:
        // TODO: Implement receipt scanner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('receipt_scan_coming_soon'.tr())),
        );

      case AddItemMethod.visualScan:
        // TODO: Navigate to visual/camera scan
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('visual_scan_coming_soon'.tr())));
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
    String householdId,
    PantryItem item,
  ) async {
    await Navigator.of(context).pushNamed<bool>(
      AppRouter.pantryDetail,
      arguments: <String, dynamic>{'item': item, 'householdId': householdId},
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    List<PantryItem> items,
    PantryViewMode mode,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    final bool isTablet = context.isTablet;

    if (isTablet && mode == PantryViewMode.flat) {
      return _buildGridLayout(context, items, householdId, userId, avatarId);
    }

    return mode == PantryViewMode.flat
        ? _buildFlatList(context, items, householdId, userId, avatarId)
        : _buildGroupedList(context, items, householdId, userId, avatarId);
  }

  Widget _buildGridLayout(
    BuildContext context,
    List<PantryItem> items,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    final int crossAxisCount = ResponsiveGrid.getCrossAxisCount(context);
    final double aspectRatio = ResponsiveGrid.getChildAspectRatio(context);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSizes.spacingS,
        mainAxisSpacing: AppSizes.verticalSpacingS,
        childAspectRatio: aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => RepaintBoundary(
        child: PantryItemGridCard(
          item: items[index],
          userId: householdId,
          onTap: () => _openDetail(context, householdId, items[index]),
          onQuantityChanged: (PantryItem updatedItem) {
            _viewModel?.update(householdId, updatedItem);
          },
        ),
      ),
    );
  }

  Widget _buildFlatList(
    BuildContext context,
    List<PantryItem> items,
    String householdId,
    String userId,
    String? avatarId,
  ) => ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    itemCount: items.length * 2 - 1,
    itemExtent: 108,
    itemBuilder: (BuildContext _, int i) {
      if (i.isOdd) {
        return SizedBox(height: AppSizes.verticalSpacingS);
      }
      final int itemIndex = i ~/ 2;
      _lastDeletedItem = items[itemIndex];
      _lastDeletedHouseholdId = householdId;
      return RepaintBoundary(
        child: _buildDismissibleCard(
          context,
          items[itemIndex],
          householdId,
          () => _openDetail(context, householdId, items[itemIndex]),
          itemIndex,
        ),
      );
    },
  );

  Widget _buildDismissibleCard(
    BuildContext context,
    PantryItem item,
    String householdId,
    VoidCallback onTap,
    int index,
  ) => PantryItemDismissibleWidget(
    item: item,
    userId: householdId,
    index: index,
    onTap: onTap,
    onUndo: () {
      if (_lastDeletedItem != null && _lastDeletedHouseholdId != null) {
        _viewModel?.add(_lastDeletedHouseholdId!, _lastDeletedItem!);
        _lastDeletedItem = null;
        _lastDeletedHouseholdId = null;
      }
    },
  );

  Widget _buildGroupedList(
    BuildContext context,
    List<PantryItem> items,
    String householdId,
    String userId,
    String? avatarId,
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
              userId: householdId,
              onItemTap: (PantryItem item) =>
                  _openDetail(context, householdId, item),
              onQuantityChanged: (PantryItem updatedItem) {
                _viewModel?.update(householdId, updatedItem);
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
                    _lastDeletedHouseholdId = uid;
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
      final String normalizedKey = PantryCategoryHelper.normalize(
        item.category,
      );
      grouped.putIfAbsent(normalizedKey, () => <PantryItem>[]).add(item);
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
