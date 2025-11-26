// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';

class RecipeSuggestion {
  const RecipeSuggestion({
    required this.title,
    required this.ingredients,
    required this.steps,
    this.calories,
    this.durationMinutes,
    this.difficulty,
    this.imageUrl,
    this.category,
    this.fiber,
    this.imageSearchQuery,
  });

  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final int? calories;
  final int? durationMinutes;
  final String? difficulty;
  final String? imageUrl;
  final String? category; // kahvaltı/öğle/akşam/ara öğün vb.
  final int? fiber;
  final String? imageSearchQuery; // English search query for image APIs (Pexels/Unsplash)
}

abstract class IOpenAIService {
  Future<List<Ingredient>> parseFridgeImage(
    Uint8List imageBytes, {
    CancelToken? cancelToken,
    String? userId,
  });

  Future<List<RecipeSuggestion>> suggestRecipes(
    List<Ingredient> pantry, {
    int servings = 2,
    int count = 6,
    String? query,
    List<String>? excludeTitles,
    CancelToken? cancelToken,
    String? userId,
  });

  Future<String> categorizeItem(
    String itemName, {
    CancelToken? cancelToken,
    String? userId,
  });
}
