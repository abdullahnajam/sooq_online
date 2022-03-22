import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/admin_search_list.dart';
import 'package:propertymarket/language_selection.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/screens/message.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 2;
  User user;

  getCurrentUser()async{
    user=await FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/video/splash.mp4");
    _initializeVideoPlayerFuture = _controller.initialize();
    FirebaseFirestore.instance.collection('data').doc('data').get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if(data['active']=='yes'){
          _loadWidget();
          getCurrentUser();
        }
        else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Message(data['message'])));
        }

      }
      else {
        print('Document does not exist on the database');
      }
    });

  }
  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }
  void navigationPage() async{
    _controller.pause();
    SharedPref sharedPref=SharedPref();
    sharedPref.getFirstTimePref().then((value) => {
      if(value){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LanguageSelection()))
      }
      else{
        FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => BottomBar(0)));
      } else {
        if(user.uid==adminId){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AdminSearchList()));
        }
        else
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => BottomBar(0)));

      }
    })
      }
    });




  }
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset("assets/video/splash.gif",fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,),
          /*child:FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _controller.play();
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  //child: CircularProgressIndicator(),
                );
              }
            },
          ),*/

      ),
    );
  }
}

