// ignore_for_file: public_member_api_docs

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';

/// Service for recipe detail operations - SRP: Single responsibility for recipe detail business logic
class RecipeDetailService {
  /// Constructor
  RecipeDetailService({
    UserRecipeService? userRecipeService,
    IProfileStatsService? profileStatsService,
    IStorageService? storageService,
    IBadgeRepository? badgeRepository,
  }) : _userRecipeService = userRecipeService ?? sl<UserRecipeService>(),
       _profileStatsService = profileStatsService ?? sl<IProfileStatsService>(),
       _storageService = storageService ?? sl<IStorageService>(),
       _badgeRepository = badgeRepository ?? sl<IBadgeRepository>();

  final UserRecipeService _userRecipeService;
  final IProfileStatsService _profileStatsService;
  final IStorageService _storageService;
  final IBadgeRepository _badgeRepository;

  /// Upload recipe photo to Firebase Storage
  Future<String?> uploadRecipePhoto({
    required String userId,
    required String recipeId,
    required Uint8List imageBytes,
  }) async {
    try {
      return await _storageService.uploadRecipePhoto(
        userId: userId,
        recipeId: recipeId,
        imageBytes: imageBytes,
      );
    } on Exception catch (e) {
      debugPrint('[RecipeDetailService] Fotoğraf yükleme hatası: $e');
      rethrow;
    }
  }

  /// Save recipe as made
  /// Handles both AI recommendations and manual recipes
  /// Follows Single Responsibility Principle - only handles recipe marking logic
  Future<RecipeMadeResult> markRecipeAsMade({
    required Recipe recipe,
    String? imageUrl,
  }) async {
    try {
      // Determine if recipe is AI recommendation (recipes from AI typically have Firestore IDs)
      // For MVP, we assume recipes with non-empty IDs are AI recommendations
      final bool isAIRecommendation = recipe.id.isNotEmpty;

      // Convert Recipe to UserRecipe
      await _userRecipeService.createManual(
        title: recipe.title,
        ingredients: recipe.ingredients,
        steps: recipe.stepsAsStrings, // Convert RecipeStep list to String list
        description: recipe.category ?? '',
        tags: <String>[
          if (recipe.category != null) recipe.category!,
          if (recipe.difficulty != null) recipe.difficulty!,
        ],
        imagePath: imageUrl,
        isAIRecommendation: isAIRecommendation,
      );

      // Update stats based on recipe type
      final int xpGained = imageUrl != null ? 75 : 50;

      if (isAIRecommendation) {
        // AI recipe: increment AI recipes counter
        await _profileStatsService.incrementAiRecipes();
      } else {
        // Manual recipe: increment user recipes counter
        await _profileStatsService.incrementUserRecipes(
          withPhoto: imageUrl != null,
        );
      }

      // Add XP
      await _profileStatsService.addXp(xpGained);

      // Check for badges
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final BadgeService badgeService = BadgeService(
          statsService: _profileStatsService,
          badgeRepository: _badgeRepository,
          userId: userId,
        );
        await badgeService.checkAndAwardBadges();
      }

      return RecipeMadeResult(success: true, xpGained: xpGained);
    } on Exception catch (e) {
      debugPrint('[RecipeDetailService] Tarif kaydetme hatası: $e');
      return RecipeMadeResult(success: false, error: e.toString());
    }
  }
}

/// Result of marking recipe as made
class RecipeMadeResult {
  /// Constructor
  const RecipeMadeResult({required this.success, this.xpGained, this.error});

  /// Whether the operation was successful
  final bool success;

  /// XP gained from marking recipe as made
  final int? xpGained;

  /// Error message if operation failed
  final String? error;
}
