import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sahel_alik/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(String name, String email,
      String password, String phone, bool isServiceProvider) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Profile image url
        final profileImageUrl =
            "https://api.dicebear.com/5.x/initials/png?seed=$name";

        // Create a UserModel
        UserModel user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          type: isServiceProvider ? 'provider' : 'searcher',
          profileImage: profileImageUrl,
        );

        // Save user to Firestore 'users' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());

        return user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          // If user doesn't exist, return null to navigate to registration completion
          return null;
        } else {
          // If user exists, return existing user model
          return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print("Error signing in with Google: ${e.toString()}");
      return null;
    }
  }

  // Register with google - to complete registration after google sign in
  Future<UserModel?> registerWithGoogle(
      String name, String email, String phone, bool isServiceProvider) async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Profile image url
        final profileImageUrl =
            "https://api.dicebear.com/5.x/initials/png?seed=$name";

        // Update UserModel
        UserModel user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          type: isServiceProvider ? 'provider' : 'searcher',
          profileImage: profileImageUrl,
        );

        // Update user in Firestore 'users' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update(user.toJson());

        return user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Fetch user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print("Error signing in: ${e.toString()}"); // Print detailed error
      return null;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Sign out
  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching user by ID: ${e.toString()}");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
