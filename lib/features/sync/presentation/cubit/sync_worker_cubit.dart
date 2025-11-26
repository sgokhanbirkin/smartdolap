import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/sync/domain/services/i_sync_queue_service.dart';
import 'package:smartdolap/features/sync/domain/use_cases/process_sync_queue_usecase.dart';

part 'sync_worker_state.dart';

/// Periodically processes the sync queue.
class SyncWorkerCubit extends Cubit<SyncWorkerState> {
  SyncWorkerCubit({
    required ISyncQueueService queueService,
    ProcessSyncQueueUseCase? processUseCase,
    Duration interval = const Duration(minutes: 5),
  })  : _queueService = queueService,
        _processUseCase =
            processUseCase ?? ProcessSyncQueueUseCase(queueService: queueService),
        _interval = interval,
        super(const SyncWorkerState.idle());

  final ISyncQueueService _queueService;
  final ProcessSyncQueueUseCase _processUseCase;
  final Duration _interval;
  Timer? _timer;
  bool _isRunning = false;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _run());
    _run();
  }

  Future<void> _run() async {
    if (_isRunning) {
      return;
    }
    final int pending = _queueService.getPendingTasks().length;
    if (pending == 0) {
      emit(SyncWorkerState.idle());
      return;
    }

    _isRunning = true;
    emit(SyncWorkerState.running(pending));

    try {
      await _processUseCase();
      final int left = _queueService.getPendingTasks().length;
      emit(SyncWorkerState.success(left));
    } catch (e) {
      emit(SyncWorkerState.failure(e.toString()));
    } finally {
      _isRunning = false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

