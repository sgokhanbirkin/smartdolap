import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartdolap/features/sync/domain/entities/sync_task.dart';
import 'package:smartdolap/features/sync/domain/services/i_sync_queue_service.dart';

/// Processes pending sync tasks and pushes them to Firestore.
class ProcessSyncQueueUseCase {
  ProcessSyncQueueUseCase({
    required ISyncQueueService queueService,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    Duration retryDelay = const Duration(seconds: 5),
  })  : _queueService = queueService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _retryDelay = retryDelay;

  final ISyncQueueService _queueService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final Duration _retryDelay;

  /// Processes all pending tasks.
  Future<void> call() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    final List<SyncTask> tasks = _queueService.getPendingTasks();
    for (final SyncTask task in tasks) {
      final bool success = await _processTask(task, user.uid);
      if (!success) {
        // Stop further processing to avoid hammering Firestore when errors happen
        break;
      }
    }
  }

  Future<bool> _processTask(SyncTask task, String userId) async {
    try {
      final SyncTask updated = task.copyWith(
        lastTriedAt: DateTime.now(),
        retryCount: task.retryCount + 1,
        lastError: null,
      );
      await _queueService.updateTask(updated);

      switch (task.entityType) {
        case 'recipe':
          await _processRecipeTask(task, userId);
          break;
        default:
          throw UnsupportedError('Unsupported entity type: ${task.entityType}');
      }

      await _queueService.removeTask(task.id);
      return true;
    } on FirebaseException catch (e) {
      final SyncTask failed = task.copyWith(
        lastTriedAt: DateTime.now(),
        retryCount: task.retryCount + 1,
        lastError: e.message,
      );
      await _queueService.updateTask(failed);
      await Future<void>.delayed(_retryDelay);
      return false;
    } catch (e) {
      final SyncTask failed = task.copyWith(
        lastTriedAt: DateTime.now(),
        retryCount: task.retryCount + 1,
        lastError: e.toString(),
      );
      await _queueService.updateTask(failed);
      await Future<void>.delayed(_retryDelay);
      return false;
    }
  }

  Future<void> _processRecipeTask(SyncTask task, String userId) async {
    final String? recipeId = task.payload['id'] as String?;
    if (recipeId == null || recipeId.isEmpty) {
      throw ArgumentError('Recipe task payload must include an id');
    }

    final DocumentReference<Map<String, dynamic>> doc = _firestore
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .doc(recipeId);

    switch (task.operation) {
      case 'create':
      case 'update':
        await doc.set(task.payload, SetOptions(merge: true));
        break;
      case 'delete':
        await doc.delete();
        break;
      default:
        throw UnsupportedError('Unsupported operation: ${task.operation}');
    }
  }
}

