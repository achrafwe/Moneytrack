import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Existing methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // New user stream method
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map((User? user) {
      return user != null ? UserModel(uid: user.uid, email: user.email!, role: 'user') : null;
    });
  }
}
