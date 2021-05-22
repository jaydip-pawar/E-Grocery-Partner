import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_grocery_partner/screens/complete_profile.dart';
import 'package:e_grocery_partner/screens/home_page.dart';
import 'package:e_grocery_partner/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigatePage extends StatefulWidget {
  const NavigatePage({Key key}) : super(key: key);

  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {

  FirebaseAuth _auth;
  User _user;
  String _uid;

  getValues() async {
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    if (_user != null)
      _uid = _user.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getValues();
  }

  @override
  Widget build(BuildContext context) {
    getValues();
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (userSnapshot.hasData) {
          _uid = FirebaseAuth.instance.currentUser.uid;
          return FutureBuilder(
            future: Future.wait([FirebaseFirestore.instance.collection("shop_owner").doc(_uid).get()]),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                DocumentSnapshot doc = snapshot.data[0];
                if (doc.exists) {
                  if(doc.data().length > 1) {
                    if (doc["profile_pic"] != null && doc["shop_name"] != null) {
                      return HomePage();
                    }
                  }
                }
                return CompleteProfile();
              }
              return Center(child: CircularProgressIndicator(),);
            },
          );
        }
        return LoginPage();
      },
    );
  }
}
