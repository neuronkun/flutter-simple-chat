import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _db = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String text = '';
  final textController = TextEditingController();
  bool inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      print(user);
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                await _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
        title: Text('⚡️Flutter Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: MessageStream(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        setState(() {
                          text = value;
                        });
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      _db.collection('messages').document().setData(
                          {'text': text, 'author': loggedInUser.email});
                      setState(() {
                        text = '';
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;

        return ListView(
            reverse: true,
            children: messages.map(
              (message) {
                return MessageBubble(
                  text: message.data['text'],
                  author: message.data['author'],
                  isMe: loggedInUser != null &&
                      (loggedInUser.email == message.data['author']),
                );
              },
            ).toList());
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.author, this.isMe});

  final String text;
  final String author;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              author,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
              elevation: 5,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15),
                ),
              ),
            )
          ],
        ));
  }
}
