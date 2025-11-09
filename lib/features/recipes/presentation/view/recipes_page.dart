import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // FloatingActionButton yorum satırına alındı
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/features/recipes/data/services/recipes_page_data_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/utils/meal_time_order_helper.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_row_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';

/// Recipes page - Shows available recipes
class RecipesPage extends StatefulWidget {
  /// Recipes page constructor
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  RecipesCubit? _recipesCubit;
  RecipesPageDataService? _dataService;
  String? _activeUserId;
  late Future<Box<dynamic>> _favoritesFuture;
  late Future<Box<dynamic>> _userRecipesFuture;
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier<double>(
    0.0,
  );
  Timer? _scrollThrottle;
  Timer? _searchDebounce;

  // Data holders
  List<Recipe> _favorites = <Recipe>[];
  List<Recipe> _breakfastRecipes = <Recipe>[];
  List<Recipe> _snackRecipes = <Recipe>[];
  List<Recipe> _lunchRecipes = <Recipe>[];
  List<Recipe> _dinnerRecipes = <Recipe>[];
  List<Recipe> _madeRecipes = <Recipe>[];

  // Loading states - her meal için ayrı
  final Map<String, bool> _loadingStates = <String, bool>{
    'breakfast': false,
    'snack': false,
    'lunch': false,
    'dinner': false,
    'favorites': false,
    'made': false,
  };

  StreamSubscription<PantryState>? _pantrySubscription;
  VoidCallback? _favoritesListener;
  VoidCallback? _madeRecipesListener;
  Timer? _pantryDebounceTimer;
  Timer? _madeRecipesDebounceTimer;
  DateTime? _lastPantryUpdate;
  DateTime? _lastMadeRecipesUpdate;
  bool _isLoadingRecipes = false;
  bool _hasLoadedInitialData = false; // İlk yükleme kontrolü
  bool _madeRecipesListenerAdded = false; // Listener'ın bir kez eklenmesi için
  String? _lastUserRecipesHash; // user_recipes değişiklik kontrolü için
  final Map<String, bool> _isLoadingMeal =
      <String, bool>{}; // Her meal için loading kontrolü

  @override
  void initState() {
    super.initState();
    _favoritesFuture = Hive.isBoxOpen('favorite_recipes')
        ? Future<Box<dynamic>>.value(Hive.box<dynamic>('favorite_recipes'))
        : Hive.openBox<dynamic>('favorite_recipes');
    _userRecipesFuture = Hive.isBoxOpen('profile_box')
        ? Future<Box<dynamic>>.value(Hive.box<dynamic>('profile_box'))
        : Hive.openBox<dynamic>('profile_box');
    _scrollController.addListener(_onScrollChanged);
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

  Future<void> _loadAllData() async {
    if (_activeUserId == null ||
        _recipesCubit == null ||
        _dataService == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      // Favoriler
      if (mounted) {
        setState(() => _loadingStates['favorites'] = true);
      }
      _favorites = await _dataService!.loadFavorites();
      if (mounted) {
        setState(() => _loadingStates['favorites'] = false);
      }

      // Öğün bazlı tarifler - saat sıralamasına göre - her meal için ayrı istek
      final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();

      // Her meal için paralel olarak yükle (cache kontrolü içinde)
      final List<Future<void>> mealLoadFutures = orderedMeals.map((
        String meal,
      ) async {
        // Eğer bu meal zaten yükleniyorsa atla
        if (_isLoadingMeal[meal] == true) {
          debugPrint('[RecipesPage] Meal zaten yükleniyor, atlanıyor: $meal');
          return;
        }

        if (mounted) {
          setState(() {
            _loadingStates[meal] = true;
            _isLoadingMeal[meal] = true;
          });
        }

        try {
          final List<Recipe> mealRecipes = await _dataService!.loadMealRecipes(
            _activeUserId!,
            meal,
          );

          if (!mounted) {
            return;
          }

          switch (meal) {
            case 'breakfast':
              _breakfastRecipes = mealRecipes;
              break;
            case 'snack':
              _snackRecipes = mealRecipes;
              break;
            case 'lunch':
              _lunchRecipes = mealRecipes;
              break;
            case 'dinner':
              _dinnerRecipes = mealRecipes;
              break;
          }
        } finally {
          if (mounted) {
            setState(() {
              _loadingStates[meal] = false;
              _isLoadingMeal[meal] = false;
            });
          }
        }
      }).toList();

      // Tüm meal'leri paralel yükle
      await Future.wait(mealLoadFutures);

      // Yaptıkların
      if (mounted) {
        setState(() => _loadingStates['made'] = true);
      }
      _madeRecipes = await _dataService!.loadMadeRecipes();
      if (mounted) {
        setState(() => _loadingStates['made'] = false);
      }
    } on Exception catch (e) {
      debugPrint('Error loading data: $e');
      // Hata durumunda tüm loading state'lerini false yap
      if (mounted) {
        setState(() {
          _loadingStates.forEach((String key, bool value) {
            _loadingStates[key] = false;
          });
        });
      }
    }
  }

  void _onScrollChanged() {
    // Throttle scroll updates to prevent too frequent rebuilds
    _scrollThrottle?.cancel();
    _scrollThrottle = Timer(const Duration(milliseconds: 32), () {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
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
    _searchDebounce?.cancel();
    _pantryDebounceTimer?.cancel();
    _madeRecipesDebounceTimer?.cancel();
    _pantrySubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    // Favoriler listener'ı kaldır
    _favoritesFuture.then((Box<dynamic> box) {
      if (_favoritesListener != null) {
        box.listenable().removeListener(_favoritesListener!);
      }
    });
    // Yaptıklarım listener'ı kaldır
    _userRecipesFuture.then((Box<dynamic> box) {
      if (_madeRecipesListener != null) {
        box.listenable().removeListener(_madeRecipesListener!);
      }
    });
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  // FloatingActionButton yorum satırına alındı - otomatik öneriler aktif
  // Future<void> _showGetSuggestionsDialog(BuildContext context) async {
  //   if (!context.mounted) {
  //     return;
  //   }
  //   final BuildContext authContext = context;
  //   final AuthState st = authContext.read<AuthCubit>().state;
  //   await st.whenOrNull(
  //     authenticated: (domain.User user) async {
  //       final IPantryRepository repo = sl<IPantryRepository>();
  //       final List<PantryItem> items = await repo.getItems(userId: user.id);
  //
  //       if (!authContext.mounted) {
  //         return;
  //       }
  //       final BuildContext dialogContext = authContext;
  //       final bool? ok = await showDialog<bool>(
  //         context: dialogContext,
  //         builder: (BuildContext ctx) => GetSuggestionsDialogWidget(
  //           items: items,
  //           onConfirm: (Map<String, String> data) {
  //             if (_recipesCubit == null) {
  //               return;
  //             }
  //             final List<String> selected = data['ingredients']!
  //                 .split(',')
  //                 .where((String s) => s.trim().isNotEmpty)
  //                 .toList();
  //             _recipesCubit!.loadWithSelection(
  //               user.id,
  //               selected,
  //               data['meal']!,
  //             );
  //           },
  //         ),
  //       );
  //       if (ok == false && dialogContext.mounted) {
  //         Navigator.pop(dialogContext);
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(
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
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<RecipesCubit>(
                create: (BuildContext _) => sl<RecipesCubit>(),
              ),
              BlocProvider<PantryCubit>(
                create: (BuildContext _) => sl<PantryCubit>()..watch(user.id),
              ),
            ],
            child: Builder(
              builder: (BuildContext inner) {
                _recipesCubit = inner.read<RecipesCubit>();
                _dataService = RecipesPageDataService(
                  recipesCubit: _recipesCubit!,
                );
                final PantryCubit pantryCubit = inner.read<PantryCubit>();

                // Favoriler değişikliklerini dinle - anlık güncelleme
                _favoritesListener = () {
                  if (mounted) {
                    _loadFavorites();
                  }
                };
                _favoritesFuture.then((Box<dynamic> box) {
                  if (mounted) {
                    box.listenable().addListener(_favoritesListener!);
                  }
                });

                // Yaptıklarım değişikliklerini dinle - debounce ile (sadece bir kez ekle)
                if (!_madeRecipesListenerAdded) {
                _madeRecipesListener = () {
                  debugPrint(
                      '[RecipesPage] profile_box değişti, yaptıklarım kontrol ediliyor...',
                    );
                    if (!mounted) {
                      return;
                    }
                    
                    // Sadece user_recipes key'i değiştiyse işlem yap
                    _userRecipesFuture.then((Box<dynamic> box) {
                      if (!mounted) {
                        return;
                      }
                      
                      final List<dynamic>? currentRecipes = 
                          box.get('user_recipes') as List<dynamic>?;
                      final String currentHash = 
                          currentRecipes?.toString() ?? '';
                      
                      // Eğer aynıysa, işlem yapma
                      if (_lastUserRecipesHash == currentHash) {
                        debugPrint(
                          '[RecipesPage] user_recipes değişmedi, atlanıyor',
                        );
                        return;
                      }
                      
                      _lastUserRecipesHash = currentHash;
                      
                      // Debounce: Son 2 saniye içinde güncelleme varsa bekle
                      final DateTime now = DateTime.now();
                      _madeRecipesDebounceTimer?.cancel();

                      if (_lastMadeRecipesUpdate != null &&
                          now.difference(_lastMadeRecipesUpdate!).inSeconds < 2) {
                        _madeRecipesDebounceTimer = Timer(
                          const Duration(seconds: 2),
                          () {
                            if (mounted) {
                              _loadMadeRecipes();
                            }
                          },
                        );
                        return;
                      }

                      _lastMadeRecipesUpdate = now;
                  if (mounted) {
                    _loadMadeRecipes();
                  }
                    });
                };
                _userRecipesFuture.then((Box<dynamic> box) {
                    if (mounted && !_madeRecipesListenerAdded) {
                    box.listenable().addListener(_madeRecipesListener!);
                      _madeRecipesListenerAdded = true;
                      
                      // İlk hash'i kaydet
                      final List<dynamic>? initialRecipes = 
                          box.get('user_recipes') as List<dynamic>?;
                      _lastUserRecipesHash = initialRecipes?.toString() ?? '';
                      
                    debugPrint('[RecipesPage] profile_box listener eklendi');
                  }
                });
                }

                // Pantry değişikliklerini dinle - debounce ile
                _pantrySubscription?.cancel();
                _pantrySubscription = pantryCubit.stream.listen((
                  PantryState pantryState,
                ) {
                  if (pantryState is PantryLoaded &&
                      pantryState.items.isNotEmpty) {
                    // Debounce: Son 3 saniye içinde güncelleme varsa bekle
                    final DateTime now = DateTime.now();
                    _pantryDebounceTimer?.cancel();

                    if (_lastPantryUpdate != null &&
                        now.difference(_lastPantryUpdate!).inSeconds < 3) {
                      _pantryDebounceTimer = Timer(
                        const Duration(seconds: 3),
                        () {
                          if (mounted) {
                            _handlePantryUpdate();
                          }
                        },
                      );
                      return;
                    }

                    _lastPantryUpdate = now;
                    if (mounted) {
                      _handlePantryUpdate();
                    }
                  }
                });

                // İlk yüklemede verileri çek - build sonrası
                final bool hasAnyData =
                    _favorites.isNotEmpty ||
                    _breakfastRecipes.isNotEmpty ||
                    _snackRecipes.isNotEmpty ||
                    _lunchRecipes.isNotEmpty ||
                    _dinnerRecipes.isNotEmpty ||
                    _madeRecipes.isNotEmpty;

                if (!hasAnyData && !_hasLoadedInitialData) {
                  _hasLoadedInitialData = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadAllData();
                      // Yaptıklarım için de listener ekle
                      _loadMadeRecipes();
                    }
                  });
                }

                // RecipesCubit stream listener kaldırıldı
                // - sonsuz döngüyü önlemek için
                // loadMeal içinde emit edilmediği için stream listener'a gerek yok
                // UI güncellemesi _loadAllData tarafından yapılıyor

                return SafeArea(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _searchQuery,
                    builder: (
                      BuildContext context,
                      String query,
                      Widget? child,
                    ) {
                      if (query.isNotEmpty) {
                        // Arama modu
                        final List<Recipe> allRecipes = _getAllRecipes();
                        final List<Recipe> filteredRecipes =
                            _filterRecipes(allRecipes, query);
                        return Column(
                          children: <Widget>[
                            // Search bar
                            Padding(
                              padding: EdgeInsets.all(AppSizes.padding),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radius * 2,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.05),
                                      blurRadius: AppSizes.spacingS,
                                      offset: Offset(0, AppSizes.spacingS),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(
                                    fontSize: AppSizes.text,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: tr('search'),
                                    hintStyle: TextStyle(
                                      fontSize: AppSizes.text,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    suffixIcon: query.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear_rounded,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _searchQuery.value = '';
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.spacingM,
                                      vertical: AppSizes.spacingM + 2,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            // Search results
                            Expanded(
                              child: filteredRecipes.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.search_off,
                                            size: AppSizes.iconXXL * 1.5,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          SizedBox(
                                            height: AppSizes.verticalSpacingM,
                                          ),
                                          Text(
                                            tr('no_items_found'),
                                            style: TextStyle(
                                              fontSize: AppSizes.textM,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.all(AppSizes.padding),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSizes.spacingS,
                                        mainAxisSpacing: AppSizes.spacingS,
                                        childAspectRatio: 0.75,
                                      ),
                                      itemCount: filteredRecipes.length,
                                      itemBuilder: (
                                        BuildContext context,
                                        int index,
                                      ) {
                                        final Recipe recipe =
                                            filteredRecipes[index];
                                        return _buildSearchResultCard(
                                          context,
                                          recipe,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }
                      // Normal mod - kategori listeleri
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: <Widget>[
                          // Search bar
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.padding),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radius * 2,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.05),
                                      blurRadius: AppSizes.spacingS,
                                      offset: Offset(0, AppSizes.spacingS),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(
                                    fontSize: AppSizes.text,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: tr('search'),
                                    hintStyle: TextStyle(
                                      fontSize: AppSizes.text,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.spacingM,
                                      vertical: AppSizes.spacingM + 2,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Recipe rows
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.padding,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                <Widget>[
                                  // 1. Row: Favoriler
                                  RecipeRowWidget(
                                    title: tr('recipes_favorites_title'),
                                    recipes: _favorites,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.3),
                                    icon: Icons.favorite,
                                    isLoading:
                                        _loadingStates['favorites'] ?? false,
                                    onRecipeTap: (Recipe recipe) =>
                                        _openRecipeDetail(context, recipe),
                                    onViewAll: () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.favorites),
                                  ),

                                  // 2-5. Rows: Öğünler (saat sıralamasına göre)
                                  ..._buildMealRows(context),

                                  // 6. Row: Yaptıkların
                                  RecipeRowWidget(
                                    title: tr('made_recipes'),
                                    recipes: _madeRecipes,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer
                                        .withValues(alpha: 0.3),
                                    icon: Icons.check_circle_outline,
                                    isLoading:
                                        _loadingStates['made'] ?? false,
                                    onRecipeTap: (Recipe recipe) =>
                                        _openRecipeDetail(context, recipe),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
    // FloatingActionButton yorum satırına alındı - otomatik öneriler aktif
    // floatingActionButton: ValueListenableBuilder<double>(
    //   valueListenable: _scrollOffsetNotifier,
    //   builder: (BuildContext context, double scrollOffset, Widget? child) {
    //     final double scale = 1.0 + (scrollOffset / 200.0).clamp(0.0, 0.2);
    //     return Transform.scale(
    //       scale: scale,
    //       child: FloatingActionButton.extended(
    //                 onPressed: () {
    //                   if (_recipesCubit != null && _activeUserId != null) {
    //                     _showGetSuggestionsDialog(context);
    //                   }
    //                 },
    //                 icon: const Icon(Icons.lightbulb),
    //                 label: Text(tr('get_suggestions')),
    //               )
    //               .animate()
    //               .scale(
    //                 begin: const Offset(0.8, 0.8),
    //                 end: const Offset(1, 1),
    //                 duration: 500.ms,
    //                 delay: 200.ms,
    //                 curve: Curves.easeOutBack,
    //               )
    //               .fadeIn(
    //                 duration: 500.ms,
    //                 delay: 200.ms,
    //                 curve: Curves.easeOut,
    //               ),
    //     );
    //   },
    // ),
  );

  List<Widget> _buildMealRows(BuildContext context) {
    final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
    final List<Widget> rows = <Widget>[];

    for (final String meal in orderedMeals) {
      List<Recipe> recipes;
      switch (meal) {
        case 'breakfast':
          recipes = _breakfastRecipes;
          break;
        case 'snack':
          recipes = _snackRecipes;
          break;
        case 'lunch':
          recipes = _lunchRecipes;
          break;
        case 'dinner':
          recipes = _dinnerRecipes;
          break;
        default:
          recipes = <Recipe>[];
      }

      rows.add(
        RecipeRowWidget(
          title:
              '${tr('you_can_make')} - '
              '${MealTimeOrderHelper.getMealName(meal)}',
          recipes: recipes,
          backgroundColor: MealTimeOrderHelper.getMealColor(meal),
          icon: MealTimeOrderHelper.getMealIcon(meal),
          isLoading: _loadingStates[meal] ?? false,
          onRecipeTap: (Recipe recipe) => _openRecipeDetail(context, recipe),
          onViewAll: _activeUserId != null
              ? () => Navigator.of(context).pushNamed(
                  '/recipes/meal',
                  arguments: <String, dynamic>{
                    'meal': meal,
                    'userId': _activeUserId!,
                  },
                )
              : null,
        ),
      );
    }

    return rows;
  }

  Future<void> _loadFavorites() async {
    if (!mounted || _dataService == null) {
      return;
    }
    try {
      final List<Recipe> favorites = await _dataService!.loadFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
        });
      }
    } on Exception catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _loadMadeRecipes() async {
    if (!mounted || _dataService == null) {
      return;
    }
    debugPrint('[RecipesPage] _loadMadeRecipes çağrıldı');
    try {
      final List<Recipe> madeRecipes = await _dataService!.loadMadeRecipes();
      debugPrint(
        '[RecipesPage] ${madeRecipes.length} yaptıklarım tarifi yüklendi',
      );
      if (mounted) {
        setState(() {
          _madeRecipes = madeRecipes;
        });
      }
    } on Exception catch (e) {
      debugPrint('[RecipesPage] Error loading made recipes: $e');
    }
  }

  void _handlePantryUpdate() {
    if (!mounted ||
        _recipesCubit == null ||
        _activeUserId == null ||
        _isLoadingRecipes) {
      return;
    }

    debugPrint('[RecipesPage] Pantry değişti, öneriler güncelleniyor...');
    _isLoadingRecipes = true;
    _recipesCubit!
        .load(_activeUserId!)
        .then((_) {
          _isLoadingRecipes = false;
          // UI güncellemesi RecipesCubit stream listener tarafından yapılacak
        })
        .catchError((Object error) {
          _isLoadingRecipes = false;
          debugPrint('[RecipesPage] Pantry güncelleme hatası: $error');
        });
  }

  Future<void> _openRecipeDetail(BuildContext context, Recipe recipe) async {
    final bool? recipeMade = await Navigator.of(
      context,
    ).pushNamed<bool>(AppRouter.recipeDetail, arguments: recipe);
    // Eğer tarif yapıldı olarak işaretlendiyse yaptıklarım listesini güncelle
    if (recipeMade == true && mounted) {
      await _loadMadeRecipes();
    }
  }

  /// Get all recipes from all sources (favorites, meals, made)
  List<Recipe> _getAllRecipes() {
    final List<Recipe> allRecipes = <Recipe>[
      ..._favorites,
      ..._breakfastRecipes,
      ..._snackRecipes,
      ..._lunchRecipes,
      ..._dinnerRecipes,
      ..._madeRecipes,
    ];

    // Duplicate kontrolü - aynı başlıklı tarifleri kaldır
    final Map<String, Recipe> uniqueRecipes = <String, Recipe>{};
    for (final Recipe recipe in allRecipes) {
      if (!uniqueRecipes.containsKey(recipe.title)) {
        uniqueRecipes[recipe.title] = recipe;
      }
    }

    return uniqueRecipes.values.toList();
  }

  /// Filter recipes by search query (title and ingredients)
  List<Recipe> _filterRecipes(List<Recipe> recipes, String query) {
    if (query.isEmpty) {
      return recipes;
    }

    final String lowerQuery = query.toLowerCase();
    return recipes.where((Recipe recipe) {
      // Tarif isminde ara
      final bool matchesTitle = recipe.title.toLowerCase().contains(lowerQuery);

      // Malzemelerde ara
      final bool matchesIngredients = recipe.ingredients.any(
        (String ingredient) => ingredient.toLowerCase().contains(lowerQuery),
      );

      return matchesTitle || matchesIngredients;
    }).toList();
  }

  /// Build search result card widget
  Widget _buildSearchResultCard(BuildContext context, Recipe recipe) {
    return CompactRecipeCardWidget(
      recipe: recipe,
      onTap: () => _openRecipeDetail(context, recipe),
    );
  }
}
