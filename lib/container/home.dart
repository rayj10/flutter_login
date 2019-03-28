import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../container/login.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) {
      this.setState(() {
        user = currentUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text('Welcome ${user != null ? user.uid : ''}!'),
            ),
            Center(
              child: RaisedButton(
                child: Text('Log Out'),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Login()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
