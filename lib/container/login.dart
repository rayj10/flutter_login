import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../component/form_input.dart';
import '../container/home.dart';
import '../utils/fetch.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  List<Map> fields = [
    {
      'key': 'staffID',
      'label': 'Staff Id',
      'value': '',
      'secure': false,
      'error': null,
      'controller': new TextEditingController()
    },
    {
      'key': 'password',
      'label': 'Password',
      'value': '',
      'secure': true,
      'error': null,
      'controller': new TextEditingController()
    }
  ];

  final _formKey = GlobalKey<FormState>();
  bool isSubmitted = false;
  String progressText = '';

  void _onSubmit(String key, String value) {
    Map element = fields.firstWhere((e) => e['key'] == key);
    element['value'] = value;
  }

  @override
  void dispose() {
    fields.forEach((e) {
      e['controller'].dispose();
    });
    super.dispose();
  }

  void _onError(err) {
    switch (err.code) {
      case 'ERROR_WRONG_PASSWORD':
        fields[1]['error'] = err.message;
        break;
      default:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(err.code),
              content: Text(err.message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        break;
    }
  }

  void _firebaseLogin(String email, String password, Function callback) {
    this.setState(() {
      progressText = 'Getting user info...';
    });

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
      //once username and password checks out
      //empty fields
      this.setState(() {
        fields.forEach((e) {
          e['value'] = '';
          e['controller'].clear();
          isSubmitted = false;
        });
      });
      callback(user, true);
    }).catchError((err) {
      //if user not registered, register user straightaway
      if (err.code == 'ERROR_USER_NOT_FOUND') {
        this.setState(() {
          progressText = 'User not found,\nCreating new account...';
        });

        FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) {
          //empty fields
          this.setState(() {
            fields.forEach((e) {
              e['value'] = '';
              e['controller'].clear();
              isSubmitted = false;
            });
          });
          callback(user, false);
        });
      } else {
        this.setState(() {
          this._onError(err);
          isSubmitted = false;
        });
      }
    });
  }

  void _onLogin() {
    this.setState(() {
      isSubmitted = true;
      progressText = 'Validating fields...';
      //clear out previous error messages
      fields.forEach((e) {
        e['error'] = null;
      });
    });

    final formContent = _formKey.currentState;
    if (formContent.validate()) {
      this.setState(() {
        progressText = 'Looking up staff id...';
      });

      formContent.save(); //calling onSubmit for each field
      String staffID = fields[0]['value'];
      String password = fields[1]['value'];

      httpGet('api.php?method=DetailStaff&staff_id=$staffID&key=xkRKJui9acBcx4CG/HCeboyIDF==')
          .then((json) {
        Map userDetail = json['Detail'];
        String email = userDetail['EMAIL'];

        if (email != '') {
          //user is on intranet
          _firebaseLogin(email, password, (FirebaseUser user, bool exists) {
            //add user info to firestore if this is a newly created user
            if (!exists)
              Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .setData({
                'staffID': staffID,
                'name': userDetail['FULLNAME'],
                'division': userDetail['DIVISION_NAME']
              });

            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
            );
          });
        } else {
          this.setState(() {
            fields[0]['error'] = 'Staff Id not found';
            isSubmitted = false;
          });
        }
      }).catchError((err) {
        this.setState(() {
          this._onError(err);
          isSubmitted = false;
        });
      });
    } else {
      //form validation fails
      this.setState(() {
        isSubmitted = false;
      });
    }
  }

  Widget renderButton() {
    if (!isSubmitted)
      return ButtonTheme(
        height: 60,
        child: RaisedButton(
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.white,
            ),
          ),
          color: Color(0xFF004071),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: () => _onLogin(),
        ),
      );
    else
      return Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              value: null,
              strokeWidth: 5.0,
            ),
            SizedBox(height: 15),
            Text(
              progressText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 50, 0, 25),
              child: FormInput(
                  fields: fields, onSave: _onSubmit, formKey: _formKey),
            ),
            renderButton(),
          ],
        ),
      ),
    );
  }
}
