part of 'pantry_cubit.dart';

/// Pantry state - Immutable state classes following MVVM pattern
///
/// Uses sealed class pattern for exhaustive pattern matching
/// Implements Equatable for efficient state comparison
///
/// SOLID Principles:
/// - Single Responsibility: Each state class represents one state
/// - Open/Closed: New states can be added without modifying existing
/// - Liskov Substitution: All states are substitutable for PantryState
sealed class PantryState extends Equatable {
  const PantryState();

  /// Initial state - app just started
  const factory PantryState.initial() = _PantryInitial;

  /// Loading state - fetching data
  const factory PantryState.loading() = _PantryLoading;

  /// Loaded state - data available
  const factory PantryState.loaded(List<PantryItem> items) = _PantryLoaded;

  /// Failure state - error occurred
  const factory PantryState.failure(String messageKey) = _PantryFailure;

  /// Pattern matching helper - execute callback based on state type
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<PantryItem> items) loaded,
    required T Function(String messageKey) failure,
  }) {
    final PantryState self = this;
    return switch (self) {
      _PantryInitial() => initial(),
      _PantryLoading() => loading(),
      _PantryLoaded(:final List<PantryItem> items) => loaded(items),
      _PantryFailure(:final String messageKey) => failure(messageKey),
    };
  }

  /// Pattern matching helper with optional callbacks
  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? initial,
    T Function()? loading,
    T Function(List<PantryItem> items)? loaded,
    T Function(String messageKey)? failure,
  }) {
    final PantryState self = this;
    return switch (self) {
      _PantryInitial() => initial?.call() ?? orElse(),
      _PantryLoading() => loading?.call() ?? orElse(),
      _PantryLoaded(:final List<PantryItem> items) =>
        loaded?.call(items) ?? orElse(),
      _PantryFailure(:final String messageKey) =>
        failure?.call(messageKey) ?? orElse(),
    };
  }

  /// Check if state is loading
  bool get isLoading => this is _PantryLoading;

  /// Check if state is loaded
  bool get isLoaded => this is _PantryLoaded;

  /// Check if state has error
  bool get hasError => this is _PantryFailure;

  /// Get items if loaded, otherwise empty list
  List<PantryItem> get itemsOrEmpty {
    final PantryState self = this;
    if (self is _PantryLoaded) {
      return self.items;
    }
    return <PantryItem>[];
  }
}

/// Initial state
final class _PantryInitial extends PantryState {
  const _PantryInitial();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading state
final class _PantryLoading extends PantryState {
  const _PantryLoading();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loaded state with pantry items
final class _PantryLoaded extends PantryState {
  const _PantryLoaded(this.items);

  /// List of pantry items
  final List<PantryItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Failure state with error message key (for localization)
final class _PantryFailure extends PantryState {
  const _PantryFailure(this.messageKey);

  /// Localization key for error message
  final String messageKey;

  @override
  List<Object?> get props => <Object?>[messageKey];
}
