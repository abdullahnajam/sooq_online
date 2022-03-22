//dart 2.9
import 'package:admob_flutter/admob_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:propertymarket/splash.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/json',
      fallbackLocale: Locale('ar', 'EG'),
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sooq Online',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

