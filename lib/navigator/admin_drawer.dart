       import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/User_Adds.dart';
import 'package:propertymarket/admin/add_category.dart';
import 'package:propertymarket/admin/add_country.dart';
import 'package:propertymarket/admin/admin_home.dart';
import 'package:propertymarket/admin/admin_property_type.dart';
import 'package:propertymarket/admin/admin_search_list.dart';
import 'package:propertymarket/admin/my_info.dart';
import 'package:propertymarket/admin/slideshow.dart';
import 'package:propertymarket/admin/view_Trending.dart';
import 'package:propertymarket/admin/view_news.dart';
import 'package:propertymarket/auth/login.dart';
import 'package:propertymarket/data/my_colors.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/admin/Add_Trending.dart';
import 'package:propertymarket/screens/My_Chats.dart';
import 'package:propertymarket/screens/My_Profile.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:propertymarket/widget/my_text.dart';
import 'package:toast/toast.dart';

class AdminDrawer extends StatefulWidget {
  @override
  _AdminDrawerState createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  Future<void> _showPasswordDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'A mail has been sent to you. Please check your mail for reset password link'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _controller = TextEditingController();

  Future<void> _changePasswordDailog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          insetAnimationDuration: const Duration(seconds: 1),
          insetAnimationCurve: Curves.fastOutSlowIn,
          elevation: 2,
          child: Container(
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    "Change Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "Enter Your Email Id",
                        contentPadding: EdgeInsets.only(left: 10)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                      color: primaryColor,
                      onPressed: () async {
                        if (_controller.text != "") {
                          final FirebaseAuth firebaseAuth =
                              FirebaseAuth.instance;
                          await firebaseAuth
                              .sendPasswordResetEmail(email: _controller.text)
                              .whenComplete(() {
                            final databaseReference =
                                FirebaseDatabase.instance.reference();
                            databaseReference.child("admin").set({
                              'password': _controller.text.toString().trim(),
                            });
                            Toast.show("Please check your mail", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.TOP);
                            Navigator.pop(context);
                          }).catchError((onError) {
                            print(onError.toString());
                            Toast.show(onError.toString(), context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.TOP);
                          });
                        } else {
                          Toast.show("Enter Value", context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM);
                        }
                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onDrawerItemClicked(String name) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/logo_english.jpeg",
              height: 150,
            ),
          ),

          SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => MyProfile()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.person, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text(
                    "My Profile",
                  )),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => UserAdds()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.list_alt, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("User Adds",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddCategory()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.list_alt, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Categories",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => MyChats()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.chat_sharp, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text(
                    "My Chats",
                  )),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {
               Navigator.push(context, new MaterialPageRoute(
                  builder: (context) => ViewTrending()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.trending_up_rounded,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text(
                    "Trending",
                  )),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //SizedBox(height: 10,),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddCountry()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.place_outlined, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Location",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          // Container(height: 10),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MyInfo()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.contact_mail_outlined,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Update Contact",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //Container(height: 10),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewNews()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.assignment_outlined,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("News",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //Container(height: 10),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AdminSearchList()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.home_outlined, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Items",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //Container(height: 10),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddSlideShow()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.image_outlined, color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Slideshow",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewPropertyType()));
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.category_outlined,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Type",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //Container(height: 10),
          InkWell(
            onTap: () async {
              //_changePasswordDailog();
              final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
              await firebaseAuth
                  .sendPasswordResetEmail(email: "propertymarket1@gmail.com")
                  .whenComplete(() {
                final databaseReference = FirebaseDatabase.instance.reference();
                databaseReference.child("admin").set({
                  'password': _controller.text.toString().trim(),
                });
                _showPasswordDialog();
              }).catchError((onError) {
                print(onError.toString());
                Toast.show(onError.toString(), context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
              });
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.vpn_key_outlined,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Change password",)),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 2,
          ),
          //Container(height: 10),
          InkWell(
            onTap: () async {
              // SharedPref sp = SharedPref();

              final FirebaseAuth _auth = FirebaseAuth.instance;
              final FirebaseFirestore _firestore = FirebaseFirestore.instance;
              await _firestore.collection('user status').doc(_auth.currentUser.uid).set({
                "isOnline": false,
                "lastSeen" : DateTime.now().millisecondsSinceEpoch,
              });

              await FirebaseAuth.instance.signOut().whenComplete(() {
                //  sp.setIsLogin(false);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => BottomBar(0)));
              });


            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(Icons.power_settings_new,
                      color: MyColors.grey_20, size: 20),
                  Container(width: 20),
                  Expanded(
                      child: Text("Logout",)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
