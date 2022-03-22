import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/model/location.dart';
import 'package:propertymarket/screens/property_detail.dart';
import 'package:propertymarket/screens/search_list.dart';
import 'package:propertymarket/screens/search_property.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/getters.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:propertymarket/widget/property_tile.dart';
import 'package:easy_localization/easy_localization.dart';
enum rentOrBuy { rent, buy }
class Best extends StatefulWidget {




  @override
  _BestState createState() => _BestState();
}

class _BestState extends State<Best> {
  SharedPref sharedPref=new SharedPref();

  double bedroom=0;
  bool bedAll=false;
  bool priceAll=false;
  bool areaAll=false;






  bool isLoaded=false;
  bool isRent=true;
  bool sortOpened=false;
  bool filterOpened=false;
  bool isAccessding=false;


  AdmobBannerSize bannerSize;
  AdmobBannerSize smallBannerSize;
  AdmobInterstitial interstitialAd;
  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

    priceFromController.text="0";
    priceToController.text="0";
    areaToController.text="0";
    areaFromController.text="0";
    getBest();
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
  Future<List<CategoryModel>> getCategoryList() async {
    List<CategoryModel> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("categories").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          CategoryModel property = new CategoryModel(
            individualKey,
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['name'],
            DATA[individualKey]['image'],
            DATA[individualKey]['time'],
          );
          list.add(property);



        }
      }
    });
    return list;
  }
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }
  final _scrollController = ScrollController();
  final priceFromController=TextEditingController();
  final priceToController=TextEditingController();
  final areaToController=TextEditingController();
  final areaFromController=TextEditingController();
  List<Item> list=[];


  getBest() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null) {
        var KEYS = dataSnapshot.value.keys;
        var DATA = dataSnapshot.value;

        for (var individualKey in KEYS) {
          Item property = new Item(
            individualKey,
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['status'],
            DATA[individualKey]['name'].toString(),
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['category'],
            DATA[individualKey]['subcategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['payment_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['categoryAr'],
            DATA[individualKey]['subcategoryAr'],
            DATA[individualKey]['coverImage'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['image'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['best'],
          );
          if (property.best) {
            list.add(property);
          }
        }


        list.sort((a, b) =>
            DateTime
                .parse(a.datePosted)
                .millisecondsSinceEpoch
                .compareTo(DateTime
                .parse(b.datePosted)
                .millisecondsSinceEpoch));
        list = list.reversed.toList();
      }
    });
    setState(() {
      isLoaded=true;
    });
  }





  Future<bool> _onWillPop(){
    if(sortOpened){
      setState(() {
        sortOpened=false;
      });
    }
    else if(filterOpened){
      setState(() {
        filterOpened=false;
      });
    }
    else{
      Navigator.pop(context);
    }

  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: FutureBuilder<bool>(
          future: sharedPref.getPref(),
          builder: (context,snapshot){
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return SafeArea(
                    child: Stack(
                      children: [
                        ListView(
                          children: [
                            Container(
                              height: 100,

                              child: Stack(
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      border: Border(
                                        bottom: BorderSide(width: 0.2, color: Colors.grey[500]),
                                      ),

                                    ),
                                  ),
                                  Center(
                                    child: InkWell(

                                      onTap: ()async{
                                        if (await interstitialAd.isLoaded) {
                                          interstitialAd.show();
                                          if(snapshot.data){

                                            final result = await showSearch<String>(
                                              context: context,
                                              delegate: NameSearchEn(list),
                                            );
                                          }
                                          else{
                                            final result = await showSearch<String>(
                                              context: context,
                                              delegate: NameSearch(list),
                                            );
                                          }
                                        }
                                        else {
                                          if(snapshot.data){

                                            final result = await showSearch<String>(
                                              context: context,
                                              delegate: NameSearchEn(list),
                                            );
                                          }
                                          else{
                                            final result = await showSearch<String>(
                                              context: context,
                                              delegate: NameSearch(list),
                                            );
                                          }

                                          print('Interstitial ad is still loading...');
                                        }


                                        //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SearchProperty()));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10),
                                        height: 45,
                                        margin: EdgeInsets.only(left: 10,right: 10,top: 50),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search,color: Colors.grey[600],),
                                            SizedBox(width: 10,),
                                            Text('searchProperty'.tr(),style: TextStyle(color: Colors.grey[600],fontSize: 18),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: IconButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.arrow_back,color: Colors.white,),
                                    ),
                                  )

                                ],
                              ),
                            ),




                            isLoaded?
                            list.length>0?Container(
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
                                itemCount: list.length,
                                itemBuilder: (BuildContext context,int index){
                                  return GestureDetector(
                                      onTap: ()async{
                                        if (await interstitialAd.isLoaded) {
                                          interstitialAd.show();
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(list[index],snapshot.data)));
                                        }
                                        else {
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(list[index],snapshot.data)));
                                          print('Interstitial ad is still loading...');
                                        }
                                      },
                                      child: PropertyTile(list[index],snapshot.data)
                                  );
                                },
                              ),
                            ):Container(margin: EdgeInsets.only(top: 200),child: Center(child: Text('noData'.tr())),)
                                :Center(child: CircularProgressIndicator(),)

                          ],
                        ),

                        Align(
                            alignment: Alignment.bottomCenter,
                            child: AdmobBanner(
                              adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                              adSize: bannerSize,
                              listener: (AdmobAdEvent event,
                                  Map<String, dynamic> args) {
                                handleEvent(event, args, 'Banner');
                              }, onBannerCreated: (AdmobBannerController controller) {
                            },
                            )
                        )



                      ],
                    )
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

      ),
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
                height: MediaQuery.of(context).size.height*0.7,
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
                                                                              engCountry=snapshot.data[index].name;
                                                                              arCountry=snapshot.data[index].name_ar;
                                                                              selectedCountryId=snapshot.data[index].id;
                                                                            });
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
                                                                                engCity=snapshot.data[index].name;
                                                                                arCity=snapshot.data[index].name_ar;
                                                                                selectedCityId=snapshot.data[index].id;
                                                                              });
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
                                                                                  engArea=snapshot.data[index].name;
                                                                                  arArea=snapshot.data[index].name_ar;
                                                                                  selectedAreaId=snapshot.data[index].id;
                                                                                });
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

                              Text('selectCategory'.tr(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
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






                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: ()async{
                          interstitialAd.show();
                          if (await interstitialAd.isLoaded) {
                            interstitialAd.show();
                            if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                              Navigator.pop(context);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Best()));
                            }
                          }
                          else {
                            if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                              Navigator.pop(context);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Best()));
                            }
                          }


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
