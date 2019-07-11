import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/button.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  height: 100.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              Flexible(
                child: SizedBox(
                  height: 40.0,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Password',
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Button(
                text: 'Register',
                color: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    inAsyncCall = true;
                  });
                  try {
                    final user = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Navigator.pushNamed(
                        context,
                        ChatScreen.id,
                      );
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      inAsyncCall = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
