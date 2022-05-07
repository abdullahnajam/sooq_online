import 'dart:io';
import 'dart:math';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/model/User_Notificactions.dart';
import 'package:propertymarket/model/location.dart';
import 'package:propertymarket/model/property.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/values/getters.dart';
import 'package:propertymarket/values/shared_prefs.dart';

enum rentOrBuy { rent, buy }

class Notify extends StatefulWidget {
  const Notify({Key key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {

  bool _isLoaded=false;
  SharedPref sharedPref = new SharedPref();
  final _scrollController = ScrollController();
  final ScrollController listScrollController = ScrollController();

  String userid;
  var rng = new Random();
  var notificationId;

  String selectedCountryId = "";
  String selectedCityId = "";
  String selectedAreaId = "";
  String selectedTypeId="";

  String engCountry = "";
  String engCity = "";
  String engArea = "";
  String engType="";

  String arCountry = "";
  String arCity = "";
  String arArea = "";
  String arType="";


  String selectedCountryName = 'selectCountry'.tr();
  String selectedCityName = 'selectCity'.tr();
  String selectedAreaName = 'selectArea'.tr();
  String selectedTypeName='selectType'.tr();


  String arBuy="بيع";
  String arRent="تاجير";

  bool isRent = true;
  rentOrBuy _rentOrBuy = rentOrBuy.rent;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'notification'.tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15,0,15,0),
            child: Container(
              margin:EdgeInsets.only(left: 10, right: 10, top: 5),
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
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () => sharedPref.getPref().then(
                            (value) => _showCountryDailog(value)),
                    leading: Image.asset(
                      "assets/images/country.png",
                      width: 30,
                      height: 30,
                    ),
                    title: Text(
                      selectedCountryName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_down),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      if (selectedCountryId != null) {
                        sharedPref.getPref().then(
                                (value) => _showCityDailog(value));
                      } else {
                        //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      }
                    },
                    leading: Image.asset(
                      "assets/images/city.png",
                      width: 30,
                      height: 30,
                    ),
                    title: Text(
                      selectedCityName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_down),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      if (selectedCountryId != null &&
                          selectedCityId != null) {
                        sharedPref.getPref().then(
                                (value) => _showAreaDailog(value));
                      } else {
                        //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      }
                    },
                    leading: Image.asset(
                      "assets/images/area.png",
                      width: 30,
                      height: 30,
                    ),
                    title: Text(
                      selectedAreaName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_down),
                  ),
                  Divider(color: Colors.grey,),
                  ListTile(
                    onTap: ()=>sharedPref.getPref().then((value) => _showTypeDailog(value)),
                    leading: Image.asset("assets/images/home.png",width: 30,height: 30,),
                    title: Text(selectedTypeName,style: TextStyle(color: Colors.grey[600]),),
                    trailing: Icon(Icons.keyboard_arrow_down),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      if (selectedCityId != null &&
                          selectedCityId != "" &&
                          selectedCountryId != null &&
                          selectedCountryId != "" &&
                          selectedAreaName != null &&
                          selectedAreaName != "") {
                        randNumber();
                        makeNotificationRequest()
                            .whenComplete(() {
                          setState(() {});
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
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
                          )),
                      child: Text(
                        'Notify'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("notifyNote".tr(),style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),),
                      )),



                ],
              ),
            ),
          ),
          SizedBox(
              height: 10
          ),
          Container(
            height:
            MediaQuery.of(context).size.height * 0.63,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
            ),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(
                      "myNotification".tr(),
                      style: TextStyle(
                          fontSize: 20,
                          color: primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  color: primaryColor,
                  height: 1.5,
                  width:MediaQuery.of(context).size.width *0.4,
                ),
                Container(
                  height: 7,
                ),
                Container(
                  height:
                  MediaQuery.of(context).size.height *
                      0.53,
                  child: FutureBuilder<
                      List<UserNotificationModel>>(
                    future: getUserNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null &&
                            snapshot.data.length > 0) {
                          print(userid);
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                              snapshot.data.length,
                              itemBuilder:
                                  (context, index) {
                                return Container(
                                    height: MediaQuery.of(
                                        context)
                                        .size
                                        .height *
                                        0.16,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(
                                              child:
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(10.0),
                                                    child: FutureBuilder<bool>(
                                                      future: sharedPref.getPref(),
                                                      builder: (context,snapshots){
                                                        if (snapshots.hasData) {
                                                          if (snapshots.data != null && snapshots.connectionState == ConnectionState.done ) {
                                                            if(snapshots.data == true )
                                                            {
                                                              return Text("Address : " + snapshot.data[index].country +  " , " + snapshot.data[index].city + " , " +
                                                                  snapshot.data[index].area +
                                                                  "\nCategory : " +
                                                                  snapshot.data[index].propertyCategory + "\nType : " + snapshot.data[index].type,
                                                                style:
                                                                TextStyle(fontSize: 14),
                                                              );
                                                            }
                                                            else
                                                            {
                                                              return Align(
                                                                alignment : Alignment.centerRight,
                                                                child: Text("عنوان : " + snapshot.data[index].country_ar +  " , " + snapshot.data[index].city_ar + " , " +
                                                                    snapshot.data[index].area_ar +"\n"+
                                                                    "فئة : " + snapshot.data[index].propertyCategory_ar +"\n"+
                                                                    "نوع : " + snapshot.data[index].type_ar ,
                                                                  style:
                                                                  TextStyle(fontSize: 14),
                                                                ),
                                                              );                                                                                  }
                                                          }
                                                          else  {
                                                            return new Center(
                                                              child: Container(
                                                                  child: Text('noData'.tr())
                                                              ),
                                                            );
                                                          }

                                                        }
                                                        else if (snapshots.hasError) {
                                                          return Text('Error : ${snapshots.error}');
                                                        } else {
                                                          return new Center(
                                                            child: CircularProgressIndicator(),
                                                          );
                                                        }
                                                      },
                                                    ),


                                                  ),
                                                ],
                                              ),
                                              width: MediaQuery.of(context).size.width *0.85,
                                              alignment:Alignment.centerLeft,
                                            ),
                                            IconButton(
                                                onPressed:
                                                    () async {
                                                  print ("Notificaotin id is : ${snapshot.data[index].notificationId}");
                                                  FirebaseDatabase
                                                      .instance
                                                      .reference()
                                                      .child('userNotification')
                                                      .orderByChild('notificationId')
                                                      .equalTo(snapshot.data[index].notificationId)
                                                      .once()
                                                      .then((DataSnapshot snapshot) {
                                                    Map<dynamic, dynamic>
                                                    children =
                                                        snapshot.value;
                                                    children.forEach((key,
                                                        value) {
                                                      FirebaseDatabase.instance.reference().child('userNotification').child(key).remove();
                                                    });
                                                  }).then((value) {
                                                    setState(
                                                            () {});
                                                  });
                                                },
                                                icon:
                                                Icon(
                                                  Icons
                                                      .delete,
                                                  color: Colors
                                                      .red,
                                                ))
                                          ],
                                        ),

                                        SizedBox(height: 4,),
                                        Divider(
                                          height: 2,
                                          color: Colors.black54,
                                          thickness: 1,
                                          endIndent: 20,
                                          indent: 20,
                                        ),
                                      ],
                                    ));
                              });
                        } else {
                          print("user id :$userid");

                          return new Center(
                            child: Container(
                                child: Text(
                                    "No Notification Request")),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error : ${snapshot.error}');
                      } else {
                        return new Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],


      ),


      /* Container(
        child: Column(
          children: [
            DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: primaryColor,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        *//*indicator:  UnderlineTabIndicator(
                                borderSide: BorderSide(width: 0.0,color: Colors.white),
                                insets: EdgeInsets.symmetric(horizontal:16.0)
                            ),*//*

                        tabs: [
                          Tab(text: 'myNotification'.tr()),
                          Tab(text: 'addNotification'.tr()),
                        ],
                      ),
                    ),

                    // body of tab
                    Container(
                      //height of TabBarView
                      height: MediaQuery.of(context).size.height * 0.67,

                      child: TabBarView(children: <Widget>[




                      FutureBuilder<bool>(
                      future: sharedPref.getPref(),
                      builder: (context,snapshot){
                        if (snapshot.hasData) {
                          if (snapshot.data != null && snapshot.connectionState == ConnectionState.done ) {
                            return Container(
                              height:
                              MediaQuery.of(context).size.height * 0.36,

                              child:  _isLoaded?
                              _list.length>0?Container(
                                margin: EdgeInsets.all(10),
                                child: ListView.separated(
                                  separatorBuilder: (context, position) {
                                    return Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: (position != 0 && position % 4 == 0) ?
                                        AdmobBanner(
                                          adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                                          adSize: bannerSize,
                                          listener: (AdmobAdEvent event,
                                              Map<String, dynamic> args) {
                                            handleEvent(event, args, 'Banner');
                                          }, onBannerCreated: (AdmobBannerController controller) {
                                        },
                                        ): Container());
                                  },
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _list.length,
                                  itemBuilder: (BuildContext context,int index){
                                    return GestureDetector(
                                        onTap: ()async{
                                          if (await interstitialAd.isLoaded) {
                                            interstitialAd.show();
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(_list[index],snapshot.data)));
                                          }
                                          else {
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(_list[index],snapshot.data)));
                                            print('Interstitial ad is still loading...');
                                          }
                                        },
                                        child: PropertyTile(_list[index],snapshot.data)
                                    );
                                  },
                                ),
                              ):Container(child: Center(child: Text('noData'.tr())),)
                                  :Center(child: Text('noData'.tr()),),
                            );
                          }
                          else  {
                            return new Center(
                              child: Container(
                                  child: Text('noData'.tr())
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



                        //Add Notification

                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15,0,15,0),
                              child: Container(
                                margin:EdgeInsets.only(left: 10, right: 10, top: 5),
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
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      onTap: () => sharedPref.getPref().then(
                                              (value) => _showCountryDailog(value)),
                                      leading: Image.asset(
                                        "assets/images/country.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                      title: Text(
                                        selectedCountryName,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      onTap: () {
                                        if (selectedCountryId != null) {
                                          sharedPref.getPref().then(
                                                  (value) => _showCityDailog(value));
                                        } else {
                                          //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                        }
                                      },
                                      leading: Image.asset(
                                        "assets/images/city.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                      title: Text(
                                        selectedCityName,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      onTap: () {
                                        if (selectedCountryId != null &&
                                            selectedCityId != null) {
                                          sharedPref.getPref().then(
                                                  (value) => _showAreaDailog(value));
                                        } else {
                                          //Toast.show("Please select above", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                        }
                                      },
                                      leading: Image.asset(
                                        "assets/images/area.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                      title: Text(
                                        selectedAreaName,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    Divider(color: Colors.grey,),
                                    ListTile(
                                      onTap: ()=>sharedPref.getPref().then((value) => _showTypeDailog(value)),
                                      leading: Image.asset("assets/images/home.png",width: 30,height: 30,),
                                      title: Text(selectedTypeName,style: TextStyle(color: Colors.grey[600]),),
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (selectedCityId != null &&
                                            selectedCityId != "" &&
                                            selectedCountryId != null &&
                                            selectedCountryId != "" &&
                                            selectedAreaName != null &&
                                            selectedAreaName != "") {
                                          randNumber();
                                          makeNotificationRequest()
                                              .whenComplete(() {
                                            setState(() {});
                                          });
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 60,
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
                                            )),
                                        child: Text(
                                          'Notify'.tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: primaryColor,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("notifyNote".tr(),style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),),
                                        )),



                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 10
                            ),
                            Container(
                              height:
                              MediaQuery.of(context).size.height * 0.6,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                              ),
                              child: Column(
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Text(
                                        "myNotification".tr(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color: primaryColor,
                                    height: 1.5,
                                    width:MediaQuery.of(context).size.width *0.4,
                                  ),
                                  Container(
                                    height: 7,
                                  ),
                                  Container(
                                    height:
                                    MediaQuery.of(context).size.height *
                                        0.53,
                                    child: FutureBuilder<
                                        List<UserNotificationModel>>(
                                      future: getUserNotifications(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data != null &&
                                              snapshot.data.length > 0) {
                                            print(userid);
                                            return ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                snapshot.data.length,
                                                itemBuilder:
                                                    (context, index) {
                                                  return Container(
                                                      height: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .height *
                                                          0.16,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Container(
                                                                child:
                                                                Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                      const EdgeInsets.all(10.0),
                                                                      child: FutureBuilder<bool>(
                                                                        future: sharedPref.getPref(),
                                                                        builder: (context,snapshots){
                                                                          if (snapshots.hasData) {
                                                                            if (snapshots.data != null && snapshots.connectionState == ConnectionState.done ) {
                                                                                if(snapshots.data == true )
                                                                                  {
                                                                                    return Text("Address : " + snapshot.data[index].country +  " , " + snapshot.data[index].city + " , " +
                                                                                        snapshot.data[index].area +
                                                                                        "\nCategory : " +
                                                                                        snapshot.data[index].propertyCategory + "\nType : " + snapshot.data[index].type,
                                                                                      style:
                                                                                      TextStyle(fontSize: 14),
                                                                                    );
                                                                                  }
                                                                                else
                                                                                  {
                                                                                    return Text("عنوان : " + snapshot.data[index].country_ar +  " , " + snapshot.data[index].city_ar + " , " +
                                                                                        snapshot.data[index].area_ar +"\n"+
                                                                                        "  فئة : " + snapshot.data[index].propertyCategory_ar +"\n"+
                                                                                        "نوع : " + snapshot.data[index].type_ar ,
                                                                                      style:
                                                                                      TextStyle(fontSize: 14),
                                                                                    );                                                                                  }
                                                                            }
                                                                            else  {
                                                                              return new Center(
                                                                                child: Container(
                                                                                    child: Text('noData'.tr())
                                                                                ),
                                                                              );
                                                                            }

                                                                          }
                                                                          else if (snapshots.hasError) {
                                                                            return Text('Error : ${snapshots.error}');
                                                                          } else {
                                                                            return new Center(
                                                                              child: CircularProgressIndicator(),
                                                                            );
                                                                          }
                                                                        },
                                                                      ),


                                                                    ),
                                                                  ],
                                                                ),
                                                                width: MediaQuery.of(context).size.width *0.85,
                                                                alignment:Alignment.centerLeft,
                                                              ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () async {
                                                                    FirebaseDatabase
                                                                        .instance
                                                                        .reference()
                                                                        .child('userNotification')
                                                                        .orderByChild('notificationId')
                                                                        .equalTo(snapshot.data[index].notificationId)
                                                                        .once()
                                                                        .then((DataSnapshot snapshot) {
                                                                      Map<dynamic, dynamic>
                                                                      children =
                                                                          snapshot.value;
                                                                      children.forEach((key,
                                                                          value) {
                                                                        FirebaseDatabase.instance.reference().child('userNotification').child(key).remove();
                                                                      });
                                                                    }).whenComplete(() {
                                                                      setState(
                                                                              () {});
                                                                    });
                                                                  },
                                                                  icon:
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .red,
                                                                  ))
                                                            ],
                                                          ),

                                                          SizedBox(height: 4,),
                                                          Divider(
                                                            height: 2,
                                                            color: Colors.black54,
                                                            thickness: 1,
                                                            endIndent: 20,
                                                            indent: 20,
                                                          ),
                                                        ],
                                                      ));
                                                });
                                          } else {
                                            print("user id :$userid");

                                            return new Center(
                                              child: Container(
                                                  child: Text(
                                                      "No Notification Request")),
                                            );
                                          }
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error : ${snapshot.error}');
                                        } else {
                                          return new Center(
                                            child:
                                            CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],


                        ),



                      ]),
                    ),
                  ],
                )),
          ],
        ),
      ),*/
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  void getUid() {
    final User user = auth.currentUser;
    userid = user.uid;
    // here you write the codes to input the data into firestore
  }

  AdmobBannerSize bannerSize;
  AdmobBannerSize smallBannerSize;
  AdmobInterstitial interstitialAd;
  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;

  @override
  void initState() {
    getPropertyList();
    super.initState();
    getUid();
    Admob.requestTrackingAuthorization();
    bannerSize = AdmobBannerSize.LARGE_BANNER;
    smallBannerSize= AdmobBannerSize.BANNER;

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

  Future<void> _showCountryDailog(bool val) async {
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
                          'country'.tr(),
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
                  child: FutureBuilder<List<LocationModel>>(
                    future: getCountryList(),
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
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        !val
                                            ? selectedCountryName =snapshot.data[index].name_ar
                                            : selectedCountryName =snapshot.data[index].name;

                                        engCountry = snapshot.data[index].name;
                                        arCountry = snapshot.data[index].name_ar;
                                        selectedCountryId =
                                            snapshot.data[index].id;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: Text(
                                        !val
                                            ? snapshot.data[index].name_ar
                                            : snapshot.data[index].name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
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
  }

  Future<void> _showCityDailog(bool val) async {
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
                          'city'.tr(),
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
                  child: FutureBuilder<List<LocationModel>>(
                    future: getCityList(selectedCountryId),
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
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        !val
                                            ? selectedCityName =
                                                snapshot.data[index].name_ar
                                            : selectedCityName =
                                                snapshot.data[index].name;
                                        engCity = snapshot.data[index].name;
                                        arCity = snapshot.data[index].name_ar;
                                        selectedCityId =
                                            snapshot.data[index].id;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: Text(
                                        !val
                                            ? snapshot.data[index].name_ar
                                            : snapshot.data[index].name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
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
  }

  Future<void> _showAreaDailog(bool val) async {
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
                          'areaSelect'.tr(),
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
                  child: FutureBuilder<List<LocationModel>>(
                    future: getAreaList(selectedCountryId,selectedCityId),
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
                                          !val
                                              ? selectedAreaName =
                                                  snapshot.data[index].name_ar
                                              : selectedAreaName =
                                                  snapshot.data[index].name;
                                          engArea = snapshot.data[index].name;
                                          arArea = snapshot.data[index].name_ar;
                                          selectedAreaId =
                                              snapshot.data[index].id;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        child: Text(
                                          !val
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
  }

  Future<void> _showTypeDailog(bool val) async {
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
                        child: Text('propertyType'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color:Colors.black,fontWeight: FontWeight.w600),),
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
                    future: getTypeList(),
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
                                          !val?selectedTypeName=snapshot.data[index].name_ar:selectedTypeName=snapshot.data[index].name;
                                          engType=snapshot.data[index].name;
                                          arType=snapshot.data[index].name_ar;
                                          selectedTypeId=snapshot.data[index].id;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        child: Text(!val?snapshot.data[index].name_ar:snapshot.data[index].name,textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color:Colors.black),),
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
  }


  Future<void> makeNotificationRequest() async {
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    final databaseReference = FirebaseDatabase.instance.reference();
    User user = FirebaseAuth.instance.currentUser;

    databaseReference.child("userNotification").push().set({
      'userid': user.uid.toString(),
      'country': engCountry,
      'city': engCity,
      'area': engArea,
      'type' : engType,
      'propertyCategory': isRent ? "rent" : "buy",
      'country_ar': arCountry,
      'city_ar': arCity,
      'area_ar' : arArea,
      'type_ar' : arType,
      'propertyCategoryAr': isRent? arRent : arBuy,
      'notificationId': notificationId,
    }).whenComplete(() => pr.hide());
  }

  Future<List<UserNotificationModel>> getUserNotifications() async {
    List<UserNotificationModel> list = [];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child("userNotification")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        var KEYS = dataSnapshot.value.keys;
        var DATA = dataSnapshot.value;

        for (var individualKey in KEYS) {
          UserNotificationModel userNotificationModel =
              new UserNotificationModel(
                  DATA[individualKey]['userid'],
                  DATA[individualKey]['city'],
                  DATA[individualKey]['country'],
                  DATA[individualKey]['area'],
                  DATA[individualKey]['type'],
                  DATA[individualKey]['propertyCategory'],
                  DATA[individualKey]['city_ar'],
                  DATA[individualKey]['country_ar'],
                  DATA[individualKey]['area_ar'],
                  DATA[individualKey]['type_ar'],
                  DATA[individualKey]['propertyCategoryAr'],
                  DATA[individualKey]['notificationId'],
              );
          if (DATA[individualKey]['userid'] == userid) {
            list.add(userNotificationModel);
          }
        }
      }
    });
    return list;
  }

  String randNumber() {
    return notificationId = rng.nextInt(100000).toString();
  }

/*  Future getPropertyDetail ()async
  {
    String category ;
    isRent ? category = "rent" : category = "buy" ;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("userNotification").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {

          if( DATA[individualKey]['country'] == countryController.text && DATA[individualKey]['city']  == cityController.text && DATA[individualKey]['area'] == areaController.text &&  DATA[individualKey]['propertyCategory'] == category)
          {
            FirebaseDatabase.instance.reference().child("userData").child(DATA[individualKey]['userid']).once().then((DataSnapshot userSnapshot)
            {
              sendPropertyNotification(userSnapshot.value['token']);
            });
          }

        }
      }
    });
  }*/

  List<Property> _list=[];

  getPropertyList() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot) async {
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          Property property = new Property(
            individualKey,
            DATA[individualKey]['status'],
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['image'],
            DATA[individualKey]['name'].toString(),
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['typeOfProperty'],
            DATA[individualKey]['propertyCategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['beds'].toString(),
            DATA[individualKey]['bath'].toString(),
            DATA[individualKey]['measurementArea'].toString(),
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['furnish'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['floor'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['furnish_ar'],
            DATA[individualKey]['payment_ar'],
            DATA[individualKey]['typeOfProperty_ar'],
            DATA[individualKey]['propertyCategoryAr'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
          );

          //print("country notification name : ${data[individualKey]['country']}");
          // print("country property name : ${DATA[individualKey]['country']}");
          await databaseReference.child("userNotification").orderByChild("userid").equalTo(userid).once().then((DataSnapshot dataSnapshot){
            if(dataSnapshot.value!=null ){
              var KEYS= dataSnapshot.value.keys;
              var data=dataSnapshot.value;

              for(var individualKeys in KEYS) {

                print("country notification name : ${data[individualKeys]['country']}");
                print("country property name : ${DATA[individualKey]['country']}");

                if( data[individualKeys]['country'] ==  DATA[individualKey]['country'] && data[individualKeys]['city']  == DATA[individualKey]['city'] && data[individualKeys]['area'] == DATA[individualKey]['area'] &&  data[individualKeys]['propertyCategory'] ==  DATA[individualKey]['propertyCategory'] && data[individualKeys]['type'] == DATA[individualKey]['typeOfProperty'] )
                {

                  setState(() {
                    _list.add(property);
                  });
                }

              }
            }
          });


        }

      }
    });

    setState(() {
      _isLoaded=true;
    });
    _list = _list.reversed.toList();

  }


}
