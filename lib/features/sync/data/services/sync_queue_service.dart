import 'package:hive/hive.dart';
import 'package:smartdolap/features/sync/domain/entities/sync_task.dart';
import 'package:smartdolap/features/sync/domain/services/i_sync_queue_service.dart';

/// Hive-backed implementation of the sync queue.
class SyncQueueService implements ISyncQueueService {
  /// Creates a queue service using the provided Hive box.
  SyncQueueService(this._box);

  final Box<dynamic> _box;

  @override
  Future<SyncTask> enqueue(SyncTask task) async {
    await _box.put(task.id, task.toMap());
    return task;
  }

  @override
  List<SyncTask> getPendingTasks() {
    final List<SyncTask> tasks = _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(SyncTask.fromMap)
        .toList();

    tasks.sort(
      (SyncTask a, SyncTask b) => a.createdAt.compareTo(b.createdAt),
    );

    return tasks;
  }

  @override
  Future<void> updateTask(SyncTask task) async {
    await _box.put(task.id, task.toMap());
  }

  @override
  Future<void> removeTask(String taskId) async {
    await _box.delete(taskId);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}

