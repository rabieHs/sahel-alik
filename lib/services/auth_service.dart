import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahel_alik/models/user.dart'; // Import UserModel

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
