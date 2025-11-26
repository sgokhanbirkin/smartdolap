// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';

/// Helper class for managing request cancellation tokens
/// Provides centralized cancellation token management for API calls
class RequestCancellationHelper {
  /// Request cancellation helper constructor
  RequestCancellationHelper();

  /// Active cancellation tokens
  final Map<String, CancelToken> _tokens = <String, CancelToken>{};

  /// Create or get a cancellation token for a specific operation
  /// If a token already exists for the key, it will be cancelled first
  CancelToken getToken(String key) {
    // Cancel existing token if any
    _tokens[key]?.cancel('New request started');
    // Create new token
    final CancelToken token = CancelToken();
    _tokens[key] = token;
    return token;
  }

  /// Cancel a specific token
  void cancel(String key, [String? reason]) {
    _tokens[key]?.cancel(reason ?? 'Cancelled by user');
    _tokens.remove(key);
  }

  /// Cancel all active tokens
  void cancelAll([String? reason]) {
    for (final CancelToken token in _tokens.values) {
      if (!token.isCancelled) {
        token.cancel(reason ?? 'All requests cancelled');
      }
    }
    _tokens.clear();
  }

  /// Dispose and clean up all tokens
  void dispose() {
    cancelAll('Disposing');
  }
}

