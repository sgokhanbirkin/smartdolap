/// Interface for syncing Firestore data to Hive cache
/// Follows Dependency Inversion Principle (DIP)
abstract class ISyncService {
  /// Syncs all user data from Firestore to Hive
  /// Called after login/register to ensure local cache is up-to-date
  Future<void> syncUserData({required String userId});
}
