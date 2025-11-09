import 'package:cloud_firestore/cloud_firestore.dart';

/// Service responsible for building Firestore queries for recipes
/// Follows Single Responsibility Principle - only handles query building
class FirestoreRecipeQueryBuilder {
  /// Build query for recipes collection with optional meal filter
  static Query<Map<String, dynamic>> buildQuery({
    required CollectionReference<Map<String, dynamic>> collection,
    String? meal,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection;

    // Apply meal filter if provided
    if (meal != null && meal.isNotEmpty) {
      query = query.where('category', isEqualTo: meal);
    }

    // Order by creation date (newest first)
    query = query.orderBy('createdAt', descending: true);

    // Apply limit if provided
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query;
  }
}

