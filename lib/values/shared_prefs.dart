import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  Future<bool> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool language = prefs.getBool('language') ?? false;
    print("pref $language");
    return language;

  }
  setPref(bool language)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setBool('language', language);
  }

  setFirstTimePref(bool first)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('first', first);
  }
  Future<bool> getFirstTimePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool first = prefs.getBool('first') ?? true;
    print("firstpref $first");
    return first;
  }


}