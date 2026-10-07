import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// User Data Provider
final userDataProvider = StateNotifierProvider<UserDataNotifier, AsyncValue<UserModel?>>((ref) {
  return UserDataNotifier(ref);
});

class UserDataNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  final DatabaseService _db = DatabaseService();

  UserDataNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // 1. Check existing auth state immediately
    final currentAuth = ref.read(authStateProvider);
    currentAuth.when(
      data: (user) {
        if (user != null) {
          loadUserData(user.uid);
        } else {
          state = const AsyncValue.data(null);
        }
      },
      loading: () => state = const AsyncValue.loading(),
      error: (err, stack) => state = AsyncValue.error(err, stack),
    );

    // 2. Listen for future auth state changes
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            loadUserData(user.uid);
          } else {
            state = const AsyncValue.data(null);
          }
        },
        loading: () => state = const AsyncValue.loading(),
        error: (err, stack) => state = AsyncValue.error(err, stack),
      );
    });
  }

  Future<void> loadUserData(String firebaseUid) async {
    state = const AsyncValue.loading();
    try {
      var userData = await _db.getUserByFirebaseUid(firebaseUid).timeout(
        const Duration(seconds: 5),
      );

      // If user doesn't exist in Supabase yet, create or provide fallback
      if (userData == null) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          try {
            userData = await _db.createUser(
              firebaseUid: firebaseUser.uid,
              username: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
            ).timeout(const Duration(seconds: 5));
          } catch (createErr) {
            // If database table is unreachable or not yet migrated, construct fallback
            userData = UserModel(
              id: firebaseUser.uid,
              firebaseUid: firebaseUser.uid,
              username: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email,
              level: 1,
              exp: 0,
              coins: 0,
              dailyStreak: 1,
              lastLoginDate: DateTime.now(),
            );
          }
        }
      }

      state = AsyncValue.data(userData);
    } catch (e) {
      // If network/database error occurs, provide fallback user from Firebase auth
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final fallbackUser = UserModel(
          id: firebaseUser.uid,
          firebaseUid: firebaseUser.uid,
          username: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email,
          level: 1,
          exp: 0,
          coins: 0,
          dailyStreak: 1,
          lastLoginDate: DateTime.now(),
        );
        state = AsyncValue.data(fallbackUser);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> updateUser(Map<String, dynamic> updates) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _db.updateUser(currentUser.id, updates).timeout(
        const Duration(seconds: 5),
      );
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      // Update local state even if offline
      state = AsyncValue.data(
        UserModel(
          id: currentUser.id,
          firebaseUid: currentUser.firebaseUid,
          username: currentUser.username,
          email: currentUser.email,
          level: currentUser.level,
          exp: currentUser.exp,
          coins: currentUser.coins,
          dailyStreak: currentUser.dailyStreak,
          fitnessGoal: updates['fitness_goal'] ?? currentUser.fitnessGoal,
          age: updates['age'] ?? currentUser.age,
          weightKg: updates['weight_kg'] != null
              ? (updates['weight_kg'] as num).toDouble()
              : currentUser.weightKg,
          heightCm: updates['height_cm'] != null
              ? (updates['height_cm'] as num).toDouble()
              : currentUser.heightCm,
          bodyShape: updates['body_shape'] ?? currentUser.bodyShape,
          lastLoginDate: currentUser.lastLoginDate,
        ),
      );
    }
  }

  Future<void> updateDailyStreak() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _db.updateDailyStreak(currentUser.id).timeout(
        const Duration(seconds: 5),
      );
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      // Silently ignore streak update failure if offline
    }
  }
}

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _db = DatabaseService();

  AuthService(this.ref);

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    // Obtain auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user exists in database
    final existingUser = await _db.getUserByFirebaseUid(userCredential.user!.uid);

    if (existingUser == null) {
      // Create new user in database
      await _db.createUser(
        firebaseUid: userCredential.user!.uid,
        username: userCredential.user!.displayName ?? 'User',
        email: userCredential.user!.email ?? '',
      );
    }

    return userCredential;
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
