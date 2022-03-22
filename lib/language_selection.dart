import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/auth/login.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';

import 'admin/admin_search_list.dart';
import 'navigator/bottom_navigation.dart';
class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  String code="العربية";

  Future<void> _showChangeLanguageDailog() async {
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('changeLanguage'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                ),
                ListTile(
                  onTap: (){
                    context.locale = Locale('ar', 'EG');
                    code="العربية";
                    Navigator.pop(context);
                  },
                  title: Text('arabic'.tr()),
                ),
                ListTile(
                  onTap: (){
                    context.locale = Locale('en', 'US');
                    setState(() {
                      code="English";
                    });
                    Navigator.pop(context);
                  },
                  title: Text("English"),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/language.png"),
            fit: BoxFit.cover
          )
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            height: MediaQuery.of(context).size.height*0.18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  onTap: _showChangeLanguageDailog,
                  leading: Icon(Icons.language),
                  title: Text('language'.tr()),
                  trailing: Text(code,style: TextStyle(color: Colors.grey),)
                ),
                InkWell(
                  onTap: (){
                    SharedPref sharedPref=SharedPref();
                    sharedPref.setFirstTimePref(false);
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
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 10,right: 10),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text('start'.tr(),style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
