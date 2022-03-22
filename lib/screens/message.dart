import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  String message;

  Message(this.message);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.message,style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
