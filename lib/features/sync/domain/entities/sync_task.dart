import 'package:uuid/uuid.dart';

/// Represents a pending change that needs to be synced with Firestore.
class SyncTask {
  /// Creates a sync task.
  SyncTask({
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.createdAt,
    String? id,
    this.lastTriedAt,
    this.retryCount = 0,
    this.lastError,
  }) : id = id ?? const Uuid().v4();

  /// Deserialize from map.
  factory SyncTask.fromMap(Map<dynamic, dynamic> map) => SyncTask(
    id: map['id'] as String?,
    entityType: map['entityType'] as String? ?? 'unknown',
    operation: map['operation'] as String? ?? 'create',
    payload: _parsePayload(map['payload'] as Map<dynamic, dynamic>?),
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    lastTriedAt: map['lastTriedAt'] != null
        ? DateTime.tryParse(map['lastTriedAt'] as String)
        : null,
    retryCount: map['retryCount'] as int? ?? 0,
    lastError: map['lastError'] as String?,
  );

  /// Unique identifier for the task.
  final String id;

  /// Entity type (e.g., `recipe`, `favorite`, etc.).
  final String entityType;

  /// Operation (e.g., `create`, `update`, `delete`).
  final String operation;

  /// Payload to be sent to Firestore.
  final Map<String, dynamic> payload;

  /// When the task was created.
  final DateTime createdAt;

  /// Last time the task was attempted.
  final DateTime? lastTriedAt;

  /// Number of retries.
  final int retryCount;

  /// Last error message if failed.
  final String? lastError;

  /// Task status derived from retry data.
  bool get isPending => lastError == null;

  /// Creates a copy with modifications.
  SyncTask copyWith({
    String? id,
    String? entityType,
    String? operation,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? lastTriedAt,
    int? retryCount,
    String? lastError,
  }) => SyncTask(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    lastTriedAt: lastTriedAt ?? this.lastTriedAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError ?? this.lastError,
  );

  /// Serialize for Hive/Firestore storage.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'entityType': entityType,
    'operation': operation,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'lastTriedAt': lastTriedAt?.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
  };
}

Map<String, dynamic> _parsePayload(Map<dynamic, dynamic>? source) {
  if (source == null) {
    return <String, dynamic>{};
  }
  final Map<String, dynamic> result = <String, dynamic>{};
  source.forEach((Object? key, Object? value) {
    if (key is String) {
      result[key] = value;
    }
  });
  return result;
}
