// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barcode_scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BarcodeScannerState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarcodeScannerStateCopyWith<$Res> {
  factory $BarcodeScannerStateCopyWith(
    BarcodeScannerState value,
    $Res Function(BarcodeScannerState) then,
  ) = _$BarcodeScannerStateCopyWithImpl<$Res, BarcodeScannerState>;
}

/// @nodoc
class _$BarcodeScannerStateCopyWithImpl<$Res, $Val extends BarcodeScannerState>
    implements $BarcodeScannerStateCopyWith<$Res> {
  _$BarcodeScannerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ReadyImplCopyWith<$Res> {
  factory _$$ReadyImplCopyWith(
    _$ReadyImpl value,
    $Res Function(_$ReadyImpl) then,
  ) = __$$ReadyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ReadyImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$ReadyImpl>
    implements _$$ReadyImplCopyWith<$Res> {
  __$$ReadyImplCopyWithImpl(
    _$ReadyImpl _value,
    $Res Function(_$ReadyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ReadyImpl implements _Ready {
  const _$ReadyImpl();

  @override
  String toString() {
    return 'BarcodeScannerState.ready()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ReadyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return ready();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return ready?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return ready(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return ready?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _Ready implements BarcodeScannerState {
  const factory _Ready() = _$ReadyImpl;
}

/// @nodoc
abstract class _$$ScanningImplCopyWith<$Res> {
  factory _$$ScanningImplCopyWith(
    _$ScanningImpl value,
    $Res Function(_$ScanningImpl) then,
  ) = __$$ScanningImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String barcode});
}

/// @nodoc
class __$$ScanningImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$ScanningImpl>
    implements _$$ScanningImplCopyWith<$Res> {
  __$$ScanningImplCopyWithImpl(
    _$ScanningImpl _value,
    $Res Function(_$ScanningImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? barcode = null}) {
    return _then(
      _$ScanningImpl(
        barcode: null == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ScanningImpl implements _Scanning {
  const _$ScanningImpl({required this.barcode});

  @override
  final String barcode;

  @override
  String toString() {
    return 'BarcodeScannerState.scanning(barcode: $barcode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanningImpl &&
            (identical(other.barcode, barcode) || other.barcode == barcode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, barcode);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanningImplCopyWith<_$ScanningImpl> get copyWith =>
      __$$ScanningImplCopyWithImpl<_$ScanningImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return scanning(barcode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return scanning?.call(barcode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (scanning != null) {
      return scanning(barcode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return scanning(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return scanning?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (scanning != null) {
      return scanning(this);
    }
    return orElse();
  }
}

abstract class _Scanning implements BarcodeScannerState {
  const factory _Scanning({required final String barcode}) = _$ScanningImpl;

  String get barcode;

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanningImplCopyWith<_$ScanningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProductFoundImplCopyWith<$Res> {
  factory _$$ProductFoundImplCopyWith(
    _$ProductFoundImpl value,
    $Res Function(_$ProductFoundImpl) then,
  ) = __$$ProductFoundImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ScannedProduct product});
}

/// @nodoc
class __$$ProductFoundImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$ProductFoundImpl>
    implements _$$ProductFoundImplCopyWith<$Res> {
  __$$ProductFoundImplCopyWithImpl(
    _$ProductFoundImpl _value,
    $Res Function(_$ProductFoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? product = null}) {
    return _then(
      _$ProductFoundImpl(
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as ScannedProduct,
      ),
    );
  }
}

/// @nodoc

class _$ProductFoundImpl implements _ProductFound {
  const _$ProductFoundImpl({required this.product});

  @override
  final ScannedProduct product;

  @override
  String toString() {
    return 'BarcodeScannerState.productFound(product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductFoundImpl &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductFoundImplCopyWith<_$ProductFoundImpl> get copyWith =>
      __$$ProductFoundImplCopyWithImpl<_$ProductFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return productFound(product);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return productFound?.call(product);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (productFound != null) {
      return productFound(product);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return productFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return productFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (productFound != null) {
      return productFound(this);
    }
    return orElse();
  }
}

abstract class _ProductFound implements BarcodeScannerState {
  const factory _ProductFound({required final ScannedProduct product}) =
      _$ProductFoundImpl;

  ScannedProduct get product;

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductFoundImplCopyWith<_$ProductFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProductNotFoundImplCopyWith<$Res> {
  factory _$$ProductNotFoundImplCopyWith(
    _$ProductNotFoundImpl value,
    $Res Function(_$ProductNotFoundImpl) then,
  ) = __$$ProductNotFoundImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String barcode});
}

/// @nodoc
class __$$ProductNotFoundImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$ProductNotFoundImpl>
    implements _$$ProductNotFoundImplCopyWith<$Res> {
  __$$ProductNotFoundImplCopyWithImpl(
    _$ProductNotFoundImpl _value,
    $Res Function(_$ProductNotFoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? barcode = null}) {
    return _then(
      _$ProductNotFoundImpl(
        barcode: null == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProductNotFoundImpl implements _ProductNotFound {
  const _$ProductNotFoundImpl({required this.barcode});

  @override
  final String barcode;

  @override
  String toString() {
    return 'BarcodeScannerState.productNotFound(barcode: $barcode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductNotFoundImpl &&
            (identical(other.barcode, barcode) || other.barcode == barcode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, barcode);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductNotFoundImplCopyWith<_$ProductNotFoundImpl> get copyWith =>
      __$$ProductNotFoundImplCopyWithImpl<_$ProductNotFoundImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return productNotFound(barcode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return productNotFound?.call(barcode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (productNotFound != null) {
      return productNotFound(barcode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return productNotFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return productNotFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (productNotFound != null) {
      return productNotFound(this);
    }
    return orElse();
  }
}

abstract class _ProductNotFound implements BarcodeScannerState {
  const factory _ProductNotFound({required final String barcode}) =
      _$ProductNotFoundImpl;

  String get barcode;

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductNotFoundImplCopyWith<_$ProductNotFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? barcode});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? barcode = freezed}) {
    return _then(
      _$ErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        barcode: freezed == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message, this.barcode});

  @override
  final String message;
  @override
  final String? barcode;

  @override
  String toString() {
    return 'BarcodeScannerState.error(message: $message, barcode: $barcode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.barcode, barcode) || other.barcode == barcode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, barcode);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return error(message, barcode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return error?.call(message, barcode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, barcode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements BarcodeScannerState {
  const factory _Error({required final String message, final String? barcode}) =
      _$ErrorImpl;

  String get message;
  String? get barcode;

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionDeniedImplCopyWith<$Res> {
  factory _$$PermissionDeniedImplCopyWith(
    _$PermissionDeniedImpl value,
    $Res Function(_$PermissionDeniedImpl) then,
  ) = __$$PermissionDeniedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PermissionDeniedImplCopyWithImpl<$Res>
    extends _$BarcodeScannerStateCopyWithImpl<$Res, _$PermissionDeniedImpl>
    implements _$$PermissionDeniedImplCopyWith<$Res> {
  __$$PermissionDeniedImplCopyWithImpl(
    _$PermissionDeniedImpl _value,
    $Res Function(_$PermissionDeniedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PermissionDeniedImpl implements _PermissionDenied {
  const _$PermissionDeniedImpl();

  @override
  String toString() {
    return 'BarcodeScannerState.permissionDenied()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PermissionDeniedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(String barcode) scanning,
    required TResult Function(ScannedProduct product) productFound,
    required TResult Function(String barcode) productNotFound,
    required TResult Function(String message, String? barcode) error,
    required TResult Function() permissionDenied,
  }) {
    return permissionDenied();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(String barcode)? scanning,
    TResult? Function(ScannedProduct product)? productFound,
    TResult? Function(String barcode)? productNotFound,
    TResult? Function(String message, String? barcode)? error,
    TResult? Function()? permissionDenied,
  }) {
    return permissionDenied?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(String barcode)? scanning,
    TResult Function(ScannedProduct product)? productFound,
    TResult Function(String barcode)? productNotFound,
    TResult Function(String message, String? barcode)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_ProductFound value) productFound,
    required TResult Function(_ProductNotFound value) productNotFound,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return permissionDenied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_ProductFound value)? productFound,
    TResult? Function(_ProductNotFound value)? productNotFound,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return permissionDenied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_ProductFound value)? productFound,
    TResult Function(_ProductNotFound value)? productNotFound,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied(this);
    }
    return orElse();
  }
}

abstract class _PermissionDenied implements BarcodeScannerState {
  const factory _PermissionDenied() = _$PermissionDeniedImpl;
}
