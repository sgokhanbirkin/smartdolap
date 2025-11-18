import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/food_preferences/data/food_preferences_data.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/user_food_preferences.dart';
import 'package:smartdolap/features/food_preferences/domain/repositories/i_food_preference_repository.dart';

/// Firestore implementation of food preference repository
class FoodPreferenceRepositoryImpl implements IFoodPreferenceRepository {
  /// Food preference repository constructor
  FoodPreferenceRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _users = 'users';
  static const String _foodPreferences = 'foodPreferences';

  @override
  Future<List<FoodPreference>> getAllFoodPreferences() async {
    // For now, return static data
    // Later can be moved to Firestore for easier updates
    return FoodPreferencesData.getAllFoodPreferences();
  }

  @override
  Future<void> saveUserFoodPreferences(
    UserFoodPreferences preferences,
  ) async {
    await _firestore
        .collection(_users)
        .doc(preferences.userId)
        .collection(_foodPreferences)
        .doc('current')
        .set(preferences.toJson());
  }

  @override
  Future<UserFoodPreferences?> getUserFoodPreferences(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(_users)
        .doc(userId)
        .collection(_foodPreferences)
        .doc('current')
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return UserFoodPreferences.fromJson(snapshot.data()!);
  }

  @override
  Stream<UserFoodPreferences?> watchUserFoodPreferences(String userId) {
    return _firestore
        .collection(_users)
        .doc(userId)
        .collection(_foodPreferences)
        .doc('current')
        .snapshots()
        .map(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.exists
                  ? UserFoodPreferences.fromJson(snapshot.data()!)
                  : null,
        );
  }

  @override
  Future<Map<String, dynamic>> getHouseholdFoodPreferences(
    String householdId,
  ) async {
    // Get all members of the household
    final QuerySnapshot<Map<String, dynamic>> membersSnapshot =
        await _firestore
            .collection('households')
            .doc(householdId)
            .collection('members')
            .get();

    final List<String> memberIds = membersSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            doc.data()['userId'] as String)
        .toList();

    // Get food preferences for all members
    final List<UserFoodPreferences> allPreferences = <UserFoodPreferences>[];
    for (final String memberId in memberIds) {
      final UserFoodPreferences? prefs = await getUserFoodPreferences(memberId);
      if (prefs != null) {
        allPreferences.add(prefs);
      }
    }

    // Aggregate preferences
    final Set<String> allFoodIds = <String>{};
    final Map<String, List<String>> mealTypeProducts = <String, List<String>>{
      'breakfast': <String>[],
      'lunch': <String>[],
      'dinner': <String>[],
      'snack': <String>[],
    };

    for (final UserFoodPreferences prefs in allPreferences) {
      allFoodIds.addAll(prefs.selectedFoodIds);
      mealTypeProducts['breakfast']!.addAll(prefs.mealTypePreferences.breakfast);
      mealTypeProducts['lunch']!.addAll(prefs.mealTypePreferences.lunch);
      mealTypeProducts['dinner']!.addAll(prefs.mealTypePreferences.dinner);
      mealTypeProducts['snack']!.addAll(prefs.mealTypePreferences.snack);
    }

    return <String, dynamic>{
      'selectedFoodIds': allFoodIds.toList(),
      'mealTypeProducts': <String, List<String>>{
        'breakfast': mealTypeProducts['breakfast']!.toSet().toList(),
        'lunch': mealTypeProducts['lunch']!.toSet().toList(),
        'dinner': mealTypeProducts['dinner']!.toSet().toList(),
        'snack': mealTypeProducts['snack']!.toSet().toList(),
      },
    };
  }
}

