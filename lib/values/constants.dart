import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const primaryColor = Color(0xFF0247af);
const backgroundColorLight = Color(0xFFfcdeb3);
//const adminId="GSExrT5IUrfVmg9bY9kZcayclFl2";
const adminId="j50vjMevGGZguDwNeaDyFdpRgl43";//"H5FL9JksDFYgbq4iHgp4wZ13FUc2"; //temp admin
const serverToken="AAAAEw4em9g:APA91bGrMl-LZ_gVm1AETZqjl0k4eKAKt16Ilzsp-ngfQuypNqvXmK8Y8FyYMw-N9t9FYGYgS_HFjblGk1bH0rIThyShDTsStDMSrkkRF4s2QLSn3_4pmcU0RcuKvSGczIDFHPVjAdph";
const primaryColorDark = Color(0xFF2f3b47);
final RegExp emailValidatorRegExp =
RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";
const String url="https://www.freeprivacypolicy.com/live/493470a8-8f50-4d6d-8238-b92328ec9563";
const String androidInterstitialVideo="ca-app-pub-3940256099942544/1033173712";
const String androidAdmobBanner="ca-app-pub-3940256099942544/6300978111";/*
const String androidFanBanner="4072676972810543_4084550341623206";
const String androidFanInterstitialVideo="4072676972810543_4084573791620861";*/
const String iosAdmobBanner="ca-app-pub-9395198588563221/3988023888";
const String iosAdmobInterstitialVideo="ca-app-pub-9395198588563221/3549078172";


Future<void> showAlertDialog(BuildContext context,String title,String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children:  <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child:  Text('ok'.tr()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


