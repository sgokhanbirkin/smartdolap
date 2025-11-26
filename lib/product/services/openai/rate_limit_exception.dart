// ignore_for_file: public_member_api_docs

/// Exception thrown when API rate limit is exceeded
class RateLimitException implements Exception {
  const RateLimitException(this.message);

  final String message;

  @override
  String toString() => 'RateLimitException: $message';
}


