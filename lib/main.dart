import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './container/login.dart';
import './container/home.dart';

void main() => runApp(LoginApp());

class LoginApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginAppState();
  }
}

class _LoginAppState extends State<LoginApp> {
  FirebaseUser user;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) {
      this.setState(() {
        user = currentUser;
        isReady = true;
      });
    });
  }

  // Root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isReady && user == null ? Login() : Home(),
    );
  }
}
