// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';

/// Service for recipe detail operations - SRP: Single responsibility for recipe detail business logic
class RecipeDetailService {
  /// Constructor
  RecipeDetailService({
    UserRecipeService? userRecipeService,
    ProfileStatsService? profileStatsService,
    IStorageService? storageService,
    IBadgeRepository? badgeRepository,
  })  : _userRecipeService =
            userRecipeService ?? sl<UserRecipeService>(),
        _profileStatsService =
            profileStatsService ?? sl<ProfileStatsService>(),
        _storageService = storageService ?? sl<IStorageService>(),
        _badgeRepository =
            badgeRepository ?? sl<IBadgeRepository>();

  final UserRecipeService _userRecipeService;
  final ProfileStatsService _profileStatsService;
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
  Future<RecipeMadeResult> markRecipeAsMade({
    required Recipe recipe,
    String? imageUrl,
  }) async {
    try {
      // Convert Recipe to UserRecipe
      await _userRecipeService.createManual(
        title: recipe.title,
        ingredients: recipe.ingredients,
        steps: recipe.steps,
        description: recipe.category ?? '',
        tags: <String>[
          if (recipe.category != null) recipe.category!,
          if (recipe.difficulty != null) recipe.difficulty!,
        ],
        imagePath: imageUrl,
      );

      // Add XP (base 50 XP, +25 if with photo)
      final int xpGained = imageUrl != null ? 75 : 50;
      await _profileStatsService.incrementUserRecipes(
        withPhoto: imageUrl != null,
      );
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

      return RecipeMadeResult(
        success: true,
        xpGained: xpGained,
      );
    } on Exception catch (e) {
      debugPrint('[RecipeDetailService] Tarif kaydetme hatası: $e');
      return RecipeMadeResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Result of marking recipe as made
class RecipeMadeResult {
  /// Constructor
  const RecipeMadeResult({
    required this.success,
    this.xpGained,
    this.error,
  });

  /// Whether the operation was successful
  final bool success;

  /// XP gained from marking recipe as made
  final int? xpGained;

  /// Error message if operation failed
  final String? error;
}

