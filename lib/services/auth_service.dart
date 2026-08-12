import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_fix/models/app_user.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> loadProfile(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return AppUser.fromMap(snapshot.data()!..putIfAbsent('id', () => user.uid));
  }

  Future<AppUser> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = result.user!;
    final profile = await loadProfile(user);
    if (profile == null) {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No se encontró el perfil del usuario.');
    }
    return profile;
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> registerStudent(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = result.user!;
    final profile = AppUser(
      id: user.uid,
      name: name,
      email: user.email ?? email,
      role: UserRole.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }
}
