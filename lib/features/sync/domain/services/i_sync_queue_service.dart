import 'package:smartdolap/features/sync/domain/entities/sync_task.dart';

/// Interface for local sync queue operations.
abstract class ISyncQueueService {
  /// Enqueue a new sync task.
  Future<SyncTask> enqueue(SyncTask task);

  /// Get pending tasks ordered by creation time.
  List<SyncTask> getPendingTasks();

  /// Update an existing task.
  Future<void> updateTask(SyncTask task);

  /// Remove a task from queue.
  Future<void> removeTask(String taskId);

  /// Clear entire queue (used for logout/debug).
  Future<void> clear();
}

