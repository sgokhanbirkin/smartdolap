// ignore_for_file: public_member_api_docs

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Global image cache manager
/// Configures and manages image cache limits for the entire app
class ImageCacheManager {
  ImageCacheManager._();

  /// Initialize image cache with optimized limits
  /// Should be called once at app startup
  static void initialize() {
    // Configure Flutter's image cache
    PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images in memory
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100 MB

    // Configure CachedNetworkImage default settings
    // These can be overridden per widget if needed
    CachedNetworkImage.logLevel = CacheManagerLogLevel.warning;
  }

  /// Clear image cache (useful for memory pressure situations)
  static Future<void> clearCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await DefaultCacheManager().emptyCache();
  }

  /// Clear old images from cache (keep recent ones)
  static void clearOldImages() {
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get current cache size in bytes
  static int getCurrentCacheSize() => PaintingBinding.instance.imageCache.currentSizeBytes;

  /// Get current cache size in MB
  static double getCurrentCacheSizeMB() => getCurrentCacheSize() / (1024 * 1024);

  /// Check if cache is near limit
  static bool isCacheNearLimit() {
    final int current = getCurrentCacheSize();
    final int max = PaintingBinding.instance.imageCache.maximumSizeBytes;
    return current > (max * 0.8); // 80% threshold
  }
}

