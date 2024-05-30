import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneytracker/exception/auth_exception_handler.dart';
import 'package:moneytracker/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AuthResultStatus> login({required String email, required String password}) async {
    AuthResultStatus status;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      status = AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      status = AuthExceptionHandler.handleException(e);
    } catch (e) {
      status = AuthResultStatus.undefined;
    }
    return status;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isCommercial(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && userDoc['role'] == 'commercial';
  }

  Future<AuthResultStatus> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
    required String dateNaissance,
    required String adresse,
    required String numsalarier,
    required String teleportable,
    String? commercialId,
  }) async {
    AuthResultStatus status;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        role: role,
        adresse: adresse,
        numsalarier: numsalarier,
        dateNaissance: dateNaissance,
        teleportable: teleportable,
        commercialId: commercialId,
      );
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      status = AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      status = AuthExceptionHandler.handleException(e);
    } catch (e) {
      status = AuthResultStatus.undefined;
    }
    return status;
  }
}
