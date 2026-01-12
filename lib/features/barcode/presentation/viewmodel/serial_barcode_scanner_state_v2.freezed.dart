// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'serial_barcode_scanner_state_v2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SerialBarcodeScannerStateV2 {
  /// List of all queued scans with their statuses
  List<QueuedScan> get queuedScans => throw _privateConstructorUsedError;

  /// Count of pending scans
  int get pendingCount => throw _privateConstructorUsedError;

  /// Count of successfully found products
  int get foundCount => throw _privateConstructorUsedError;

  /// Last feedback event for triggering audio/haptic
  FeedbackEvent get lastFeedbackEvent => throw _privateConstructorUsedError;

  /// Last error barcode (for showing dialogs)
  String? get lastErrorBarcode => throw _privateConstructorUsedError;

  /// Last error message
  String? get lastErrorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SerialBarcodeScannerStateV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SerialBarcodeScannerStateV2CopyWith<SerialBarcodeScannerStateV2>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SerialBarcodeScannerStateV2CopyWith<$Res> {
  factory $SerialBarcodeScannerStateV2CopyWith(
    SerialBarcodeScannerStateV2 value,
    $Res Function(SerialBarcodeScannerStateV2) then,
  ) =
      _$SerialBarcodeScannerStateV2CopyWithImpl<
        $Res,
        SerialBarcodeScannerStateV2
      >;
  @useResult
  $Res call({
    List<QueuedScan> queuedScans,
    int pendingCount,
    int foundCount,
    FeedbackEvent lastFeedbackEvent,
    String? lastErrorBarcode,
    String? lastErrorMessage,
  });
}

/// @nodoc
class _$SerialBarcodeScannerStateV2CopyWithImpl<
  $Res,
  $Val extends SerialBarcodeScannerStateV2
>
    implements $SerialBarcodeScannerStateV2CopyWith<$Res> {
  _$SerialBarcodeScannerStateV2CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SerialBarcodeScannerStateV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queuedScans = null,
    Object? pendingCount = null,
    Object? foundCount = null,
    Object? lastFeedbackEvent = null,
    Object? lastErrorBarcode = freezed,
    Object? lastErrorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            queuedScans: null == queuedScans
                ? _value.queuedScans
                : queuedScans // ignore: cast_nullable_to_non_nullable
                      as List<QueuedScan>,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            foundCount: null == foundCount
                ? _value.foundCount
                : foundCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastFeedbackEvent: null == lastFeedbackEvent
                ? _value.lastFeedbackEvent
                : lastFeedbackEvent // ignore: cast_nullable_to_non_nullable
                      as FeedbackEvent,
            lastErrorBarcode: freezed == lastErrorBarcode
                ? _value.lastErrorBarcode
                : lastErrorBarcode // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastErrorMessage: freezed == lastErrorMessage
                ? _value.lastErrorMessage
                : lastErrorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SerialBarcodeScannerStateV2ImplCopyWith<$Res>
    implements $SerialBarcodeScannerStateV2CopyWith<$Res> {
  factory _$$SerialBarcodeScannerStateV2ImplCopyWith(
    _$SerialBarcodeScannerStateV2Impl value,
    $Res Function(_$SerialBarcodeScannerStateV2Impl) then,
  ) = __$$SerialBarcodeScannerStateV2ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<QueuedScan> queuedScans,
    int pendingCount,
    int foundCount,
    FeedbackEvent lastFeedbackEvent,
    String? lastErrorBarcode,
    String? lastErrorMessage,
  });
}

/// @nodoc
class __$$SerialBarcodeScannerStateV2ImplCopyWithImpl<$Res>
    extends
        _$SerialBarcodeScannerStateV2CopyWithImpl<
          $Res,
          _$SerialBarcodeScannerStateV2Impl
        >
    implements _$$SerialBarcodeScannerStateV2ImplCopyWith<$Res> {
  __$$SerialBarcodeScannerStateV2ImplCopyWithImpl(
    _$SerialBarcodeScannerStateV2Impl _value,
    $Res Function(_$SerialBarcodeScannerStateV2Impl) _then,
  ) : super(_value, _then);

  /// Create a copy of SerialBarcodeScannerStateV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queuedScans = null,
    Object? pendingCount = null,
    Object? foundCount = null,
    Object? lastFeedbackEvent = null,
    Object? lastErrorBarcode = freezed,
    Object? lastErrorMessage = freezed,
  }) {
    return _then(
      _$SerialBarcodeScannerStateV2Impl(
        queuedScans: null == queuedScans
            ? _value._queuedScans
            : queuedScans // ignore: cast_nullable_to_non_nullable
                  as List<QueuedScan>,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        foundCount: null == foundCount
            ? _value.foundCount
            : foundCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastFeedbackEvent: null == lastFeedbackEvent
            ? _value.lastFeedbackEvent
            : lastFeedbackEvent // ignore: cast_nullable_to_non_nullable
                  as FeedbackEvent,
        lastErrorBarcode: freezed == lastErrorBarcode
            ? _value.lastErrorBarcode
            : lastErrorBarcode // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastErrorMessage: freezed == lastErrorMessage
            ? _value.lastErrorMessage
            : lastErrorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SerialBarcodeScannerStateV2Impl
    implements _SerialBarcodeScannerStateV2 {
  const _$SerialBarcodeScannerStateV2Impl({
    final List<QueuedScan> queuedScans = const [],
    this.pendingCount = 0,
    this.foundCount = 0,
    this.lastFeedbackEvent = FeedbackEvent.none,
    this.lastErrorBarcode,
    this.lastErrorMessage,
  }) : _queuedScans = queuedScans;

  /// List of all queued scans with their statuses
  final List<QueuedScan> _queuedScans;

  /// List of all queued scans with their statuses
  @override
  @JsonKey()
  List<QueuedScan> get queuedScans {
    if (_queuedScans is EqualUnmodifiableListView) return _queuedScans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queuedScans);
  }

  /// Count of pending scans
  @override
  @JsonKey()
  final int pendingCount;

  /// Count of successfully found products
  @override
  @JsonKey()
  final int foundCount;

  /// Last feedback event for triggering audio/haptic
  @override
  @JsonKey()
  final FeedbackEvent lastFeedbackEvent;

  /// Last error barcode (for showing dialogs)
  @override
  final String? lastErrorBarcode;

  /// Last error message
  @override
  final String? lastErrorMessage;

  @override
  String toString() {
    return 'SerialBarcodeScannerStateV2(queuedScans: $queuedScans, pendingCount: $pendingCount, foundCount: $foundCount, lastFeedbackEvent: $lastFeedbackEvent, lastErrorBarcode: $lastErrorBarcode, lastErrorMessage: $lastErrorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SerialBarcodeScannerStateV2Impl &&
            const DeepCollectionEquality().equals(
              other._queuedScans,
              _queuedScans,
            ) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.foundCount, foundCount) ||
                other.foundCount == foundCount) &&
            (identical(other.lastFeedbackEvent, lastFeedbackEvent) ||
                other.lastFeedbackEvent == lastFeedbackEvent) &&
            (identical(other.lastErrorBarcode, lastErrorBarcode) ||
                other.lastErrorBarcode == lastErrorBarcode) &&
            (identical(other.lastErrorMessage, lastErrorMessage) ||
                other.lastErrorMessage == lastErrorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_queuedScans),
    pendingCount,
    foundCount,
    lastFeedbackEvent,
    lastErrorBarcode,
    lastErrorMessage,
  );

  /// Create a copy of SerialBarcodeScannerStateV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SerialBarcodeScannerStateV2ImplCopyWith<_$SerialBarcodeScannerStateV2Impl>
  get copyWith =>
      __$$SerialBarcodeScannerStateV2ImplCopyWithImpl<
        _$SerialBarcodeScannerStateV2Impl
      >(this, _$identity);
}

abstract class _SerialBarcodeScannerStateV2
    implements SerialBarcodeScannerStateV2 {
  const factory _SerialBarcodeScannerStateV2({
    final List<QueuedScan> queuedScans,
    final int pendingCount,
    final int foundCount,
    final FeedbackEvent lastFeedbackEvent,
    final String? lastErrorBarcode,
    final String? lastErrorMessage,
  }) = _$SerialBarcodeScannerStateV2Impl;

  /// List of all queued scans with their statuses
  @override
  List<QueuedScan> get queuedScans;

  /// Count of pending scans
  @override
  int get pendingCount;

  /// Count of successfully found products
  @override
  int get foundCount;

  /// Last feedback event for triggering audio/haptic
  @override
  FeedbackEvent get lastFeedbackEvent;

  /// Last error barcode (for showing dialogs)
  @override
  String? get lastErrorBarcode;

  /// Last error message
  @override
  String? get lastErrorMessage;

  /// Create a copy of SerialBarcodeScannerStateV2
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SerialBarcodeScannerStateV2ImplCopyWith<_$SerialBarcodeScannerStateV2Impl>
  get copyWith => throw _privateConstructorUsedError;
}
