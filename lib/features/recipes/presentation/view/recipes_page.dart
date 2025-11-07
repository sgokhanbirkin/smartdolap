// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/recipe_card.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('recipes_title'),
        style: TextStyle(fontSize: AppSizes.textL),
      ),
      automaticallyImplyLeading: false,
      elevation: AppSizes.appBarElevation,
      toolbarHeight: AppSizes.appBarHeight,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            final AuthState st = context.read<AuthCubit>().state;
            await st.whenOrNull(
              authenticated: (domain.User user) async {
                final repo = sl<IPantryRepository>();
                final items = await repo.getItems(userId: user.id);
                final Set<String> inc = <String>{};
                String? meal;
                int? maxCal;
                int? minFiber;
                // ignore: use_build_context_synchronously
                final bool? ok = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    title: Text(tr('recipes_title')),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(tr('select_ingredients')),
                          Wrap(
                            spacing: AppSizes.spacingS,
                            children: items
                                .map<Widget>(
                                  (dynamic e) => FilterChip(
                                    label: Text(e.name as String),
                                    selected: inc.contains(e.name as String),
                                    onSelected: (bool v) {
                                      if (v) {
                                        inc.add(e.name as String);
                                      } else {
                                        inc.remove(e.name as String);
                                      }
                                      (ctx as Element).markNeedsBuild();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(height: AppSizes.verticalSpacingM),
                          DropdownButton<String>(
                            hint: Text(tr('meal')),
                            isExpanded: true,
                            value: meal,
                            items:
                                <String>[
                                      tr('breakfast'),
                                      tr('lunch'),
                                      tr('dinner'),
                                      tr('snack'),
                                    ]
                                    .map(
                                      (String m) => DropdownMenuItem<String>(
                                        value: m,
                                        child: Text(m),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (String? v) {
                              meal = v;
                              (ctx as Element).markNeedsBuild();
                            },
                          ),
                          SizedBox(height: AppSizes.verticalSpacingM),
                          Text('Max Kalori'),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (String v) => maxCal = int.tryParse(v),
                            decoration: const InputDecoration(
                              hintText: 'örn. 700',
                            ),
                          ),
                          SizedBox(height: AppSizes.verticalSpacingM),
                          Text('Min Lif (g)'),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (String v) => minFiber = int.tryParse(v),
                            decoration: const InputDecoration(
                              hintText: 'örn. 5',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(tr('cancel')),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(tr('confirm')),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                if (ok == true) {
                  final RecipesState s = context.read<RecipesCubit>().state;
                  if (s is RecipesLoaded) {
                    final filtered = s.recipes.where((r) {
                      final ingOk =
                          inc.isEmpty ||
                          inc.every(
                            (name) => r.ingredients
                                .map((e) => e.toLowerCase())
                                .contains(name.toLowerCase()),
                          );
                      final mealOk =
                          meal == null ||
                          (r.category ?? '').toLowerCase() ==
                              meal!.toLowerCase();
                      final calOk =
                          maxCal == null || (r.calories ?? 0) <= maxCal!;
                      final fiberOk =
                          minFiber == null || (r.fiber ?? 0) >= minFiber!;
                      return ingOk && mealOk && calOk && fiberOk;
                    }).toList();
                    context.read<RecipesCubit>().applyFilter(filtered);
                  }
                }
              },
            );
          },
        ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_) => EmptyState(messageKey: 'recipes_empty_message'),
            unauthenticated: () =>
                EmptyState(messageKey: 'recipes_empty_message'),
            authenticated: (domain.User user) {
              _activeUserId = user.id;
              return BlocProvider<RecipesCubit>(
                create: (BuildContext _) =>
                    sl<RecipesCubit>()..loadFromCache(user.id),
                child: Builder(
                  builder: (BuildContext inner) {
                    _recipesCubit = inner.read<RecipesCubit>();
                    return BlocBuilder<RecipesCubit, RecipesState>(
                      builder: (BuildContext context, RecipesState s) {
                        if (s is RecipesInitial) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              EmptyState(
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
                                      final bool? ok = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext ctx) => AlertDialog(
                                          title: Text(tr('get_suggestions')),
                                          content: TextField(
                                            controller: c,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'tomato, egg, cheese (comma separated)',
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(tr('cancel')),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        // ignore: use_build_context_synchronously
                                        context
                                            .read<RecipesCubit>()
                                            .loadFromText(c.text);
                                      }
                                    },
                                    child: const Text('Enter Ingredients'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        if (s is RecipesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (s is RecipesFailure) {
                          return EmptyState(
                            messageKey: 'recipes_empty_message',
                          );
                        }
                        final RecipesLoaded loaded = s as RecipesLoaded;
                        return Stack(
                          children: <Widget>[
                            MasonryGridView.count(
                              controller: _scrollController
                                ..removeListener(_onScroll)
                                ..addListener(_onScroll),
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSizes.verticalSpacingS,
                              crossAxisSpacing: AppSizes.spacingS,
                              itemCount:
                                  loaded.recipes.length +
                                  (context.read<RecipesCubit>().isFetchingMore
                                      ? 2
                                      : 0),
                              itemBuilder: (_, int i) {
                                if (i < loaded.recipes.length) {
                                  final Recipe recipe = loaded.recipes[i];
                                  return RecipeCard(
                                    recipe: recipe,
                                    onTap: () =>
                                        _openRecipeDetail(context, recipe),
                                  );
                                }
                                return _placeholderCard(context);
                              },
                            ),
                            Positioned(
                              right: AppSizes.spacingL,
                              bottom: AppSizes.verticalSpacingL,
                              child: FloatingActionButton.extended(
                                onPressed: () async {
                                  final AuthState st = context
                                      .read<AuthCubit>()
                                      .state;
                                  st.whenOrNull(
                                    authenticated: (domain.User user) async {
                                      final repo = sl<IPantryRepository>();
                                      final items = await repo.getItems(
                                        userId: user.id,
                                      );
                                      final Set<String> selected = items
                                          .map((dynamic e) => e.name as String)
                                          .toSet();
                                      String meal = tr('dinner');
                                      // ignore: use_build_context_synchronously
                                      final bool? ok = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext ctx) => AlertDialog(
                                          title: Text(tr('select_ingredients')),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Wrap(
                                                    spacing: AppSizes.spacingS,
                                                    children: items
                                                        .map<Widget>(
                                                          (
                                                            dynamic e,
                                                          ) => FilterChip(
                                                            label: Text(
                                                              e.name as String,
                                                            ),
                                                            selected: selected
                                                                .contains(
                                                                  e.name
                                                                      as String,
                                                                ),
                                                            onSelected: (bool v) {
                                                              if (v) {
                                                                selected.add(
                                                                  e.name
                                                                      as String,
                                                                );
                                                              } else {
                                                                selected.remove(
                                                                  e.name
                                                                      as String,
                                                                );
                                                              }
                                                              // rebuild sheet
                                                              (ctx as Element)
                                                                  .markNeedsBuild();
                                                            },
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                  SizedBox(
                                                    height: AppSizes
                                                        .verticalSpacingM,
                                                  ),
                                                  Text(tr('meal')),
                                                  DropdownButton<String>(
                                                    value: meal,
                                                    isExpanded: true,
                                                    items:
                                                        <String>[
                                                              tr('breakfast'),
                                                              tr('lunch'),
                                                              tr('dinner'),
                                                              tr('snack'),
                                                            ]
                                                            .map(
                                                              (String m) =>
                                                                  DropdownMenuItem<
                                                                    String
                                                                  >(
                                                                    value: m,
                                                                    child: Text(
                                                                      m,
                                                                    ),
                                                                  ),
                                                            )
                                                            .toList(),
                                                    onChanged: (String? v) {
                                                      meal = v ?? meal;
                                                      (ctx as Element)
                                                          .markNeedsBuild();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(tr('cancel')),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: Text(tr('confirm')),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        // ignore: use_build_context_synchronously
                                        context
                                            .read<RecipesCubit>()
                                            .loadWithSelection(
                                              user.id,
                                              selected.toList(),
                                              meal,
                                            );
                                      }
                                    },
                                  );
                                },
                                label: Text(tr('get_suggestions')),
                                icon: const Icon(Icons.lightbulb),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _placeholderCard(BuildContext context) => Container(
  height: 180,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
  ),
  margin: EdgeInsets.only(bottom: AppSizes.verticalSpacingS),
);

extension on _RecipesPageState {
  void _onScroll() {
    final RecipesCubit? cubit = _recipesCubit;
    final String? userId = _activeUserId;
    if (cubit == null || userId == null) return;
    final RecipesState s = cubit.state;
    if (s is! RecipesLoaded) return;
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      cubit.loadMoreFromPantry(userId);
    }
  }

  void _openRecipeDetail(BuildContext context, Recipe recipe) {
    Navigator.of(context).pushNamed(AppRouter.recipeDetail, arguments: recipe);
  }
}
