// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'serial_barcode_scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SerialBarcodeScannerState {
  /// List of successfully scanned products in the current session
  List<ScannedProduct> get scannedItems => throw _privateConstructorUsedError;

  /// Whether a product is currently being looked up
  bool get isProcessing => throw _privateConstructorUsedError;

  /// Last scanned barcode (for immediate feedback logic if needed)
  String? get lastScannedBarcode => throw _privateConstructorUsedError;

  /// Latest error message if any
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SerialBarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SerialBarcodeScannerStateCopyWith<SerialBarcodeScannerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SerialBarcodeScannerStateCopyWith<$Res> {
  factory $SerialBarcodeScannerStateCopyWith(
    SerialBarcodeScannerState value,
    $Res Function(SerialBarcodeScannerState) then,
  ) = _$SerialBarcodeScannerStateCopyWithImpl<$Res, SerialBarcodeScannerState>;
  @useResult
  $Res call({
    List<ScannedProduct> scannedItems,
    bool isProcessing,
    String? lastScannedBarcode,
    String? errorMessage,
  });
}

/// @nodoc
class _$SerialBarcodeScannerStateCopyWithImpl<
  $Res,
  $Val extends SerialBarcodeScannerState
>
    implements $SerialBarcodeScannerStateCopyWith<$Res> {
  _$SerialBarcodeScannerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SerialBarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scannedItems = null,
    Object? isProcessing = null,
    Object? lastScannedBarcode = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            scannedItems: null == scannedItems
                ? _value.scannedItems
                : scannedItems // ignore: cast_nullable_to_non_nullable
                      as List<ScannedProduct>,
            isProcessing: null == isProcessing
                ? _value.isProcessing
                : isProcessing // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastScannedBarcode: freezed == lastScannedBarcode
                ? _value.lastScannedBarcode
                : lastScannedBarcode // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SerialBarcodeScannerStateImplCopyWith<$Res>
    implements $SerialBarcodeScannerStateCopyWith<$Res> {
  factory _$$SerialBarcodeScannerStateImplCopyWith(
    _$SerialBarcodeScannerStateImpl value,
    $Res Function(_$SerialBarcodeScannerStateImpl) then,
  ) = __$$SerialBarcodeScannerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ScannedProduct> scannedItems,
    bool isProcessing,
    String? lastScannedBarcode,
    String? errorMessage,
  });
}

/// @nodoc
class __$$SerialBarcodeScannerStateImplCopyWithImpl<$Res>
    extends
        _$SerialBarcodeScannerStateCopyWithImpl<
          $Res,
          _$SerialBarcodeScannerStateImpl
        >
    implements _$$SerialBarcodeScannerStateImplCopyWith<$Res> {
  __$$SerialBarcodeScannerStateImplCopyWithImpl(
    _$SerialBarcodeScannerStateImpl _value,
    $Res Function(_$SerialBarcodeScannerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SerialBarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scannedItems = null,
    Object? isProcessing = null,
    Object? lastScannedBarcode = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$SerialBarcodeScannerStateImpl(
        scannedItems: null == scannedItems
            ? _value._scannedItems
            : scannedItems // ignore: cast_nullable_to_non_nullable
                  as List<ScannedProduct>,
        isProcessing: null == isProcessing
            ? _value.isProcessing
            : isProcessing // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastScannedBarcode: freezed == lastScannedBarcode
            ? _value.lastScannedBarcode
            : lastScannedBarcode // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SerialBarcodeScannerStateImpl implements _SerialBarcodeScannerState {
  const _$SerialBarcodeScannerStateImpl({
    final List<ScannedProduct> scannedItems = const [],
    this.isProcessing = false,
    this.lastScannedBarcode,
    this.errorMessage,
  }) : _scannedItems = scannedItems;

  /// List of successfully scanned products in the current session
  final List<ScannedProduct> _scannedItems;

  /// List of successfully scanned products in the current session
  @override
  @JsonKey()
  List<ScannedProduct> get scannedItems {
    if (_scannedItems is EqualUnmodifiableListView) return _scannedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scannedItems);
  }

  /// Whether a product is currently being looked up
  @override
  @JsonKey()
  final bool isProcessing;

  /// Last scanned barcode (for immediate feedback logic if needed)
  @override
  final String? lastScannedBarcode;

  /// Latest error message if any
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SerialBarcodeScannerState(scannedItems: $scannedItems, isProcessing: $isProcessing, lastScannedBarcode: $lastScannedBarcode, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SerialBarcodeScannerStateImpl &&
            const DeepCollectionEquality().equals(
              other._scannedItems,
              _scannedItems,
            ) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.lastScannedBarcode, lastScannedBarcode) ||
                other.lastScannedBarcode == lastScannedBarcode) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_scannedItems),
    isProcessing,
    lastScannedBarcode,
    errorMessage,
  );

  /// Create a copy of SerialBarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SerialBarcodeScannerStateImplCopyWith<_$SerialBarcodeScannerStateImpl>
  get copyWith =>
      __$$SerialBarcodeScannerStateImplCopyWithImpl<
        _$SerialBarcodeScannerStateImpl
      >(this, _$identity);
}

abstract class _SerialBarcodeScannerState implements SerialBarcodeScannerState {
  const factory _SerialBarcodeScannerState({
    final List<ScannedProduct> scannedItems,
    final bool isProcessing,
    final String? lastScannedBarcode,
    final String? errorMessage,
  }) = _$SerialBarcodeScannerStateImpl;

  /// List of successfully scanned products in the current session
  @override
  List<ScannedProduct> get scannedItems;

  /// Whether a product is currently being looked up
  @override
  bool get isProcessing;

  /// Last scanned barcode (for immediate feedback logic if needed)
  @override
  String? get lastScannedBarcode;

  /// Latest error message if any
  @override
  String? get errorMessage;

  /// Create a copy of SerialBarcodeScannerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SerialBarcodeScannerStateImplCopyWith<_$SerialBarcodeScannerStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
