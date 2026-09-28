import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _webClientId =
      '544739576393-fgjksm7n1mr8udj9t1r62mtkah6rfccv.apps.googleusercontent.com';

  // Se llama una sola vez desde main()
  static Future<void> initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId:
            '544739576393-fgjksm7n1mr8udj9t1r62mtkah6rfccv.apps.googleusercontent.com',
        serverClientId:
            '544739576393-fgjksm7n1mr8udj9t1r62mtkah6rfccv.apps.googleusercontent.com',
      );
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignIn ya inicializado o error menor: $e');
    } catch (e) {
      debugPrint('GoogleSignIn init: $e');
    }
  }

  // Inicio de sesión con Google
  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return null;

    return _getOrCreateUserDoc(user);
  }

  Future<AppUser> _getOrCreateUserDoc(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return AppUser.fromMap(user.uid, doc.data()!);
    }

    final newUser = AppUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      role: 'user',
    );

    await docRef.set(newUser.toMap());

    return newUser;
  }

  // Registro con correo y contraseña
  Future<AppUser?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user == null) return null;

    await user.updateDisplayName(name);

    final newUser = AppUser(
      uid: user.uid,
      name: name,
      email: email,
      role: 'user',
    );

    await _db.collection('users').doc(user.uid).set(newUser.toMap());

    return newUser;
  }

  // Inicio de sesión con correo y contraseña
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      // Por seguridad, si el documento no existe lo creamos
      final newUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        role: 'user',
      );

      await _db.collection('users').doc(user.uid).set(newUser.toMap());

      return newUser;
    }

    return AppUser.fromMap(user.uid, doc.data()!);
  }

  // Traduce los códigos de error de Firebase a mensajes entendibles
  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';

      case 'email-already-in-use':
        return 'Ese correo ya está registrado';

      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';

      case 'invalid-email':
        return 'El formato del correo no es válido';

      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  // Actualizar nombre
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await user.updateDisplayName(newName);

    await _db.collection('users').doc(user.uid).update({'name': newName});
  }

  // Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await user.updatePassword(newPassword);
  }

// Enviar correo de recuperación de contraseña
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  User? get currentUser => _auth.currentUser;
}