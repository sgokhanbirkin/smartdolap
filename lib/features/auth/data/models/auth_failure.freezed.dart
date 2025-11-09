// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthFailure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthFailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(
    AuthFailure value,
    $Res Function(AuthFailure) then,
  ) = _$AuthFailureCopyWithImpl<$Res, AuthFailure>;
}

/// @nodoc
class _$AuthFailureCopyWithImpl<$Res, $Val extends AuthFailure>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  factory _$$InvalidCredentialsFailureImplCopyWith(
    _$InvalidCredentialsFailureImpl value,
    $Res Function(_$InvalidCredentialsFailureImpl) then,
  ) = __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$InvalidCredentialsFailureImpl>
    implements _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  __$$InvalidCredentialsFailureImplCopyWithImpl(
    _$InvalidCredentialsFailureImpl _value,
    $Res Function(_$InvalidCredentialsFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InvalidCredentialsFailureImpl implements InvalidCredentialsFailure {
  const _$InvalidCredentialsFailureImpl();

  @override
  String toString() {
    return 'AuthFailure.invalidCredentials()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidCredentialsFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) {
    return invalidCredentials();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) {
    return invalidCredentials?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return invalidCredentials(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return invalidCredentials?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(this);
    }
    return orElse();
  }
}

abstract class InvalidCredentialsFailure implements AuthFailure {
  const factory InvalidCredentialsFailure() = _$InvalidCredentialsFailureImpl;
}

/// @nodoc
abstract class _$$EmailAlreadyInUseFailureImplCopyWith<$Res> {
  factory _$$EmailAlreadyInUseFailureImplCopyWith(
    _$EmailAlreadyInUseFailureImpl value,
    $Res Function(_$EmailAlreadyInUseFailureImpl) then,
  ) = __$$EmailAlreadyInUseFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailAlreadyInUseFailureImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$EmailAlreadyInUseFailureImpl>
    implements _$$EmailAlreadyInUseFailureImplCopyWith<$Res> {
  __$$EmailAlreadyInUseFailureImplCopyWithImpl(
    _$EmailAlreadyInUseFailureImpl _value,
    $Res Function(_$EmailAlreadyInUseFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailAlreadyInUseFailureImpl implements EmailAlreadyInUseFailure {
  const _$EmailAlreadyInUseFailureImpl();

  @override
  String toString() {
    return 'AuthFailure.emailAlreadyInUse()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailAlreadyInUseFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) {
    return emailAlreadyInUse();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) {
    return emailAlreadyInUse?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return emailAlreadyInUse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return emailAlreadyInUse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (emailAlreadyInUse != null) {
      return emailAlreadyInUse(this);
    }
    return orElse();
  }
}

abstract class EmailAlreadyInUseFailure implements AuthFailure {
  const factory EmailAlreadyInUseFailure() = _$EmailAlreadyInUseFailureImpl;
}

/// @nodoc
abstract class _$$WeakPasswordFailureImplCopyWith<$Res> {
  factory _$$WeakPasswordFailureImplCopyWith(
    _$WeakPasswordFailureImpl value,
    $Res Function(_$WeakPasswordFailureImpl) then,
  ) = __$$WeakPasswordFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WeakPasswordFailureImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$WeakPasswordFailureImpl>
    implements _$$WeakPasswordFailureImplCopyWith<$Res> {
  __$$WeakPasswordFailureImplCopyWithImpl(
    _$WeakPasswordFailureImpl _value,
    $Res Function(_$WeakPasswordFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WeakPasswordFailureImpl implements WeakPasswordFailure {
  const _$WeakPasswordFailureImpl();

  @override
  String toString() {
    return 'AuthFailure.weakPassword()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakPasswordFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) {
    return weakPassword();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) {
    return weakPassword?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return weakPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return weakPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (weakPassword != null) {
      return weakPassword(this);
    }
    return orElse();
  }
}

abstract class WeakPasswordFailure implements AuthFailure {
  const factory WeakPasswordFailure() = _$WeakPasswordFailureImpl;
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl();

  @override
  String toString() {
    return 'AuthFailure.network()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NetworkFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) {
    return network();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) {
    return network?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements AuthFailure {
  const factory NetworkFailure() = _$NetworkFailureImpl;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$UnknownFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'AuthFailure.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() emailAlreadyInUse,
    required TResult Function() weakPassword,
    required TResult Function() network,
    required TResult Function(String? message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? emailAlreadyInUse,
    TResult? Function()? weakPassword,
    TResult? Function()? network,
    TResult? Function(String? message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? emailAlreadyInUse,
    TResult Function()? weakPassword,
    TResult Function()? network,
    TResult Function(String? message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InvalidCredentialsFailure value)
    invalidCredentials,
    required TResult Function(EmailAlreadyInUseFailure value) emailAlreadyInUse,
    required TResult Function(WeakPasswordFailure value) weakPassword,
    required TResult Function(NetworkFailure value) network,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult? Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult? Function(WeakPasswordFailure value)? weakPassword,
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    TResult Function(EmailAlreadyInUseFailure value)? emailAlreadyInUse,
    TResult Function(WeakPasswordFailure value)? weakPassword,
    TResult Function(NetworkFailure value)? network,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements AuthFailure {
  const factory UnknownFailure([final String? message]) = _$UnknownFailureImpl;

  String? get message;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
