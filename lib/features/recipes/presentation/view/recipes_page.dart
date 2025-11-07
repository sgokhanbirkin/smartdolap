import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/favorites_shelf_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/filter_dialog_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/get_suggestions_dialog_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/shimmer_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/core/widgets/animated_recipe_card.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';

/// Recipes page - Shows available recipes
class RecipesPage extends StatefulWidget {
  /// Recipes page constructor
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final ScrollController _scrollController = ScrollController();
  RecipesCubit? _recipesCubit;
  String? _activeUserId;
  late Future<Box<dynamic>> _favoritesFuture;
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );
  Timer? _scrollThrottle;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = Hive.isBoxOpen('favorite_recipes')
        ? Future<Box<dynamic>>.value(Hive.box<dynamic>('favorite_recipes'))
        : Hive.openBox<dynamic>('favorite_recipes');
    _scrollController.addListener(_onScrollChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onScrollChanged() {
    // Throttle scroll updates to prevent too frequent rebuilds
    _scrollThrottle?.cancel();
    _scrollThrottle = Timer(const Duration(milliseconds: 32), () {
      if (!mounted || !_scrollController.hasClients) return;
      final double offset = _scrollController.offset;
      // Daha büyük threshold ile daha az güncelleme
      if ((_scrollOffsetNotifier.value - offset).abs() > 20.0) {
        _scrollOffsetNotifier.value = offset;
      }
    });
  }

  @override
  void dispose() {
    _scrollThrottle?.cancel();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final AuthState st = context.read<AuthCubit>().state;
    await st.whenOrNull(
      authenticated: (domain.User user) async {
        final IPantryRepository repo = sl<IPantryRepository>();
        final List<PantryItem> items = await repo.getItems(userId: user.id);
        final RecipesState currentState = _recipesCubit?.state ?? RecipesInitial();
        final Map<String, dynamic> currentFilters =
            currentState is RecipesLoaded
            ? currentState.activeFilters
            : <String, dynamic>{};

        final bool? ok = await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => FilterDialogWidget(
            items: items,
            currentFilters: currentFilters,
            onApply: (Map<String, dynamic> filters) {
              if (_recipesCubit == null) return;
              _recipesCubit!.applyFilter(
                ingredients: filters['ingredients'] as List<String>?,
                meal: filters['meal'] as String?,
                maxCalories: filters['maxCalories'] as int?,
                minFiber: filters['minFiber'] as int?,
              );
            },
          ),
        );
        if (ok == false && context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _showGetSuggestionsDialog(BuildContext context) async {
    final AuthState st = context.read<AuthCubit>().state;
    await st.whenOrNull(
      authenticated: (domain.User user) async {
        final IPantryRepository repo = sl<IPantryRepository>();
        final List<PantryItem> items = await repo.getItems(userId: user.id);

        final bool? ok = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext ctx) => GetSuggestionsDialogWidget(
            items: items,
            onConfirm: (Map<String, String> data) {
              if (_recipesCubit == null) return;
              final List<String> selected = data['ingredients']!
                  .split(',')
                  .where((String s) => s.trim().isNotEmpty)
                  .toList();
              _recipesCubit!.loadWithSelection(
                user.id,
                selected,
                data['meal']!,
              );
            },
          ),
        );
        if (ok == false && context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: <Widget>[
        SafeArea(
          child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => Center(
              child: CustomLoadingIndicator(
                type: LoadingType.pulsingGrid,
                size: 50,
              ),
            ),
            error: (_) => const EmptyState(messageKey: 'recipes_empty_message'),
            unauthenticated: () =>
                const EmptyState(messageKey: 'recipes_empty_message'),
            authenticated: (domain.User user) {
              _activeUserId = user.id;
              return BlocProvider<RecipesCubit>(
                create: (BuildContext _) =>
                    sl<RecipesCubit>()..loadFromCache(user.id),
                child: Builder(
                  builder: (BuildContext inner) {
                    _recipesCubit = inner.read<RecipesCubit>();
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: BlocBuilder<RecipesCubit, RecipesState>(
                            builder: (BuildContext context, RecipesState s) {
                              if (s is RecipesInitial) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const EmptyState(
                                      messageKey: 'recipes_empty_message',
                                      lottieUrl:
                                          'https://lottie.host/ed22b2c2-1b8c-4dde-8aa2-cb1b5d7f8f63/lottie.json',
                                    ),
                                    SizedBox(height: AppSizes.verticalSpacingM),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: AppSizes.spacingM,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: () => context
                                              .read<RecipesCubit>()
                                              .load(user.id),
                                          child: Text(tr('get_suggestions')),
                                        ),
                                        OutlinedButton(
                                          onPressed: () async {
                                            final TextEditingController c =
                                                TextEditingController();
                                            final bool?
                                            ok = await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext ctx) =>
                                                  AlertDialog(
                                                    title: Text(
                                                      tr('get_suggestions'),
                                                    ),
                                                    content: TextField(
                                                      controller: c,
                                                      decoration: InputDecoration(
                                                        hintText: tr(
                                                          'enter_ingredients',
                                                        ),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              false,
                                                            ),
                                                        child: Text(
                                                          tr('cancel'),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              true,
                                                            ),
                                                        child: Text(tr('ok')),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (ok == true) {
                                              // ignore: use_build_context_synchronously
                                              await context
                                                  .read<RecipesCubit>()
                                                  .loadFromText(c.text);
                                            }
                                          },
                                          child: Text(tr('enter_ingredients')),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              if (s is RecipesLoading) {
                                return Center(
                                  child: CustomLoadingIndicator(
                                    type: LoadingType.fadingCircle,
                                    size: 50,
                                  ),
                                );
                              }
                              if (s is RecipesFailure) {
                                return const EmptyState(
                                  messageKey: 'recipes_empty_message',
                                );
                              }
                              final RecipesLoaded loaded = s as RecipesLoaded;
                              final bool loadingMore = loaded.isLoadingMore;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  FavoritesShelfWidget(
                                    favoritesFuture: _favoritesFuture,
                                    onRecipeTap: (Recipe recipe) =>
                                        _openRecipeDetail(
                                          context,
                                          recipe,
                                        ),
                                  ),
                                  Expanded(
                                    child: MasonryGridView.count(
                                      controller: _scrollController,
                                      crossAxisCount: 2,
                                      mainAxisSpacing:
                                          AppSizes.verticalSpacingS,
                                      crossAxisSpacing: AppSizes.spacingS,
                                      itemCount:
                                          loaded.recipes.length +
                                          (loadingMore ? 2 : 0),
                                      itemBuilder: (_, int i) {
                                        if (i < loaded.recipes.length) {
                                          final Recipe recipe =
                                              loaded.recipes[i];
                                          return AnimatedRecipeCard(
                                            recipe: recipe,
                                            index: i,
                                            onTap: () => _openRecipeDetail(
                                              context,
                                              recipe,
                                            ),
                                          );
                                        }
                                        return const ShimmerCardWidget();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
          ),
        ),
        // Sağ üstte filter butonu
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSizes.spacingS,
          right: AppSizes.spacingM,
          child: BlocBuilder<RecipesCubit, RecipesState>(
            builder: (BuildContext context, RecipesState state) {
              final int filterCount = state is RecipesLoaded
                  ? state.activeFilterCount
                  : 0;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: tr('filter'),
                    onPressed: () => _showFilterDialog(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                    ),
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.spacingXS * 0.5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: AppSizes.iconXS * 1.2,
                          minHeight: AppSizes.iconXS * 1.2,
                        ),
                        child: Center(
                          child: Text(
                            '$filterCount',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: AppSizes.textXS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ),
    floatingActionButton: ValueListenableBuilder<double>(
      valueListenable: _scrollOffsetNotifier,
      builder: (BuildContext context, double scrollOffset, Widget? child) {
        // Scroll offset'e göre buton boyutunu artır
        final double scale = 1.0 + (scrollOffset / 200.0).clamp(0.0, 0.2);
        return Transform.scale(
          scale: scale,
          child:
              FloatingActionButton.extended(
                    onPressed: () {
                      // _recipesCubit zaten state'te tutuluyor, direkt kullan
                      if (_recipesCubit != null && _activeUserId != null) {
                        _showGetSuggestionsDialog(context);
                      }
                    },
                    icon: const Icon(Icons.lightbulb),
                    label: Text(tr('get_suggestions')),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  ),
        );
      },
    ),
  );

  void _onScroll() {
    final RecipesCubit? cubit = _recipesCubit;
    final String? userId = _activeUserId;
    if (cubit == null || userId == null) return;
    final RecipesState s = cubit.state;
    if (s is! RecipesLoaded) return;
    if (s.isLoadingMore) return;
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      cubit.loadMoreFromPantry(userId);
    }
  }

  void _openRecipeDetail(BuildContext context, Recipe recipe) {
    Navigator.of(context).pushNamed(AppRouter.recipeDetail, arguments: recipe);
  }
}
