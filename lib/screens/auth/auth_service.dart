import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Initiate the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In was canceled by the user.');
        return null; // User canceled the sign-in
      }

      // Obtain the authentication details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Ensure tokens are not null
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Error: Access token or ID token is null.');
        return null;
      }

      // Create Firebase credentials with the tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Return the signed-in Firebase user
      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();

      print('User signed out successfully.');
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }
}
