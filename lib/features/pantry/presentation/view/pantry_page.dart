// ignore_for_file: directives_ordering, prefer_const_constructors, lines_longer_than_80_chars

import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/pantry_item_card.dart';
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
class PantryPage extends StatefulWidget {
  /// Pantry page constructor
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  PantryViewMode _viewMode = PantryViewMode.grouped;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tr('pantry_title'),
                      style: TextStyle(
                        fontSize: AppSizes.textXL * 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingXS),
                    Text(
                      tr('pantry_subtitle'),
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: AppSizes.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Text(
                  tr('pantry_top_badge'),
                  style: TextStyle(
                    fontSize: AppSizes.textXS,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radius * 2),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: AppSizes.text,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: tr('search'),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.padding,
                  vertical: AppSizes.spacingM,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
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
                builder: (BuildContext context, AuthState state) {
                  return state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_) => EmptyState(messageKey: 'auth_error'),
                    unauthenticated: () => EmptyState(messageKey: 'auth_error'),
                    authenticated: (domain.User user) => BlocProvider<PantryCubit>(
                      create: (BuildContext _) => sl<PantryCubit>()..watch(user.id),
                      child: BlocBuilder<PantryCubit, PantryState>(
                        builder: (BuildContext context, PantryState s) {
                  if (s is PantryLoading || s is PantryInitial) {
                    return EmptyState(
                      messageKey: 'pantry_empty_message',
                      lottieUrl:
                          'https://assets2.lottiefiles.com/packages/lf20_Stt1R2.json',
                    );
                  }
                  if (s is PantryFailure) {
                    return EmptyState(messageKey: 'pantry_empty_message');
                  }
                  final PantryLoaded loaded = s as PantryLoaded;
                  if (loaded.items.isEmpty) {
                    return EmptyState(
                      messageKey: 'pantry_empty_message',
                      actionLabelKey: 'pantry_empty_cta',
                      onAction: () => _addItem(context, user.id),
                      lottieUrl:
                          'https://assets9.lottiefiles.com/packages/lf20_totrpclr.json',
                    );
                  }

                  final List<PantryItem> filtered = _filterItems(loaded.items);
                  final List<String> categories = loaded.items
                      .map(
                        (PantryItem i) =>
                            PantryCategoryHelper.normalize(i.category),
                      )
                      .toSet()
                      .toList()
                    ..sort(
                      (String a, String b) =>
                          PantryCategoryHelper.categories
                              .indexOf(a)
                              .compareTo(
                                PantryCategoryHelper.categories.indexOf(b),
                              ),
                    );

                  return Column(
                    children: <Widget>[
                      SizedBox(height: AppSizes.verticalSpacingS),
                      SegmentedButton<PantryViewMode>(
                        segments: <ButtonSegment<PantryViewMode>>[
                          ButtonSegment<PantryViewMode>(
                            value: PantryViewMode.flat,
                            icon: const Icon(Icons.view_agenda_outlined, size: 16),
                            label: Text(tr('pantry_view_flat')),
                          ),
                          ButtonSegment<PantryViewMode>(
                            value: PantryViewMode.grouped,
                            icon: const Icon(Icons.category_outlined, size: 16),
                            label: Text(tr('pantry_view_grouped')),
                          ),
                        ],
                        selected: <PantryViewMode>{_viewMode},
                        onSelectionChanged: (Set<PantryViewMode> value) =>
                            setState(() => _viewMode = value.first),
                      ),
                      SizedBox(height: AppSizes.verticalSpacingM),
                      // Category filter chips - Modern FilterChip with category colors
                      if (categories.isNotEmpty)
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              FilterChip(
                                label: Text(tr('all_categories')),
                                selected: _selectedCategory == null,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    setState(() => _selectedCategory = null);
                                  }
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                checkmarkColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                labelStyle: TextStyle(
                                  fontSize: AppSizes.textS,
                                  fontWeight: _selectedCategory == null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingS),
                              ...categories.map<Widget>(
                                (String cat) => Padding(
                                  padding: EdgeInsets.only(
                                    right: AppSizes.spacingS,
                                  ),
                                  child: FilterChip(
                                    label: Text(cat),
                                    selected: _selectedCategory == cat,
                                    onSelected: (bool selected) {
                                      setState(
                                        () => _selectedCategory = selected
                                            ? cat
                                            : null,
                                      );
                                    },
                                    selectedColor: _selectedCategory == cat
                                        ? CategoryColors.getCategoryBadgeColor(
                                            cat,
                                          )
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    checkmarkColor:
                                        CategoryColors.getCategoryBadgeTextColor(
                                          cat,
                                        ),
                                    labelStyle: TextStyle(
                                      fontSize: AppSizes.textS,
                                      fontWeight: _selectedCategory == cat
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedCategory == cat
                                          ? CategoryColors.getCategoryBadgeTextColor(
                                              cat,
                                            )
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: AppSizes.verticalSpacingM),
                      // Items list with Pull-to-refresh
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<PantryCubit>().refresh(user.id);
                          },
                          child: filtered.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: <Widget>[
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.4,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.search_off,
                                              size: 64,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            SizedBox(
                                              height: AppSizes.verticalSpacingM,
                                            ),
                                            Text(
                                              tr('no_items_found'),
                                              style: TextStyle(
                                                fontSize: AppSizes.textM,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : _viewMode == PantryViewMode.flat
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
                      ),
                    ],
                  );
                },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: Builder(
      builder: (BuildContext context) => FloatingActionButton.extended(
        onPressed: () {
          final AuthState state = context.read<AuthCubit>().state;
          state.whenOrNull(
            authenticated: (domain.User user) => _addItem(context, user.id),
          );
        },
        label: Text(tr('add_item')),
        icon: const Icon(Icons.add),
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
    final String query = _searchController.text.toLowerCase();
    return items.where((PantryItem item) {
      final String normalizedCategory =
          PantryCategoryHelper.normalize(item.category);
      final bool matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          normalizedCategory.toLowerCase().contains(query);
      final bool matchesCategory =
          _selectedCategory == null ||
          normalizedCategory == _selectedCategory;
      return matchesSearch && matchesCategory;
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
  ) =>
      ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(
          height: AppSizes.verticalSpacingS,
        ),
        itemBuilder: (BuildContext _, int i) => PantryItemCard(
          item: items[i],
          onTap: () => _openDetail(context, userId, items[i]),
        ),
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
            (MapEntry<String, List<PantryItem>> entry) =>
                _PantryCategorySection(
              category: entry.key,
              items: entry.value,
              onTap: (PantryItem item) => _openDetail(context, userId, item),
            ),
          )
          .toList(),
    );
  }

  Map<String, List<PantryItem>> _groupByCategory(List<PantryItem> items) {
    final Map<String, List<PantryItem>> grouped =
        <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      final String key = PantryCategoryHelper.normalize(item.category);
      grouped.putIfAbsent(key, () => <PantryItem>[]).add(item);
    }
    final List<MapEntry<String, List<PantryItem>>> sorted =
        grouped.entries.toList()
          ..sort(
            (MapEntry<String, List<PantryItem>> a,
                    MapEntry<String, List<PantryItem>> b) =>
                PantryCategoryHelper.categories
                    .indexOf(a.key)
                    .compareTo(PantryCategoryHelper.categories.indexOf(b.key)),
          );
    return LinkedHashMap<String, List<PantryItem>>.fromEntries(sorted);
  }
}

class _PantryCategorySection extends StatelessWidget {
  const _PantryCategorySection({
    required this.category,
    required this.items,
    required this.onTap,
  });

  final String category;
  final List<PantryItem> items;
  final ValueChanged<PantryItem> onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                color: CategoryColors.getCategoryColor(category),
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    PantryCategoryHelper.iconFor(category),
                    color: CategoryColors.getCategoryIconColor(category),
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: AppSizes.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    child: Text(
                      '${items.length}',
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingS),
            ...items.map(
              (PantryItem item) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spacingS),
                child: PantryItemCard(
                  item: item,
                  onTap: () => onTap(item),
                ),
              ),
            ),
          ],
        ),
      );
}
