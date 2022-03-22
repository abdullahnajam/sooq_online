import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/model/location.dart';
import 'package:propertymarket/model/slideshow.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/navigator/menu_drawer.dart';
import 'package:propertymarket/screens/property_list.dart';
import 'package:propertymarket/screens/sub_category.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/getters.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../language_selection.dart';

enum rentOrBuy{rent,buy}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  with WidgetsBindingObserver {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _message = '';
  SharedPref sharedPref=new SharedPref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void setStatus(bool isOnline) async {
    await _firestore.collection('user status').doc(_auth.currentUser.uid).set({
      "isOnline": isOnline,
      "lastSeen" : DateTime.now().millisecondsSinceEpoch,
    });
  }

  var _areaController=TextEditingController();
  var _countryController=TextEditingController();
  var _cityController=TextEditingController();




  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;
  @override
  Future<void> initState()  {

    _areaController.text="${'area'.tr()}";
    _countryController.text="${'country'.tr()}";
    _countryController.text="${'city'.tr()}";
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);

    super.initState();

    Admob.requestTrackingAuthorization();

    interstitialAd = AdmobInterstitial(
      adUnitId: Platform.isAndroid ? androidInterstitialVideo : iosAdmobInterstitialVideo,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    interstitialAd.load();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification.body);


      showOverlayNotification((context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: SafeArea(
            child: ListTile(
              leading: SizedBox.fromSize(
                  size: const Size(40, 40),
                  child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                            image : AssetImage("assets/images/icon.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.black,

                        ),
                      ))),
              title: Text(event.notification.title),
              subtitle: Text(event.notification.body),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    OverlaySupportEntry.of(context).dismiss();
                  }),
            ),
          ),
        );
      }, duration: Duration(seconds: 4));


    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

/*

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

     flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
                // other properties...
              ),
            ));

      }



    });
*/


    SharedPref sharedPref=new SharedPref();
    sharedPref.getPref().then((value) {
      print("value $value");
      if(!value){
        getSlideShow("ar");
      }
      else{
        getSlideShow("en");
      }
    });

  }


  countryController(value) {
    setState(() {
      _countryController.text = value;
    });
  }
  cityController(value) {
    setState(() {
      _cityController.text = value;
    });
  }
  areaController(value) {
    setState(() {
      _areaController.text = value;
    });
  }

  notificationToast(String title)
  {
    final snackBar = SnackBar(content: Text(title));
    print("title of notification is $title");
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus(true);
    } else {
      // offline
      setStatus(false);
    }
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
        if(adType=="Banner"){
          setState(() {
            isAdmobLoadedForBanner=false;
          });
        }
        if(adType=="Interstitial"){
          setState(() {
            isAdmobLoadedForBanner=false;
          });
        }
        print('Admob $adType failed to load. :(');
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



  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }
  final _scrollController = ScrollController();






  rentOrBuy _rentOrBuy = rentOrBuy.rent;
  bool isRent=true;


  List<Widget> slideShowWidget=[];
  getSlideShow(String language) async{

    List<SlideShow> slideShowList=[];

    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("slideshow").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          SlideShow slideShow = new SlideShow(
            individualKey,
            DATA[individualKey]['image'],
            DATA[individualKey]['language'],
            DATA[individualKey]['date'],

          );
          slideShowList.add(slideShow);
        }
      }
    });
    slideShowList.sort((a, b) => DateTime.parse(a.date).millisecondsSinceEpoch.compareTo(DateTime.parse(b.date).millisecondsSinceEpoch));
    for(int i=0;i<slideShowList.length;i++){
      if(slideShowList[i].language==language){

        setState(() {
          slideShowWidget.add(_slider(slideShowList[i].image));
        });
      }
    }
    return slideShowWidget;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      key: _drawerKey,
      backgroundColor: Color(0xfff2f8fc),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn,
                  padding: EdgeInsets.only(top: 10,left: 10,right: 10),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)
                      )
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: slideShowWidget.length==0?MediaQuery.of(context).size.height*0.1:MediaQuery.of(context).size.height*0.28,
                  child: Stack(
                    children: [
                      /*Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        child: Text('title'.tr(),style: TextStyle(color: Colors.white,fontSize: 25),),
                      ),
                    ),*/
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                            onTap: (){
                              _showChangeLanguageDailog();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.locale.languageCode=="en"?"English":'arabic'.tr(),style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w500),),
                                  Icon(Icons.arrow_drop_down,color: Colors.grey[600],)
                                ],
                              ),
                            )
                        ),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: _openDrawer,
                            child: Image.asset("assets/images/profile.png",color: Colors.white,height: 30,),
                          )
                      )
                      /*Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.menu,color: Colors.white,),
                        onPressed: _openDrawer,
                      ),
                    )*/
                    ],
                  ),
                ),
                slideShowWidget.length>0?Container(
                    height: MediaQuery.of(context).size.height*0.24,

                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height*0.1,
                      left: MediaQuery.of(context).size.width*0.07,
                      right: MediaQuery.of(context).size.width*0.07,
                    ),
                    child: ImageSlideshow(

                      /// Width of the [ImageSlideshow].
                      width: double.infinity,


                      /// The page to show when first creating the [ImageSlideshow].
                      initialPage: 0,

                      /// The color to paint the indicator.
                      indicatorColor: Colors.blue,

                      /// The color to paint behind th indicator.
                      indicatorBackgroundColor: Colors.white,


                      /// The widgets to display in the [ImageSlideshow].
                      /// Add the sample image file into the images folder
                      children: slideShowWidget,

                      /// Called whenever the page in the center of the viewport changes.
                      /* onPageChanged: (value) {
                    print('Page changed: $value');
                  },*/

                      /// Auto scroll interval.
                      /// Do not auto scroll with null or 0.
                      autoPlayInterval: 10000,
                    )
                ):Container()
              ],
            ),


            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10,right: 10,top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: (){
                        showSearchDialog(context);
                      },
                      child: Card(

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: context.locale.languageCode=="en"?
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text('searchIn'.tr(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w500),),
                              ):
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text('searchIn'.tr(),style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w500),),
                              ),
                            ),
                            Expanded(
                                flex: 8,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10,right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Text("${_areaController.text}, ${_cityController.text}, ${_countryController.text}",),
                                      ),
                                      Icon(Icons.arrow_drop_down,color: Colors.grey[600],)
                                    ],
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('selectCategory'.tr(),style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w700),),
                    ),
                    Expanded(
                      child: FutureBuilder<List<CategoryModel>>(
                          future: getCategoryList(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {

                              return Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator()
                              );
                            }
                            else {
                              if (snapshot.hasError) {
                                print("summary unmark error ${snapshot.error}");
                                return Center(
                                  child: Text("Something went wrong : ${snapshot.error}"),
                                );
                              }

                              else {
                                return GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 200,
                                        childAspectRatio: 3 / 3,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20),
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (BuildContext ctx, index) {
                                      return InkWell(
                                        onTap: ()async{
                                          bool hasSubCategories=false;
                                          final databaseReference = FirebaseDatabase.instance.reference();
                                          await databaseReference.child("categories").child(snapshot.data[index].id).child("sub_categories").once().then((DataSnapshot dataSnapshot){
                                            if(dataSnapshot.value!=null){
                                                hasSubCategories=true;
                                            }
                                          });
                                          if(hasSubCategories){
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SubCategory(snapshot.data[index])));
                                          }
                                          else{
                                            print("no sub categories");
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.white
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(10),
                                                        topRight: Radius.circular(10),
                                                      ),
                                                      image: DecorationImage(
                                                          image: NetworkImage(snapshot.data[index].image),
                                                          fit: BoxFit.cover
                                                      )
                                                  ),

                                                ),
                                              ),
                                              Expanded(
                                                  flex: 3,
                                                  child:Container(
                                                    alignment: Alignment.center,
                                                    child:  Text(context.locale.languageCode=="en"?snapshot.data[index].name:snapshot.data[index].name_ar,style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.w500),),
                                                  )
                                              )
                                            ],

                                          ),
                                        ),
                                      );
                                    }
                                );
                              }
                            }
                          }
                      ),
                    ),

                  ],
                ),
              ),
            ),
            /* Container(
            height: MediaQuery.of(context).size.height*0.54,
            margin: EdgeInsets.only(left: 10,right: 10,top: 10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Radio(
                      value: rentOrBuy.rent,
                      groupValue: _rentOrBuy,
                      onChanged: (rentOrBuy value) {
                        setState(() {
                          isRent = true;
                          _rentOrBuy = value;
                          print(context.locale);
                        });
                      },
                    ),
                    new Text(
                      'rent'.tr(),
                      style: new TextStyle(fontSize: 16.0),
                    ),
                    new Radio(
                      value: rentOrBuy.buy,
                      groupValue: _rentOrBuy,
                      onChanged: (rentOrBuy value) {
                        setState(() {
                          isRent = false;
                          _rentOrBuy = value;
                        });
                      },
                    ),
                    new Text(
                      'buy'.tr(),
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey,),
                ListTile(
                  onTap: ()=>sharedPref.getPref().then((value) => _showCountryDailog(value)),
                  leading: Image.asset("assets/images/country.png",width: 30,height: 30,),
                  title: Text(_selectedCountryName,style: TextStyle(color: Colors.grey[600]),),
                  trailing: Icon(Icons.keyboard_arrow_down),
                ),
                Divider(color: Colors.grey,),
                ListTile(
                  onTap: (){
                    if(selectedCountryId!=null){
                      sharedPref.getPref().then((value) => _showCityDailog(value));
                    }
                    else{
                      //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }
                  },
                  leading: Image.asset("assets/images/city.png",width: 30,height: 30,),
                  title: Text(_selectedCityName,style: TextStyle(color: Colors.grey[600]),),
                  trailing: Icon(Icons.keyboard_arrow_down),
                ),
                Divider(color: Colors.grey,),
                ListTile(
                  onTap: (){
                    if(selectedCountryId!=null && selectedCityId!=null){
                      sharedPref.getPref().then((value) => _showAreaDailog(value));

                    }
                    else{
                      //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }
                  },
                  leading: Image.asset("assets/images/area.png",width: 30,height: 30,),
                  title: Text(_selectedAreaName,style: TextStyle(color: Colors.grey[600]),),
                  trailing: Icon(Icons.keyboard_arrow_down),
                ),
                Divider(color: Colors.grey,),
                ListTile(
                  onTap: ()=>sharedPref.getPref().then((value) => _showTypeDailog(value)),
                  leading: Image.asset("assets/images/home.png",width: 30,height: 30,),
                  title: Text(_selectedTypeName,style: TextStyle(color: Colors.grey[600]),),
                  trailing: Icon(Icons.keyboard_arrow_down),
                ),
                InkWell(
                  onTap: ()async{
                    if (await interstitialAd.isLoaded) {
                      interstitialAd.show();
                      if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engType,isRent)));
                      }
                    }
                    else {
                      if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engType,isRent)));
                      }
                    }


                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 47,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                            0.4,
                            0.6,
                          ],
                          colors: [
                            Color(0xff307bd6),
                            Color(0xff2895fa),
                          ],
                        )
                    ),
                    child: Text('findProperty'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 20),),
                  ),
                ),

              ],
            ),
          )*/
          ],
        ),
      )

    );
  }
  Widget _slider(String image) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover
        ),
        borderRadius: BorderRadius.circular(15)
      ),
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
                        builder: (context) => BottomBar(0)));
                  },
                  title: Text('arabic'.tr()),
                ),
                ListTile(
                  onTap: (){
                    context.locale = Locale('en', 'US');
                    SharedPref sharedPref=new SharedPref();
                    sharedPref.setPref(true);
                    Navigator.pushReplacement(context, new MaterialPageRoute(
                        builder: (context) => BottomBar(0)));
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
  Future<void> showSearchDialog(BuildContext context) async {
    String selectedCountryId="";
    String selectedCityId="";
    String selectedAreaId="";
    String selectedTypeId="";
    String selectedCategoryId="";
    String selectedSubCategoryId="";

    String engCountry="";
    String engCity="";
    String engArea="";
    String engType="";
    String engCategory = "";
    String engSubCategory = "";


    String arCountry="";
    String arCity="";
    String arArea="";
    String arType="";
    String arCategory = "";
    String arSubCategory = "";



    String _selectedCountryName='selectCountry'.tr();
    String _selectedCityName='selectCity'.tr();
    String _selectedAreaName='selectArea'.tr();
    String _selectedTypeName='selectType'.tr();
    String _selectedCategoryName = 'selectCategory'.tr();
    String _selectedSubCategoryName='selectSubCategory'.tr();
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              insetAnimationDuration: const Duration(seconds: 1),
              insetAnimationCurve: Curves.fastOutSlowIn,
              elevation: 2,

              child: Container(
                height: MediaQuery.of(context).size.height*0.5,
                //padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.only(top: 20,),
                              child: Text('search'.tr(),textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: (){
                                Navigator.pop(context);

                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 20,right: 20),
                                child: Icon(Icons.close,color: Colors.black,),
                              ),
                            ),
                          )
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ListView(
                           shrinkWrap: true,
                            children: [
                              Text('selectCountry'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                              SizedBox(height: 7,),
                              Row(
                                children: [
                                  Image.asset("assets/images/country.png",width: 30,height: 30,),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                        sharedPref.getPref().then((value){
                                          showDialog<void>(
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
                                                  height: MediaQuery.of(context).size.height*0.4,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(30)
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment.center,
                                                            child: Container(
                                                              margin: EdgeInsets.all(10),
                                                              child: Text('country'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color:Colors.black,fontWeight: FontWeight.w600),),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Container(
                                                              margin: EdgeInsets.all(10),
                                                              child: IconButton(
                                                                icon: Icon(Icons.close,color: Colors.grey,),
                                                                onPressed: ()=>Navigator.pop(context),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),

                                                      Expanded(
                                                        child: FutureBuilder<List<LocationModel>>(
                                                          future: getCountryList(),
                                                          builder: (context,snapshot){
                                                            if (snapshot.hasData) {
                                                              if (snapshot.data != null && snapshot.data.length>0) {
                                                                return Container(
                                                                  margin: EdgeInsets.all(10),
                                                                  child: Scrollbar(
                                                                    controller: _scrollController,
                                                                    isAlwaysShown: snapshot.data.length>3?true:false,
                                                                    child: ListView.separated(
                                                                      controller: _scrollController,
                                                                      separatorBuilder: (context, index) {
                                                                        return Divider(color: Colors.grey,);
                                                                      },
                                                                      shrinkWrap: true,
                                                                      itemCount: snapshot.data.length,
                                                                      itemBuilder: (BuildContext context,int index){
                                                                        return GestureDetector(
                                                                          onTap: (){
                                                                            setState(() {

                                                                              !value?_selectedCountryName=snapshot.data[index].name_ar:_selectedCountryName=snapshot.data[index].name;
                                                                              //!value?_countryController.text=;
                                                                              engCountry=snapshot.data[index].name;
                                                                              arCountry=snapshot.data[index].name_ar;
                                                                              selectedCountryId=snapshot.data[index].id;
                                                                            });
                                                                            countryController(!value?snapshot.data[index].name_ar:snapshot.data[index].name);
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Container(
                                                                            margin: EdgeInsets.all(5),
                                                                            child: Text(!value?snapshot.data[index].name_ar:snapshot.data[index].name,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color:Colors.black),),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              else {
                                                                return Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Container(
                                                                      child: Lottie.asset(
                                                                        'assets/json/empty.json',
                                                                        width: MediaQuery.of(context).size.width*0.4,
                                                                        height: MediaQuery.of(context).size.height*0.2,
                                                                        fit: BoxFit.fill,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 10,),
                                                                    Container(
                                                                        child: Text('noData'.tr(),style: TextStyle(fontSize: 16),)
                                                                    ),
                                                                  ],
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
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue[200]),
                                            borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                child: Text(_selectedCountryName,style: TextStyle(color: Colors.grey[600]),),

                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,color: Colors.blue,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 15,),

                              Text('selectCity'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                              SizedBox(height: 7,),
                              Row(
                                children: [
                                  Image.asset("assets/images/city.png",width: 30,height: 30,),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                        if(selectedCountryId!=null){
                                          sharedPref.getPref().then((value){
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
                                                    height: MediaQuery.of(context).size.height*0.4,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30)
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: Text('city'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color:Colors.black,fontWeight: FontWeight.w600),),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: IconButton(
                                                                  icon: Icon(Icons.close,color: Colors.grey,),
                                                                  onPressed: ()=>Navigator.pop(context),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),

                                                        Expanded(
                                                          child: FutureBuilder<List<LocationModel>>(
                                                            future: getCityList(selectedCountryId),
                                                            builder: (context,snapshot){
                                                              if (snapshot.hasData) {
                                                                if (snapshot.data != null && snapshot.data.length>0) {
                                                                  return Container(
                                                                    margin: EdgeInsets.all(10),
                                                                    child: Scrollbar(
                                                                      controller: _scrollController,
                                                                      isAlwaysShown: snapshot.data.length>3?true:false,
                                                                      child: ListView.separated(
                                                                        controller: _scrollController,
                                                                        separatorBuilder: (context, index) {
                                                                          return Divider(color: Colors.grey,);
                                                                        },
                                                                        shrinkWrap: true,
                                                                        itemCount: snapshot.data.length,
                                                                        itemBuilder: (BuildContext context,int index){
                                                                          return GestureDetector(
                                                                            onTap: (){
                                                                              setState(() {
                                                                                !value?_selectedCityName=snapshot.data[index].name_ar:_selectedCityName=snapshot.data[index].name;
                                                                               // !value?_cityController.text=snapshot.data[index].name_ar:_selectedCityName=snapshot.data[index].name;
                                                                                engCity=snapshot.data[index].name;
                                                                                arCity=snapshot.data[index].name_ar;
                                                                                selectedCityId=snapshot.data[index].id;
                                                                              });
                                                                              cityController(!value?snapshot.data[index].name_ar:snapshot.data[index].name);
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Container(
                                                                              margin: EdgeInsets.all(5),
                                                                              child: Text(!value?snapshot.data[index].name_ar:snapshot.data[index].name,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color:Colors.black),),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                else {
                                                                  return Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        child: Lottie.asset(
                                                                          'assets/json/empty.json',
                                                                          width: MediaQuery.of(context).size.width*0.4,
                                                                          height: MediaQuery.of(context).size.height*0.2,
                                                                          fit: BoxFit.fill,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Container(
                                                                          child: Text('noData'.tr(),style: TextStyle(fontSize: 16),)
                                                                      ),
                                                                    ],
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
                                          });
                                        }
                                        else{
                                          //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue[200]),
                                            borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                child: Text(_selectedCityName,style: TextStyle(color: Colors.grey[600]),),

                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,color: Colors.blue,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 15,),

                              Text('selectArea'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                              SizedBox(height: 7,),
                              Row(
                                children: [
                                  Image.asset("assets/images/area.png",width: 30,height: 30,),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                        if(selectedCountryId!=null && selectedCityId!=null){
                                          sharedPref.getPref().then((value) {
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
                                                    height: MediaQuery.of(context).size.height*0.4,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30)
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: Text('areaSelect'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color:Colors.black,fontWeight: FontWeight.w600),),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: IconButton(
                                                                  icon: Icon(Icons.close,color: Colors.grey,),
                                                                  onPressed: ()=>Navigator.pop(context),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),

                                                        Expanded(
                                                          child: FutureBuilder<List<LocationModel>>(
                                                            future: getAreaList(selectedCountryId, selectedCityId),
                                                            builder: (context,snapshot){
                                                              if (snapshot.hasData) {
                                                                if (snapshot.data != null && snapshot.data.length>0) {
                                                                  return Container(
                                                                      margin: EdgeInsets.all(10),
                                                                      child: Scrollbar(
                                                                        controller: _scrollController,
                                                                        isAlwaysShown: snapshot.data.length>3?true:false,
                                                                        child: ListView.separated(
                                                                          controller: _scrollController,
                                                                          separatorBuilder: (context, index) {
                                                                            return Divider(color: Colors.grey,);
                                                                          },
                                                                          shrinkWrap: true,
                                                                          itemCount: snapshot.data.length,
                                                                          itemBuilder: (BuildContext context,int index){
                                                                            return GestureDetector(
                                                                              onTap: (){
                                                                                setState(() {
                                                                                  !value?_selectedAreaName=snapshot.data[index].name_ar:_selectedAreaName=snapshot.data[index].name;
                                                                                  //!value?_areaController.text=snapshot.data[index].name_ar:_selectedAreaName=snapshot.data[index].name;
                                                                                  engArea=snapshot.data[index].name;
                                                                                  arArea=snapshot.data[index].name_ar;
                                                                                  selectedAreaId=snapshot.data[index].id;
                                                                                });
                                                                                areaController(!value?snapshot.data[index].name_ar:snapshot.data[index].name);
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                margin: EdgeInsets.all(5),
                                                                                child: Text(!value?snapshot.data[index].name_ar:snapshot.data[index].name,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color:Colors.black),),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      )
                                                                  );
                                                                }
                                                                else {
                                                                  return Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        child: Lottie.asset(
                                                                          'assets/json/empty.json',
                                                                          width: MediaQuery.of(context).size.width*0.4,
                                                                          height: MediaQuery.of(context).size.height*0.2,
                                                                          fit: BoxFit.fill,
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Container(
                                                                          child: Text('noData'.tr(),style: TextStyle(fontSize: 16),)
                                                                      ),
                                                                    ],
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
                                          });

                                        }
                                        else{
                                          //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue[200]),
                                            borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                child: Text(_selectedAreaName,style: TextStyle(color: Colors.grey[600]),),

                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,color: Colors.blue,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 15,),

                              /*Text('selectCategory'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                              SizedBox(height: 7,),
                              Row(
                                children: [
                                  Image.asset("assets/images/country.png",width: 30,height: 30,),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: InkWell(
                                      onTap: ()=>sharedPref.getPref().then((value){
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
                                                height: MediaQuery.of(context).size.height * 0.4,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: Container(
                                                            margin: EdgeInsets.all(10),
                                                            child: Text(
                                                              'categorySelect'.tr(),
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Container(
                                                            margin: EdgeInsets.all(10),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                color: Colors.grey,
                                                              ),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: FutureBuilder<List<CategoryModel>>(
                                                        future: getCategoryList(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData) {
                                                            if (snapshot.data != null && snapshot.data.length > 0) {
                                                              return Container(
                                                                  margin: EdgeInsets.all(10),
                                                                  child: Scrollbar(
                                                                    controller: _scrollController,
                                                                    isAlwaysShown:
                                                                    snapshot.data.length > 3 ? true : false,
                                                                    child: ListView.separated(
                                                                      controller: _scrollController,
                                                                      separatorBuilder: (context, index) {
                                                                        return Divider(
                                                                          color: Colors.grey,
                                                                        );
                                                                      },
                                                                      shrinkWrap: true,
                                                                      itemCount: snapshot.data.length,
                                                                      itemBuilder:
                                                                          (BuildContext context, int index) {
                                                                        return GestureDetector(
                                                                          onTap: () {
                                                                            setState(() {
                                                                              !value?_selectedCategoryName=snapshot.data[index].name_ar:_selectedCategoryName=snapshot.data[index].name;
                                                                              arCategory = snapshot.data[index].name_ar ;
                                                                              engCategory = snapshot.data[index].name ;
                                                                              selectedCategoryId = snapshot.data[index].id;
                                                                            });

                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Container(
                                                                            margin: EdgeInsets.all(5),
                                                                            child: Text(
                                                                              !value
                                                                                  ? snapshot.data[index].name_ar
                                                                                  : snapshot.data[index].name,
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: Colors.black),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ));
                                                            } else {
                                                              return Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    child: Lottie.asset(
                                                                      'assets/json/empty.json',
                                                                      width:
                                                                      MediaQuery.of(context).size.width * 0.4,
                                                                      height:
                                                                      MediaQuery.of(context).size.height * 0.2,
                                                                      fit: BoxFit.fill,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                      child: Text(
                                                                        'noData'.tr(),
                                                                        style: TextStyle(fontSize: 16),
                                                                      )),
                                                                ],
                                                              );
                                                            }
                                                          } else if (snapshot.hasError) {
                                                            return Text('Error : ${snapshot.error}');
                                                          } else {
                                                            return new Center(
                                                              child: CircularProgressIndicator(),
                                                            );
                                                          }
                                                        },
                                                      ),
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
                                      }),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue[200]),
                                            borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                child: Text(_selectedCategoryName,style: TextStyle(color: Colors.grey[600]),),

                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,color: Colors.blue,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 15,),

                              Text('selectSubCategory'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                              SizedBox(height: 7,),
                              Row(
                                children: [
                                  Image.asset("assets/images/city.png",width: 30,height: 30,),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                        if(selectedCategoryId!=null){
                                          sharedPref.getPref().then((value){
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
                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: Text(
                                                                  'SubCategorySelect'.tr(),
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      fontSize: 25,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w600),
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Container(
                                                                margin: EdgeInsets.all(10),
                                                                child: IconButton(
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  onPressed: () => Navigator.pop(context),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Expanded(
                                                          child: FutureBuilder<List<CategoryModel>>(
                                                            future: getSubCategoryList(selectedCategoryId),
                                                            builder: (context, snapshot) {
                                                              if (snapshot.hasData) {
                                                                if (snapshot.data != null && snapshot.data.length > 0) {
                                                                  return Container(
                                                                      margin: EdgeInsets.all(10),
                                                                      child: Scrollbar(
                                                                        controller: _scrollController,
                                                                        isAlwaysShown:
                                                                        snapshot.data.length > 3 ? true : false,
                                                                        child: ListView.separated(
                                                                          controller: _scrollController,
                                                                          separatorBuilder: (context, index) {
                                                                            return Divider(
                                                                              color: Colors.grey,
                                                                            );
                                                                          },
                                                                          shrinkWrap: true,
                                                                          itemCount: snapshot.data.length,
                                                                          itemBuilder:
                                                                              (BuildContext context, int index) {
                                                                            return GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  !value
                                                                                      ?  _selectedSubCategoryName = snapshot.data[index].name_ar
                                                                                      : _selectedSubCategoryName = snapshot.data[index].name ;

                                                                                  arSubCategory = snapshot.data[index].name_ar ;
                                                                                  engSubCategory = snapshot.data[index].name ;
                                                                                  selectedSubCategoryId = snapshot.data[index].id;
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                margin: EdgeInsets.all(5),
                                                                                child: Text(
                                                                                  !value
                                                                                      ? snapshot.data[index].name_ar
                                                                                      : snapshot.data[index].name,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                      fontSize: 16,
                                                                                      color: Colors.black),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ));
                                                                } else {
                                                                  return Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        child: Lottie.asset(
                                                                          'assets/json/empty.json',
                                                                          width:
                                                                          MediaQuery.of(context).size.width * 0.4,
                                                                          height:
                                                                          MediaQuery.of(context).size.height * 0.2,
                                                                          fit: BoxFit.fill,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      Container(
                                                                          child: Text(
                                                                            'noData'.tr(),
                                                                            style: TextStyle(fontSize: 16),
                                                                          )),
                                                                    ],
                                                                  );
                                                                }
                                                              } else if (snapshot.hasError) {
                                                                return Text('Error : ${snapshot.error}');
                                                              } else {
                                                                return new Center(
                                                                  child: CircularProgressIndicator(),
                                                                );
                                                              }
                                                            },
                                                          ),
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
                                          });
                                        }
                                        else{
                                          //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue[200]),
                                            borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(left: 10,right: 10),
                                                child: Text(_selectedSubCategoryName,style: TextStyle(color: Colors.grey[600]),),

                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,color: Colors.blue,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
*/





                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: ()async{
                         /* interstitialAd.show();
                          if (await interstitialAd.isLoaded) {
                                  interstitialAd.show();
                                  if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engCategory,engSubCategory,arCountry,arCity,arArea,arCategory,arSubCategory)));
                                  }
                                }
                                else {
                                  if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engCategory,engSubCategory,arCountry,arCity,arArea,arCategory,arSubCategory)));
                                  }
                                }*/


                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Color(0xff2895fa),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              )
                              /*gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                stops: [
                                  0.4,
                                  0.6,
                                ],
                                colors: [
                                  Color(0xff307bd6),
                                  Color(0xff2895fa),
                                ],
                              )*/
                          ),
                          child: Text('search'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 20),),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


}
