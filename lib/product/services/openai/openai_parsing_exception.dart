/// Exception thrown when OpenAI response parsing fails
/// Follows Single Responsibility Principle - only represents parsing errors
class OpenAIParsingException implements Exception {
  /// Constructor
  const OpenAIParsingException(this.reason);

  /// Reason code for the parsing error
  final String reason;

  /// Error message
  @override
  String toString() => 'OpenAIParsingException: $reason';
}

