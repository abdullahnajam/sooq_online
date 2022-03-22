import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/components/form_error.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login.dart';
class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  String userName;
  bool remember = false;
  bool _progress = false ;
  //String imageUrl ="assets/images/profile.jpg";
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
      backgroundColor: primaryColorDark,
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
                Text('signup'.tr(),style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),)
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
                    'register'.tr(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'complete'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            _showPicker(context);

                            },
                          child: photoUrl==""?Center(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/profile.jpg'),
                                  fit: BoxFit.contain,
                                )
                              ),
                            ),
                          ):Center(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                  border: Border.all(color: Colors.grey),
                                  image: DecorationImage(
                                    image: NetworkImage(photoUrl),
                                    fit: BoxFit.contain,
                                  )
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        buildEmailFormField(),
                        SizedBox(height: 20),
                        buildPasswordFormField(),
                        SizedBox(height: 20),
                        buildUserNameFormField(),
                        FormError(errors: errors),
                        SizedBox(height: 20),
                        SizedBox(height:10),
                        GestureDetector(
                          onTap: ()async{
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              if(photoUrl.length>0)
                                  {
                                    final ProgressDialog pr = ProgressDialog(context);
                                    await pr.show();
                                    try {

                                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                          email: email,
                                          password: password
                                      ).then((value) {

                                        final FirebaseAuth auth = FirebaseAuth.instance;
                                        final User user = auth.currentUser;
                                        var uid = user.uid;

                                        if (user == null) {
                                          print('User is currently signed out!');
                                          pr.hide();
                                        } else {
                                          pr.hide();
                                          print('User is signed in!');
                                          final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
                                          _firebaseMessaging.subscribeToTopic('user');
                                          _firebaseMessaging.getToken().then((value) {
                                            print(value);
                                            User user=FirebaseAuth.instance.currentUser;
                                            final databaseReference = FirebaseDatabase.instance.reference();
                                            databaseReference.child("userData").child(user.uid).set({
                                              'token':value,
                                              'id' : uid,
                                              'email': user.email,
                                              'username' : userName.trim(),
                                              'profile': photoUrl,
                                            }).then((value) {

                                              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: BottomBar(0)));
                                            });

                                          });

                                        }
                                      }).onError((error, stackTrace) {
                                        pr.hide();
                                        Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                        print("error code is : ${error.toString()}");
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      print("error code is : ${e.code}");
                                      pr.hide();
                                      if (e.code == 'weak-password') {
                                        Toast.show("Weak Password", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                        print('The password provided is too weak.');
                                      } else if (e.code == 'email-already-in-use') {
                                        Toast.show("User Already Registered", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                        print('The account already exists for that email.');
                                      }
                                    } catch (e) {
                                      pr.hide();
                                      print(e);
                                    }

                                  }
                                  else if (photoUrl.length<=0)
                                    {
                                      Toast.show("Please Upload Profile Image", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
                                    }

                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColorDark,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width*0.7,

                            height: 50,
                            child: Text('signup'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 18),),
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already2'.tr(),style: TextStyle(color: Colors.grey[500]),),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: Login()));
                        },
                        child: Text('signin'.tr(),style: TextStyle(color: primaryColorDark),),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),

    );
  }
  File imageFiles;
  File imagefile;
  String photoUrl="";

  Future uploadImageToFirebase(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagefile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
        photoUrl=value;
        print("value $value");
        setState(() {
          _progress = true;
          pr.hide();
        });

      },
    ).onError((error, stackTrace){
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    });
  }

  void fileSet(File file){
    setState(() {
      if(file!=null){
        imagefile=file;
      }
    });
    uploadImageToFirebase(context);
  }
  Future<File> _chooseGallery() async{
    await ImagePicker().getImage(source: ImageSource.gallery).then((value) => fileSet(File(value.path)));

  }
  Future<File> _choosecamera() async{
    await ImagePicker().getImage(source: ImageSource.camera).then((value) => fileSet(File(value.path)));

  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _chooseGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _choosecamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
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

  TextFormField buildUserNameFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => userName = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty)
          {
            return "Please Enter";
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
        prefixIcon: Icon(Icons.person,color: Colors.black,size: 22,),
        fillColor: Colors.grey[200],
        hintText: 'Enter Your User Name'.tr(),
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

}
