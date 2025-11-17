// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';

/// Category color utility for pantry items
class CategoryColors {
  CategoryColors._();

  /// Get color for a category
  static Color getCategoryColor(String category) {
    final String normalized = PantryCategoryHelper.normalize(category);
    switch (normalized) {
      case 'dairy':
        return const Color(0xFFE3F2FD);
      case 'vegetables':
        return const Color(0xFFE8F5E9);
      case 'fruits':
        return const Color(0xFFFFF3E0);
      case 'meat':
        return const Color(0xFFFFEBEE);
      case 'legumes':
      case 'nuts':
        return const Color(0xFFEFEBE9);
      case 'grains':
        return const Color(0xFFFFF9C4);
      case 'spices':
        return const Color(0xFFFFE0B2);
      case 'snacks':
        return const Color(0xFFFCE4EC);
      case 'drinks':
        return const Color(0xFFE1F5FE);
      case 'frozen':
        return const Color(0xFFE0F7FA);
      case 'other':
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Get icon color for a category
  static Color getCategoryIconColor(String category) {
    final String normalized = PantryCategoryHelper.normalize(category);
    switch (normalized) {
      case 'dairy':
        return const Color(0xFF1976D2);
      case 'vegetables':
        return const Color(0xFF388E3C);
      case 'fruits':
        return const Color(0xFFF57C00);
      case 'meat':
        return const Color(0xFFD32F2F);
      case 'legumes':
      case 'nuts':
        return const Color(0xFF6D4C41);
      case 'grains':
        return const Color(0xFFF9A825);
      case 'spices':
        return const Color(0xFFE64A19);
      case 'snacks':
        return const Color(0xFFC2185B);
      case 'drinks':
        return const Color(0xFF0288D1);
      case 'frozen':
        return const Color(0xFF006064);
      case 'other':
      default:
        return const Color(0xFF757575);
    }
  }

  /// Get badge color for category chip
  static Color getCategoryBadgeColor(String category) =>
      getCategoryColor(category);

  /// Get badge text color for category chip
  static Color getCategoryBadgeTextColor(String category) =>
      getCategoryIconColor(category);
}
