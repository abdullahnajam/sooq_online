import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:toast/toast.dart';

class FacebookSignIn extends StatefulWidget {
  @override
  _FacebookSignInState createState() => _FacebookSignInState();
}

class _FacebookSignInState extends State<FacebookSignIn> {
  bool isSignIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  FacebookLogin facebookLogin = FacebookLogin();




  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: () async{
        await handleLogin().then((value){
          final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
          _firebaseMessaging.subscribeToTopic('user');
          _firebaseMessaging.getToken().then((value) {
            print(value);
            print("hello");
            //User user=FirebaseAuth.instance.currentUser;
            //print("user id :  ${user.uid}");
            final databaseReference = FirebaseDatabase.instance.reference();
            databaseReference.child("userData").child(FirebaseAuth.instance.currentUser.uid).set({
              'token': value,
              'id' : FirebaseAuth.instance.currentUser.uid,
              'email': FirebaseAuth.instance.currentUser.email,
              'username' : FirebaseAuth.instance.currentUser.displayName,
              'profile': FirebaseAuth.instance.currentUser.photoURL,
            }).then((value) => Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: BottomBar(0))));

          });
        });
      },
      child: Container(
          height: 45,
          padding: EdgeInsets.only(left: 10,right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color(0xff4267B2),

          ),
          alignment: Alignment.center,
          margin: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/facebook.png',width: 30,height: 30,),
              SizedBox(width: 20,),
              Text("Sign in with Facebook",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w400),),
            ],
          )
      ),
    );
  }


  Future<void> handleLogin() async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("result status is : cancelled by user");
        break;
      case FacebookLoginStatus.error:
        //_showErrorOnUI(result.errorMessage);
        print("result status is : ${result.errorMessage}");
        break;
      case FacebookLoginStatus.loggedIn:
        print("result status is : logged in ");
        try {
          await loginWithfacebook(result);
        } catch (e) {
          print(e);
        }
        break;
    }
  }

  Future loginWithfacebook(FacebookLoginResult result) async {
    final ProgressDialog pr = ProgressDialog(context);
    try
  {
    await pr.show();
    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
    var a = await _auth.signInWithCredential(credential).whenComplete(() => pr.hide());
    setState(() {
      isSignIn = true;
      _user = a.user;
    });
  } on FirebaseAuthException catch (e) {
      print("error code is : ${e.code}");
    if (e.code == 'account-exists-with-different-credential') {
      pr.hide();
      Toast.show("Account Exists with different Credentials", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);

      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      pr.hide();
      Toast.show("Wrong Password", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      print('Wrong password provided for that user.');
    }
  }



  }

  Future<void> facebookSignout() async {
    await _auth.signOut().then((onValue) {
      setState(() {
        facebookLogin.logOut();
        isSignIn = false;
      });
    });
  }






}