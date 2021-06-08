import 'dart:io';

import 'package:e_grocery_partner/model/dialog_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class AuthenticationProvider with ChangeNotifier  {

  void addName(String name) {
    final firestoreInstance = FirebaseFirestore.instance;
    var firebaseUser =  FirebaseAuth.instance.currentUser;
    firestoreInstance.collection("shop_owner").doc(firebaseUser.uid).set(
        {
          "name" : name,
        }).then((_){
      print("success!");
    });
  }

  void login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return showDialog(
            context: context,
            builder:(_) => CustomAlertDialog(
              title: 'Sign in',
              description: 'Sorry, we cant\'t find an account with this email address. Please try again or create a new account.',
              bText: 'Try again',
            )
        );
      } else if (e.code == 'wrong-password') {
        return showDialog(
          context: context,
          builder:(_) => CustomAlertDialog(
            title: 'Incorrect Password',
            description: 'Your username or password is incorrect.',
            bText: 'Try again',
          )
        );
      }
    }
  }

  void signUp(String name, String email, String password, BuildContext context) async {

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email,
          password: password);
      addName(name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        return showDialog(
            context: context,
            builder:(_) => CustomAlertDialog(
              title: 'Email address already in use',
              description: 'Please sign in.',
              bText: 'OK',
            )
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void signInWithGoogle() async {

    DocumentSnapshot _data;
    var _userName;
    User _user;

    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      // Once signed in, return the UserCredential
      UserCredential userCredential =  await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;
      final uid = _user.uid;
      _data = await FirebaseFirestore.instance.collection("shop_owner").doc(uid).get();
      _userName = _data['name'];
    }
    catch (e){
      print(e);
      addName(_user.displayName);
    }
  }

  void addLocation(double latitude, double longitude, String address, String streetAddress) {
    final firestoreInstance = FirebaseFirestore.instance;
    var firebaseUser =  FirebaseAuth.instance.currentUser;
    firestoreInstance.collection("shop_owner").doc(firebaseUser.uid).update(
        {
          "location" : GeoPoint(latitude, longitude),
          "address" : address,
          "latitude": latitude,
          "longitude": longitude,
          "street_address": streetAddress,
        }).then((_){
      print("successfully added location!");
    });
  }

  void signOut() async{
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().disconnect();
      await GoogleSignIn().signOut();
    } catch (e) {
      print("User not signed in with google");
    } finally {
      notifyListeners();
    }

  }

  void addData(String shopName, String imageUrl) {
    final firestoreInstance = FirebaseFirestore.instance;
    var firebaseUser = FirebaseAuth.instance.currentUser;
    firestoreInstance.collection("shop_owner").doc(firebaseUser.uid).set({
      "shop_name": shopName,
      "profile_pic": imageUrl,
    }, SetOptions(merge: true)).then((_) {
      print("success!");
    });
  }

  Future submitInfo(PickedFile imageFile, String shopName) async {
    String _basePath = Path.basename(imageFile.path);
    FirebaseStorage _firebaseStorageRef = FirebaseStorage.instance;
    Reference _reference = _firebaseStorageRef.ref().child('Profile/$_basePath');
    UploadTask _uploadTask = _reference.putFile(File(imageFile.path));
    _uploadTask.whenComplete(() async {
      String _downloadLink = await _reference.getDownloadURL();
      print("url Set completed......");
      addData(shopName, _downloadLink);
    });
  }

}
