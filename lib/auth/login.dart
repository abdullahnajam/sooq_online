import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:propertymarket/auth/Facebook_SignIn.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/admin/admin_home.dart';
import 'package:propertymarket/admin/admin_search_list.dart';
import 'package:propertymarket/auth/register.dart';
import 'package:propertymarket/components/form_error.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/screens/home.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:easy_localization/easy_localization.dart';

import 'Google_SignIn.dart';
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  bool remember = false;
  final List<String> errors = [];

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Container(
            child: Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back,color: Colors.white,),
                ),
                SizedBox(width: 10,),
                Text('signin'.tr(),style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),)
              ],
            ),
            margin: EdgeInsets.only(top: 50,left: 20,right: 20),
          ),
          Container(

            margin: EdgeInsets.only(top: 120),
            height: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)
                )
            ),
            padding:
            EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'title'.tr(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'loginText'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        buildEmailFormField(),
                        SizedBox(height: 20),
                        buildPasswordFormField(),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            GestureDetector(
                              onTap: null,
                              child: Text(
                                "",
                                style: TextStyle(color: primaryColor),
                              ),
                            )
                          ],
                        ),
                        FormError(errors: errors),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async{
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              final ProgressDialog pr = ProgressDialog(context);
                              await pr.show();
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword(
                                    email: email,
                                    password: password
                                ).then((value) {
                                  User user=FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    print('User is currently signed out!');
                                    Toast.show("User Not Registered", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                    pr.hide();
                                  } else {

                                  FirebaseDatabase.instance.reference().child("userData").child(user.uid).once().then((DataSnapshot userSnapshot){
                                    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
                                    _firebaseMessaging.subscribeToTopic('user');
                                    _firebaseMessaging.getToken().then((value) {

                                        if(userSnapshot.value['token'] != value.toString())
                                          {
                                            final databaseReference = FirebaseDatabase.instance.reference();
                                            databaseReference.child("userData").child(user.uid).set({
                                              'token':value,
                                              'id' : userSnapshot.value['id'],
                                              'email': userSnapshot.value['email'],
                                              'username' : userSnapshot.value['username'],
                                              'profile': userSnapshot.value['profile'],
                                            });
                                          }
                                    }).onError((error, stackTrace)
                                    {
                                      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);

                                    });

                                  }).then((value) => {

                                  if(user.uid==adminId){
                                      pr.hide(),
                                  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: AdminSearchList())),
                                  }
                                  else{
                                  pr.hide(),
                                  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: BottomBar(0))),

                                  }

                                  });





                                  }
                                });
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  pr.hide();
                                  Toast.show("User Not Registered", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);

                                  print('No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  pr.hide();
                                  Toast.show("Wrong Password", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                  print('Wrong password provided for that user.');
                                }
                              }

                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width*0.7,

                            height: 50,
                            child: Text('login'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 18),),
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already'.tr(),style: TextStyle(color: Colors.grey[500]),),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: Register()));
                        },
                        child: Text('signup'.tr(),style: TextStyle(color: primaryColor),),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FacebookSignIn(),
                        GoogleSignin(),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),

    );
  }
  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.5
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 0.5,
          ),
        ),
        filled: true,
        prefixIcon: Icon(Icons.lock_outline,color: Colors.black,size: 22,),
        fillColor: Colors.grey[200],
        hintText: 'enterPassword'.tr(),
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },

      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.5
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 0.5,
          ),
        ),
        filled: true,
        prefixIcon: Icon(Icons.email_outlined,color: Colors.black,size: 22,),
        fillColor: Colors.grey[200],
        hintText: 'enterEmail'.tr(),
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
