// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_limit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RateLimitState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ApiUsage usage) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ApiUsage usage)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ApiUsage usage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RateLimitInitial value) initial,
    required TResult Function(RateLimitLoading value) loading,
    required TResult Function(RateLimitLoaded value) loaded,
    required TResult Function(RateLimitError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RateLimitInitial value)? initial,
    TResult? Function(RateLimitLoading value)? loading,
    TResult? Function(RateLimitLoaded value)? loaded,
    TResult? Function(RateLimitError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RateLimitInitial value)? initial,
    TResult Function(RateLimitLoading value)? loading,
    TResult Function(RateLimitLoaded value)? loaded,
    TResult Function(RateLimitError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateLimitStateCopyWith<$Res> {
  factory $RateLimitStateCopyWith(
    RateLimitState value,
    $Res Function(RateLimitState) then,
  ) = _$RateLimitStateCopyWithImpl<$Res, RateLimitState>;
}

/// @nodoc
class _$RateLimitStateCopyWithImpl<$Res, $Val extends RateLimitState>
    implements $RateLimitStateCopyWith<$Res> {
  _$RateLimitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RateLimitInitialImplCopyWith<$Res> {
  factory _$$RateLimitInitialImplCopyWith(
    _$RateLimitInitialImpl value,
    $Res Function(_$RateLimitInitialImpl) then,
  ) = __$$RateLimitInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RateLimitInitialImplCopyWithImpl<$Res>
    extends _$RateLimitStateCopyWithImpl<$Res, _$RateLimitInitialImpl>
    implements _$$RateLimitInitialImplCopyWith<$Res> {
  __$$RateLimitInitialImplCopyWithImpl(
    _$RateLimitInitialImpl _value,
    $Res Function(_$RateLimitInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RateLimitInitialImpl implements RateLimitInitial {
  const _$RateLimitInitialImpl();

  @override
  String toString() {
    return 'RateLimitState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RateLimitInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ApiUsage usage) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ApiUsage usage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ApiUsage usage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RateLimitInitial value) initial,
    required TResult Function(RateLimitLoading value) loading,
    required TResult Function(RateLimitLoaded value) loaded,
    required TResult Function(RateLimitError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RateLimitInitial value)? initial,
    TResult? Function(RateLimitLoading value)? loading,
    TResult? Function(RateLimitLoaded value)? loaded,
    TResult? Function(RateLimitError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RateLimitInitial value)? initial,
    TResult Function(RateLimitLoading value)? loading,
    TResult Function(RateLimitLoaded value)? loaded,
    TResult Function(RateLimitError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class RateLimitInitial implements RateLimitState {
  const factory RateLimitInitial() = _$RateLimitInitialImpl;
}

/// @nodoc
abstract class _$$RateLimitLoadingImplCopyWith<$Res> {
  factory _$$RateLimitLoadingImplCopyWith(
    _$RateLimitLoadingImpl value,
    $Res Function(_$RateLimitLoadingImpl) then,
  ) = __$$RateLimitLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RateLimitLoadingImplCopyWithImpl<$Res>
    extends _$RateLimitStateCopyWithImpl<$Res, _$RateLimitLoadingImpl>
    implements _$$RateLimitLoadingImplCopyWith<$Res> {
  __$$RateLimitLoadingImplCopyWithImpl(
    _$RateLimitLoadingImpl _value,
    $Res Function(_$RateLimitLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RateLimitLoadingImpl implements RateLimitLoading {
  const _$RateLimitLoadingImpl();

  @override
  String toString() {
    return 'RateLimitState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RateLimitLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ApiUsage usage) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ApiUsage usage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ApiUsage usage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RateLimitInitial value) initial,
    required TResult Function(RateLimitLoading value) loading,
    required TResult Function(RateLimitLoaded value) loaded,
    required TResult Function(RateLimitError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RateLimitInitial value)? initial,
    TResult? Function(RateLimitLoading value)? loading,
    TResult? Function(RateLimitLoaded value)? loaded,
    TResult? Function(RateLimitError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RateLimitInitial value)? initial,
    TResult Function(RateLimitLoading value)? loading,
    TResult Function(RateLimitLoaded value)? loaded,
    TResult Function(RateLimitError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class RateLimitLoading implements RateLimitState {
  const factory RateLimitLoading() = _$RateLimitLoadingImpl;
}

/// @nodoc
abstract class _$$RateLimitLoadedImplCopyWith<$Res> {
  factory _$$RateLimitLoadedImplCopyWith(
    _$RateLimitLoadedImpl value,
    $Res Function(_$RateLimitLoadedImpl) then,
  ) = __$$RateLimitLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ApiUsage usage});
}

/// @nodoc
class __$$RateLimitLoadedImplCopyWithImpl<$Res>
    extends _$RateLimitStateCopyWithImpl<$Res, _$RateLimitLoadedImpl>
    implements _$$RateLimitLoadedImplCopyWith<$Res> {
  __$$RateLimitLoadedImplCopyWithImpl(
    _$RateLimitLoadedImpl _value,
    $Res Function(_$RateLimitLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? usage = null}) {
    return _then(
      _$RateLimitLoadedImpl(
        null == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as ApiUsage,
      ),
    );
  }
}

/// @nodoc

class _$RateLimitLoadedImpl implements RateLimitLoaded {
  const _$RateLimitLoadedImpl(this.usage);

  @override
  final ApiUsage usage;

  @override
  String toString() {
    return 'RateLimitState.loaded(usage: $usage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitLoadedImpl &&
            (identical(other.usage, usage) || other.usage == usage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, usage);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitLoadedImplCopyWith<_$RateLimitLoadedImpl> get copyWith =>
      __$$RateLimitLoadedImplCopyWithImpl<_$RateLimitLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ApiUsage usage) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(usage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ApiUsage usage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(usage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ApiUsage usage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(usage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RateLimitInitial value) initial,
    required TResult Function(RateLimitLoading value) loading,
    required TResult Function(RateLimitLoaded value) loaded,
    required TResult Function(RateLimitError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RateLimitInitial value)? initial,
    TResult? Function(RateLimitLoading value)? loading,
    TResult? Function(RateLimitLoaded value)? loaded,
    TResult? Function(RateLimitError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RateLimitInitial value)? initial,
    TResult Function(RateLimitLoading value)? loading,
    TResult Function(RateLimitLoaded value)? loaded,
    TResult Function(RateLimitError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class RateLimitLoaded implements RateLimitState {
  const factory RateLimitLoaded(final ApiUsage usage) = _$RateLimitLoadedImpl;

  ApiUsage get usage;

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitLoadedImplCopyWith<_$RateLimitLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitErrorImplCopyWith<$Res> {
  factory _$$RateLimitErrorImplCopyWith(
    _$RateLimitErrorImpl value,
    $Res Function(_$RateLimitErrorImpl) then,
  ) = __$$RateLimitErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RateLimitErrorImplCopyWithImpl<$Res>
    extends _$RateLimitStateCopyWithImpl<$Res, _$RateLimitErrorImpl>
    implements _$$RateLimitErrorImplCopyWith<$Res> {
  __$$RateLimitErrorImplCopyWithImpl(
    _$RateLimitErrorImpl _value,
    $Res Function(_$RateLimitErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$RateLimitErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RateLimitErrorImpl implements RateLimitError {
  const _$RateLimitErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'RateLimitState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitErrorImplCopyWith<_$RateLimitErrorImpl> get copyWith =>
      __$$RateLimitErrorImplCopyWithImpl<_$RateLimitErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ApiUsage usage) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ApiUsage usage)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ApiUsage usage)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RateLimitInitial value) initial,
    required TResult Function(RateLimitLoading value) loading,
    required TResult Function(RateLimitLoaded value) loaded,
    required TResult Function(RateLimitError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RateLimitInitial value)? initial,
    TResult? Function(RateLimitLoading value)? loading,
    TResult? Function(RateLimitLoaded value)? loaded,
    TResult? Function(RateLimitError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RateLimitInitial value)? initial,
    TResult Function(RateLimitLoading value)? loading,
    TResult Function(RateLimitLoaded value)? loaded,
    TResult Function(RateLimitError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RateLimitError implements RateLimitState {
  const factory RateLimitError(final String message) = _$RateLimitErrorImpl;

  String get message;

  /// Create a copy of RateLimitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitErrorImplCopyWith<_$RateLimitErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
