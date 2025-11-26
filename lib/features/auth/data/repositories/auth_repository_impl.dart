import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/data/models/user_model.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';

/// Auth repository implementation - Data layer
class AuthRepositoryImpl implements IAuthRepository {
  /// Auth repository implementation constructor
  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  /// Firebase auth instance
  final fb.FirebaseAuth _firebaseAuth;

  /// Firestore instance
  final FirebaseFirestore _firestore;

  @override
  Future<domain.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final fb.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        // ignore: only_throw_errors
        throw const AuthFailure.invalidCredentials();
      }

      return UserModel.fromFirebaseUser(userCredential.user!).toEntity();
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          // ignore: only_throw_errors
          throw const AuthFailure.invalidCredentials();
        case 'network-request-failed':
          // ignore: only_throw_errors
          throw const AuthFailure.network();
        default:
          // ignore: only_throw_errors
          throw AuthFailure.unknown(e.message);
      }
    } catch (e) {
      if (e is AuthFailure) {
        rethrow;
      }
      // ignore: only_throw_errors
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<domain.User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final fb.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        // ignore: only_throw_errors
        throw const AuthFailure.unknown('User creation failed');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      return UserModel.fromFirebaseUser(userCredential.user!).toEntity();
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          // ignore: only_throw_errors
          throw const AuthFailure.emailAlreadyInUse();
        case 'weak-password':
          // ignore: only_throw_errors
          throw const AuthFailure.weakPassword();
        case 'network-request-failed':
          // ignore: only_throw_errors
          throw const AuthFailure.network();
        default:
          // ignore: only_throw_errors
          throw AuthFailure.unknown(e.message);
      }
    } catch (e) {
      if (e is AuthFailure) {
        rethrow;
      }
      // ignore: only_throw_errors
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // ignore: only_throw_errors
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final fb.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Fetch householdId from Firestore
      String? householdId;
      String? avatarId;
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final Map<String, dynamic>? data = userDoc.data();
          householdId = data?['householdId'] as String?;
          avatarId = data?['avatarId'] as String?;
        }
      } catch (e) {
        // Silently fail - householdId might not exist yet
      }

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        householdId: householdId,
        avatarId: avatarId,
      ).toEntity();
    } catch (e) {
      // ignore: only_throw_errors
      throw AuthFailure.unknown(e.toString());
    }
  }

  @override
  Stream<domain.User?> get currentUserStream =>
      _firebaseAuth.authStateChanges().asyncMap((fb.User? firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }

        // Fetch householdId and avatarId from Firestore
        String? householdId;
        String? avatarId;
        try {
          final DocumentSnapshot<Map<String, dynamic>> userDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (userDoc.exists) {
            final Map<String, dynamic>? data = userDoc.data();
            householdId = data?['householdId'] as String?;
            avatarId = data?['avatarId'] as String?;
          }
        } catch (e) {
          // Silently fail - householdId might not exist yet
        }

        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          householdId: householdId,
          avatarId: avatarId,
        ).toEntity();
      }).asyncExpand((domain.User? user) {
        if (user == null) {
          return Stream<domain.User?>.value(null);
        }

        // Listen to Firestore user document changes for householdId updates
        return _firestore
            .collection('users')
            .doc(user.id)
            .snapshots()
            .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          // If document doesn't exist, return user without householdId
          if (!snapshot.exists) {
            return UserModel(
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              photoUrl: user.photoUrl,
            ).toEntity();
          }

          final Map<String, dynamic>? data = snapshot.data();
          final String? householdId = data?['householdId'] as String?;
          final String? avatarId = data?['avatarId'] as String?;

          // Return updated user with latest householdId
          return UserModel(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
            householdId: householdId,
            avatarId: avatarId,
          ).toEntity();
        });
      });
}
