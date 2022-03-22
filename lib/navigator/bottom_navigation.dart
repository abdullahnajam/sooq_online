import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/add_property.dart';
import 'package:propertymarket/auth/login.dart';
import 'package:propertymarket/model/info.dart';
import 'package:propertymarket/screens/My_Chats.dart';
import 'package:propertymarket/screens/Notify.dart';
import 'package:propertymarket/screens/Trending.dart';
import 'package:propertymarket/screens/add_item.dart';
import 'package:propertymarket/screens/best.dart';
import 'package:propertymarket/screens/favourites.dart';
import 'package:propertymarket/screens/home.dart';
import 'package:propertymarket/screens/news.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:badges/badges.dart';

class BottomBar extends StatefulWidget {
  int index;

  BottomBar(this.index);

  @override
  _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomBar>{


  int _currentIndex   ;

  List<Widget> _children=[];
  Future<MyInformation> getSlideList() async {
    MyInformation _myInfo;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("info").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        _myInfo = new MyInformation(
          dataSnapshot.value['email'],
          dataSnapshot.value['phone'],
        );

      }
    });
    return _myInfo;
  }
/*  _showInfoDailog() async {
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
                  child: Text("Contact Information",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                ),
                FutureBuilder<MyInformation>(
                  future: getSlideList(),
                  builder: (context,snapshot){
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        return Column(
                          children: [
                            Container(
                                child: ListTile(
                                  leading: Icon(Icons.phone),
                                  title: Text(snapshot.data.phone),
                                )
                            ),
                            Divider(color: Colors.grey,),
                            Container(
                                child: ListTile(
                                  leading: Icon(Icons.email),
                                  title: Text(snapshot.data.email),
                                )
                            ),
                          ],
                        );
                      }
                      else {
                        return new Center(
                          child: Container(
                              child: Text("no data")
                          ),
                        );
                      }
                    }
                    else if (snapshot.hasError) {
                      return Text('Error : ${snapshot.error}');
                    } else {
                      return new Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
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

  _showChangeLanguageDailog() async {
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
                    SharedPref sharedPref=new SharedPref();
                    sharedPref.setPref(false);
                    Navigator.pushReplacement(context, new MaterialPageRoute(
                        builder: (context) => BottomBar()));
                  },
                  title: Text('arabic'.tr()),
                ),
                ListTile(
                  onTap: (){
                    context.locale = Locale('en', 'US');
                    SharedPref sharedPref=new SharedPref();
                    sharedPref.setPref(true);
                    Navigator.pushReplacement(context, new MaterialPageRoute(
                        builder: (context) => BottomBar()));
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
  }*/
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User _user=FirebaseAuth.instance.currentUser;
  bool areUnreadMessages=false;
  var lang ;
  @override
  void initState() {
    _currentIndex = widget.index;
    super.initState();

    _children = [
      HomePage(),
      Best(),
      Trending(),
      MyChats(),
      FavouriteList(),
      AddItem(),

    ];
    Admob.requestTrackingAuthorization();
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: Platform.isAndroid ? androidInterstitialVideo : iosAdmobInterstitialVideo,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    interstitialAd.load();

  }


  void handleEvent(AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        print('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        print('Admob $adType Ad failed!');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
              onWillPop: () async {
                print("snack bar popped");
                return true;
              },
            );
          },
        );
        break;
      default:
    }
  }

  void onTabTapped(int index) async{
    if(index==0){
      setState(() {
        _currentIndex = index;
      });

    }
    if(index==1){
      if (await interstitialAd.isLoaded) {
        interstitialAd.show();
        setState(() {
          _currentIndex = index;
        });
      }
      else {
        setState(() {
          _currentIndex = index;
        });

      }
    }
    else if(index==2){
      setState(() {
        _currentIndex = index;
      });
    }
    else if(index==3){
      User user=FirebaseAuth.instance.currentUser;
      if(user == null)
      {
        print("hello");
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else
      {
        setState(() {
          _currentIndex = index;
        });
      }
    }

    else if(index==4){
      User user=FirebaseAuth.instance.currentUser;
      if(user == null)
      {
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else
      {
        setState(() {
          _currentIndex = index;
        });
      }
    }
    else if(index==5){
      User user=FirebaseAuth.instance.currentUser;
      if(user == null)
      {
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else{

        if (await interstitialAd.isLoaded) {
          interstitialAd.show();
          setState(() {
            _currentIndex = index;
          });
        }
        else {
          setState(() {
            _currentIndex = index;
          });
        }

      }

    }

  }
  String getUid() {
    final User user = auth.currentUser;
    final uId = user.uid;
    return uId;
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedItemColor:Color(0xffabc6ff),
        selectedItemColor: primaryColor,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex,
        items: [

          BottomNavigationBarItem(
              icon: new Icon(Icons.search),
              label: 'search'.tr()
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.stars_rounded),
              label: 'best'.tr()
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.trending_up_rounded),
              label: 'trending'.tr()
          ),
          BottomNavigationBarItem(

              icon: _user == null ?  Icon(Icons.chat) : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('unseen Message').doc(getUid()).collection('unseen Message').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                  if(snapshot.data != null)
                  {
                    int i=0;

                    snapshot.data.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      i+=data['unseen'];
                    }).toList();
                    print("total unseen messages $i");
                    if(i>0){
                      return Badge(
                        badgeContent: Text("$i",style: TextStyle(color: Colors.white),),
                        child: Icon(Icons.chat),
                      );

                    }
                    else{

                      return Icon(Icons.chat);
                    }

                  }
                  else {
                    return  Icon(Icons.chat);
                  }
                },
              ),
              label: 'myChat'.tr()
          ),
          BottomNavigationBarItem(

              icon: Icon(Icons.favorite),
              label: "favourite".tr(),
          ),
          BottomNavigationBarItem(

              icon: Icon(Icons.add),
              label: 'add'.tr()
          ),
        ],
      ),
      body: _children[_currentIndex],
    );
  }
  Future<bool> dataExist(String uid) async  {
    bool exsist  ;
    try {
      print("No Error");
      await FirebaseFirestore.instance.collection('unseen Message').doc(getUid()).get().then((doc) {
        print(doc.exists);
        exsist = doc.exists;

      });
    } catch (e) {
      print("error fetching");
      exsist =  false;
    }

    return exsist;

  }

  var unseen = 0 ;

   totalUnseen() {
    FirebaseFirestore.instance
        .collection('unseen Message').doc(getUid()).collection('unseen Message')
        .get()
        .then((QuerySnapshot querySnapshot) {
          if(querySnapshot.size > 0)
            {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  unseen = unseen+doc["unseen"];
                });
                print(doc["unseen"]);
              });

            }

    });
  }
/*
  Stream<int> getTotalUnReadMessages()async*{
    int i=0;
     await FirebaseFirestore.instance
        .collection('unseen Message').doc(getUid()).collection('unseen Message')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        yield* i;
        setState(() {
          i=i+doc['unseen'];
          yield ;
        });
      });
    });
  }
*/
}




/*

class BottomBar extends StatefulWidget {

  @override
  _BottomNavigationState createState() => new _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomBar>{

  int _currentIndex = 0;
  List<Widget> _children=[];

  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid = "" ;
  void inputData() {
    final User user = auth.currentUser;
    uid = user.uid;
    // here you write the codes to input the data into firestore
  }

  @override
  void initState() {
    super.initState();

    _children = [
      HomePage(),
      News(),
      Trending(),
      MyChats(),
      Notify(),
      AddProperty(),

    ];
    Admob.requestTrackingAuthorization();
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: Platform.isAndroid ? androidInterstitialVideo : iosAdmobInterstitialVideo,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    interstitialAd.load();
  }
  void handleEvent(AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        print('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        print('Admob $adType Ad failed!');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
              onWillPop: () async {
                print("snack bar popped");
                return true;
              },
            );
          },
        );
        break;
      default:
    }
  }
  Future<MyInformation> getSlideList() async {
    MyInformation _myInfo;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("info").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        _myInfo = new MyInformation(
          dataSnapshot.value['email'],
          dataSnapshot.value['phone'],
        );

      }
    });
    return _myInfo;
  }
  logout()async{
    await FirebaseAuth.instance.signOut().whenComplete((){
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => Login()));
    });
  }
  _showInfoDailog() async {
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
                  child: Text("Contact Information",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                ),
                FutureBuilder<MyInformation>(
                  future: getSlideList(),
                  builder: (context,snapshot){
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        return Column(
                          children: [
                            Container(
                                child: ListTile(
                                  leading: Icon(Icons.phone),
                                  title: Text(snapshot.data.phone),
                                )
                            ),
                            Divider(color: Colors.grey,),
                            Container(
                                child: ListTile(
                                  leading: Icon(Icons.email),
                                  title: Text(snapshot.data.email),
                                )
                            ),
                          ],
                        );
                      }
                      else {
                        return new Center(
                          child: Container(
                              child: Text("no data")
                          ),
                        );
                      }
                    }
                    else if (snapshot.hasError) {
                      return Text('Error : ${snapshot.error}');
                    } else {
                      return new Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
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
  void onTabTapped(int index) async{

    if(index==0){
      if (await interstitialAd.isLoaded) {
        interstitialAd.show();
        setState(() {
          _currentIndex = index;
        });
      }
      else {
        setState(() {
          _currentIndex = index;
        });
      }

    }
    if(index==1){
      if (await interstitialAd.isLoaded) {
        interstitialAd.show();
        setState(() {
          _currentIndex = index;
        });
      }
      else {
        setState(() {
          _currentIndex = index;
        });

      }
    }
    else if(index==2){
      setState(() {
        _currentIndex = index;
      });
    }
    else if(index==3){
      User user=FirebaseAuth.instance.currentUser;
      if(user == null)
      {
        print("hello");
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else
      {
        setState(() {
          _currentIndex = index;
        });
      }
         }

    else if(index==4){
      User user=FirebaseAuth.instance.currentUser;
      if(user == null)
      {
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else
      {
        setState(() {
          _currentIndex = index;
        });
      }
    }
    else if(index==5){
      User user=FirebaseAuth.instance.currentUser;
     if(user == null)
      {
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => Login()));
      }
      else{
        setState(() {
          _currentIndex = index;
        });
      }

    }

  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _currentIndex,
        animationDuration: Duration(milliseconds: 800),
        animationCurve: Curves.linear,
        showElevation: true,
        onItemSelected: onTabTapped,
        items: [

          FlashyTabBarItem(
              icon: new Icon(Icons.search),
              title: Text('search'.tr()),
          ),
          FlashyTabBarItem(
              icon: new Icon(Icons.assignment_outlined),
              title: Text('news'.tr())
          ),
          FlashyTabBarItem(
              icon: new Icon(Icons.trending_up_rounded),
              title: Text('trending'.tr())
          ),
          FlashyTabBarItem(

              icon: Icon(Icons.chat),
              title: Text('myChat'.tr())
          ),
          FlashyTabBarItem(
              icon: Icon(Icons.notifications),
              title: Text("notification".tr())
          ),
          FlashyTabBarItem(
              icon: Icon(Icons.add),
              title: Text('add'.tr())
          ),

        ],
      ),
      body: _children[_currentIndex],
    );
  }
}
*/
