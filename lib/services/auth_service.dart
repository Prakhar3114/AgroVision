// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Check if user is logged in ──────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // ─── Get current user display name ───────────────────────────────────────
  static String getUserName() {
    final user = _auth.currentUser;
    if (user == null) return 'User';
    return user.displayName ?? user.email?.split('@').first ?? 'User';
  }

  // ─── Get current user email ───────────────────────────────────────────────
  static String getUserEmail() {
    return _auth.currentUser?.email ?? '';
  }

  // ─── Sign Up with Email + Password ───────────────────────────────────────
  static Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Try again.'};
    }
  }

  // ─── Sign In with Email + Password ───────────────────────────────────────
  static Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Try again.'};
    }
  }

  // ─── Sign In with Google ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'error': 'Google sign-in cancelled.'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'Google sign-in failed. Try again.'};
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendPasswordReset(
      String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Human-friendly Firebase error messages ───────────────────────────────
  static String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Sign in instead.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}