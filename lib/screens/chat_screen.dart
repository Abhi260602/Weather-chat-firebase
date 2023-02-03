import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/clima/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final cloud_firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try{
    final  user = await  _auth.currentUser;
    if(user!= null){
      loggedInUser=user;
      print(loggedInUser.email);
    }
    }
    catch (e){
      print(e);
    }
  }
    
    void messagesStream() async{
      await for(var snapshot in cloud_firestore.collection('messages').snapshots()) {
            for(var message in snapshot.docs){
              print(message.data());
            }
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(onPressed: (){
                Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context)=>LocationScreen()));
              }, icon: Icon(Icons.cloud)),
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
               _auth.signOut();
               Navigator.pop(context);
              }),
              
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
        
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: cloud_firestore.collection('messages').snapshots(),
              // ignore: missing_return
              builder:(context, snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 198, 240, 15),
                      ),
                  );
                }
                  final messages = snapshot.data.docs;
                  List<Text> messageWidgets = [];
                  for (var message in messages){
                    // ignore: unused_local_variable
                    final messageText = message.data();
                    final messageSender = message.data();

                    final messageWidget = Text('$messageText from $messageSender',);
                    messageWidgets.add(messageWidget);
                  }
                  return Column(
                    children: messageWidgets,
                  );
              },
              ) ,
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      cloud_firestore.collection('messages').add({
                        'sender': loggedInUser.email,
                        'text': messageText
                      }
                      );
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