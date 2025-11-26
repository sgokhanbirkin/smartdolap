part of 'sync_worker_cubit.dart';

/// Sync worker states.
class SyncWorkerState {
  const SyncWorkerState._({
    required this.status,
    this.pending = 0,
    this.errorMessage,
  });

  const SyncWorkerState.idle() : this._(status: SyncWorkerStatus.idle);

  const SyncWorkerState.running(int pending)
      : this._(status: SyncWorkerStatus.running, pending: pending);

  const SyncWorkerState.success(int pending)
      : this._(status: SyncWorkerStatus.success, pending: pending);

  const SyncWorkerState.failure(String message)
      : this._(
          status: SyncWorkerStatus.failure,
          errorMessage: message,
        );

  final SyncWorkerStatus status;
  final int pending;
  final String? errorMessage;
}

/// Enum for sync worker status.
enum SyncWorkerStatus {
  idle,
  running,
  success,
  failure,
}

