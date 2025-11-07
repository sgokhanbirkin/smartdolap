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
      case 'Süt Ürünleri':
        return const Color(0xFFE3F2FD);
      case 'Sebze':
        return const Color(0xFFE8F5E9);
      case 'Meyve':
        return const Color(0xFFFFF3E0);
      case 'Et / Tavuk / Balık':
        return const Color(0xFFFFEBEE);
      case 'Bakliyat':
      case 'Baklagil & Tohum':
        return const Color(0xFFEFEBE9);
      case 'Tahıl & Fırın':
        return const Color(0xFFFFF9C4);
      case 'Baharat & Sos':
        return const Color(0xFFFFE0B2);
      case 'Atıştırmalık':
        return const Color(0xFFFCE4EC);
      case 'İçecek':
        return const Color(0xFFE1F5FE);
      case 'Dondurulmuş':
        return const Color(0xFFE0F7FA);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Get icon color for a category
  static Color getCategoryIconColor(String category) {
    final String normalized = PantryCategoryHelper.normalize(category);
    switch (normalized) {
      case 'Süt Ürünleri':
        return const Color(0xFF1976D2);
      case 'Sebze':
        return const Color(0xFF388E3C);
      case 'Meyve':
        return const Color(0xFFF57C00);
      case 'Et / Tavuk / Balık':
        return const Color(0xFFD32F2F);
      case 'Bakliyat':
      case 'Baklagil & Tohum':
        return const Color(0xFF6D4C41);
      case 'Tahıl & Fırın':
        return const Color(0xFFF9A825);
      case 'Baharat & Sos':
        return const Color(0xFFE64A19);
      case 'Atıştırmalık':
        return const Color(0xFFC2185B);
      case 'İçecek':
        return const Color(0xFF0288D1);
      case 'Dondurulmuş':
        return const Color(0xFF006064);
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
