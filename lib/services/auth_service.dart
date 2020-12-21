import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:flutter_twitter/flutter_twitter.dart';

import '../models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TwitterLogin _twitterLogin = TwitterLogin(
    consumerKey: 'uZc5N8JN9SZRmt6pvtxD8GbjX',
    consumerSecret: 'cf9dAmUqaPBYQ8672lT3kiaqz7pcZwtDBjHZBUTAeroichqxcJ',
  );

  // Sign Up with Email & Password
  Future<User> signUp(String username, String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser firebaseUser = result.user;
      await DatabaseService(firebaseUser.uid)
          .addUser(username, email, null, 'email');
      return _convertFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In with Email & Password
  Future<User> signIn(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser user = result.user;
      return _convertFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In with Google
  Future<User> googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      AuthResult result = await _firebaseAuth.signInWithCredential(credential);
      FirebaseUser user = result.user;

      if (await DatabaseService(user.uid).isUserExisting() == false) {
        await DatabaseService(user.uid)
            .addUser(user.displayName, user.email, user.photoUrl, 'google');
      }
      return _convertFirebaseUser(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Sign In with Twitter
  Future<User> twitterSignIn() async {
    final TwitterLoginResult loginResult = await _twitterLogin.authorize();
    try {
      if (loginResult.status == TwitterLoginStatus.loggedIn) {
        AuthCredential credential = TwitterAuthProvider.getCredential(
          authToken: loginResult.session.token,
          authTokenSecret: loginResult.session.secret,
        );
        FirebaseUser user =
            (await _firebaseAuth.signInWithCredential(credential)).user;
        if (await DatabaseService(user.uid).isUserExisting() == false) {
          await DatabaseService(user.uid)
              .addUser(user.displayName, user.email, user.photoUrl, 'twitter');
        }
        return _convertFirebaseUser(user);
      } else if (loginResult.status == TwitterLoginStatus.cancelledByUser) {
        print('Twitter Login cancelled by User!');
        return null;
      }
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // User Authentication Stream
  Stream<User> get user {
    return _firebaseAuth.onAuthStateChanged
        .map((firebaseUser) => _convertFirebaseUser(firebaseUser));
  }

  // Convert FirebaseUser into User
  User _convertFirebaseUser(FirebaseUser user) {
    return user != null
        ? User(
            uid: user.uid,
            userName: user.displayName != null ? user.displayName : '',
            email: user.email,
          )
        : null;
  }

  // Sign Out
  Future<Null> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _twitterLogin.logOut();
  }

  // Reset User password
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Changes the User E-Mail-Address
  Future<bool> changeEmail(
      Future<FirebaseUser> currentUser, String newEmail) async {
    try {
      FirebaseUser user = await currentUser;
      await user.updateEmail(newEmail);
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }

  Future deleteAccount(Future<FirebaseUser> currentUser, String password,
      String authMethod) async {
    FirebaseUser user = await currentUser;
    if (authMethod == 'email') {
      AuthCredential credential = EmailAuthProvider.getCredential(
          email: user.email, password: password);
      user.reauthenticateWithCredential(credential).whenComplete(() async {
        await user.delete();
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .delete();
      });
    } else if (authMethod == 'google') {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      user.reauthenticateWithCredential(credential).whenComplete(() async {
        await user.delete();
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .delete();
      });
    } else if (authMethod == 'twitter') {
      TwitterLoginResult loginResult = await _twitterLogin.authorize();
      AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: loginResult.session.token,
        authTokenSecret: loginResult.session.secret,
      );
      user.reauthenticateWithCredential(credential).whenComplete(() async {
        await user.delete();
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .delete();
      });
    }
  }
}
