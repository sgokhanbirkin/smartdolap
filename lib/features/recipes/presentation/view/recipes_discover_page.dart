// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/recipe_card.dart';

class RecipesDiscoverPage extends StatefulWidget {
  const RecipesDiscoverPage({
    required this.userId,
    required this.query,
    super.key,
  });

  final String userId;
  final String query;

  @override
  State<RecipesDiscoverPage> createState() => _RecipesDiscoverPageState();
}

class _RecipesDiscoverPageState extends State<RecipesDiscoverPage> {
  final ScrollController _ctrl = ScrollController();
  RecipesCubit? _discoverCubit;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_ctrl.position.pixels <= _ctrl.position.maxScrollExtent - 300) {
      return;
    }
    final RecipesCubit? cubit = _discoverCubit;
    if (cubit == null) {
      return;
    }
    cubit.discoverMore(widget.userId, widget.query);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('recipes_title'))),
    body: BlocProvider<RecipesCubit>(
      create: (_) =>
          sl<RecipesCubit>()..discoverInit(widget.userId, widget.query),
      child: BlocBuilder<RecipesCubit, RecipesState>(
        builder: (BuildContext context, RecipesState s) {
          _discoverCubit = context.read<RecipesCubit>();
          if (s is RecipesLoading || s is RecipesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Recipe> recipes = (s as RecipesLoaded).recipes;
          return MasonryGridView.count(
            controller: _ctrl,
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.verticalSpacingS,
            crossAxisSpacing: AppSizes.spacingS,
            itemCount: recipes.length,
            itemBuilder: (_, int i) {
              final Recipe recipe = recipes[i];
              return RecipeCard(
                recipe: recipe,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouter.recipeDetail, arguments: recipe),
              );
            },
          );
        },
      ),
    ),
  );
}
