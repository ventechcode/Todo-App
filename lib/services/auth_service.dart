import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todoapp/services/database_service.dart';
import 'package:flutter_twitter/flutter_twitter.dart';

import '../models/user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TwitterLogin _twitterLogin = TwitterLogin(
    consumerKey: 'uZc5N8JN9SZRmt6pvtxD8GbjX',
    consumerSecret: 'cf9dAmUqaPBYQ8672lT3kiaqz7pcZwtDBjHZBUTAeroichqxcJ',
  );

  // Sign Up with Email & Password
  Future<User> signUp(String username, String email, String password) async {
    try {
      auth.UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User fbUser = result.user;
      await DatabaseService(fbUser.uid).addUser(username, email, null, 'email');
      return _convertFirebaseUser(fbUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In with Email & Password
  Future<User> signIn(String email, String password) async {
    try {
      auth.UserCredential result =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User fbUser = result.user;
      return _convertFirebaseUser(fbUser);
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

      auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      auth.UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);
      auth.User fbUser = result.user;

      if (await DatabaseService(fbUser.uid).isUserExisting() == false) {
        await DatabaseService(fbUser.uid).addUser(
            fbUser.displayName, fbUser.email, fbUser.photoURL, 'google');
      }
      return _convertFirebaseUser(fbUser);
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
        auth.AuthCredential credential = auth.TwitterAuthProvider.credential(
          accessToken: loginResult.session.token,
          secret: loginResult.session.secret,
        );
        auth.User fbUser =
            (await _firebaseAuth.signInWithCredential(credential)).user;
        if (await DatabaseService(fbUser.uid).isUserExisting() == false) {
          await DatabaseService(fbUser.uid).addUser(
              fbUser.displayName, fbUser.email, fbUser.photoURL, 'twitter');
        }
        return _convertFirebaseUser(fbUser);
      } else if (loginResult.status == TwitterLoginStatus.cancelledByUser) {
        print('Twitter Login cancelled by User!');
        return null;
      }
      return null;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // User Authentication Stream
  Stream<User> get user {
    return _firebaseAuth
        .authStateChanges()
        .map((auth.User fbUser) => _convertFirebaseUser(fbUser));
  }

  // Convert auth.User into User
  User _convertFirebaseUser(auth.User user) {
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
  Future<bool> changeEmail(auth.User fbUser, String newEmail) async {
    try {
      await fbUser.updateEmail(newEmail);
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }

  Future deleteAccount(
      auth.User fbUser, String password, String authMethod) async {
    if (authMethod == 'email') {
      auth.AuthCredential credential = auth.EmailAuthProvider.credential(
          email: fbUser.email, password: password);
      fbUser.reauthenticateWithCredential(credential).whenComplete(() async {
        await fbUser.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUser.uid)
            .delete();
      });
    } else if (authMethod == 'google') {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      fbUser.reauthenticateWithCredential(credential).whenComplete(() async {
        await fbUser.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUser.uid)
            .delete();
      });
    } else if (authMethod == 'twitter') {
      TwitterLoginResult loginResult = await _twitterLogin.authorize();
      auth.AuthCredential credential = auth.TwitterAuthProvider.credential(
        accessToken: loginResult.session.token,
        secret: loginResult.session.secret,
      );
      fbUser.reauthenticateWithCredential(credential).whenComplete(() async {
        await fbUser.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUser.uid)
            .delete();
      });
    }
  }
}
