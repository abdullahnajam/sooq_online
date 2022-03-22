import 'dart:convert';
import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/model/location.dart';
import 'package:propertymarket/navigator/bottom_navigation.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/getters.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:toast/toast.dart';
import 'package:easy_localization/easy_localization.dart';


class AddItem extends StatefulWidget {

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {

  final FirebaseAuth auth = FirebaseAuth.instance;


  SharedPref sp = SharedPref();
  bool lang ;

  String getUserId() {
    // getting current user id
    final User user = auth.currentUser;
    return user.uid;
  }
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  @override
  void initState() {
    final User user = auth.currentUser;
    if(user != null)
    {
      sp.getPref().then((value) {
        lang = value;
        print ("language is : $lang");

      });
    }
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

    super.initState();

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

  String status,addPublisherId;
  final _scrollController = ScrollController();

  final enpriceController=TextEditingController();
  final arpriceController=TextEditingController();
  final numpriceController=TextEditingController();
  final wordPriceController=TextEditingController();
  final phoneController=TextEditingController();
  final emailController=TextEditingController();
  final countryController=TextEditingController();
  final countryControllert=TextEditingController();
  final cityController=TextEditingController();
  final cityControllert=TextEditingController();
  final areaController=TextEditingController();
  final areaControllert=TextEditingController();
  final categoryController=TextEditingController();
  final subCategoryController=TextEditingController();
  final categoryControllert=TextEditingController();
  final descriptionController=TextEditingController();
  final paymentController=TextEditingController();
  final agentNameController=TextEditingController();
  final snoController=TextEditingController();


  //arabic text field


  final arwordPriceController=TextEditingController();
  final arSubCategoryController=TextEditingController();
  final ardescriptionController=TextEditingController();
  final arpaymentController=TextEditingController();
  final aragentNameController=TextEditingController();

  String selectedCountryId="";
  String selectedCategoryId="";
  String selectedSubCategoryId="";
  String selectedCityId="";
  String selectedAreaId="";
  String selectedTypeId="";

  String selectedCountryAR="";
  String selectedCityAR="";
  String selectedAreaAR="";
  String selectedTypeAR="";
  bool isSponsered=false;



  String engCountry = "";
  String engCity = "";
  String engArea = "";
  String engCategory = "";
  String engSubCategory = "";
  String engType="";

  String arCountry = "";
  String arCity = "";
  String arArea = "";
  String arCategory = "";
  String arSubCategory = "";
  String arType="";


  String selectedCountryName = 'selectCountry'.tr();
  String selectedCityName = 'selectCity'.tr();
  String selectedAreaName = 'selectArea'.tr();
  String selectedTypeName='selectType'.tr();



  Future<List<LocationModel>> getTypeList() async {
    List<LocationModel> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("type").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          LocationModel locationModel = new LocationModel(
            individualKey,
            DATA[individualKey]['name'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['time'],
          );
          list.add(locationModel);

        }
      }
    });
    list.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
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
                                            ?  countryControllert.text  = snapshot.data[index].name_ar
                                            : countryControllert.text = snapshot.data[index].name ;

                                        selectedCountryAR = snapshot.data[index].name_ar;
                                        countryController.text = snapshot.data[index].name ;
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
                                            ?  cityControllert.text  = snapshot.data[index].name_ar
                                            : cityControllert.text = snapshot.data[index].name ;

                                        selectedCityAR = snapshot.data[index].name_ar;
                                        cityController.text = snapshot.data[index].name ;
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
                                              ?  areaControllert.text  = snapshot.data[index].name_ar
                                              : areaControllert.text = snapshot.data[index].name ;

                                          selectedAreaAR = snapshot.data[index].name_ar;
                                          areaController.text = snapshot.data[index].name ;
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

  Future<void> _showCategoryDialog(bool val) async {
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
                                          !val
                                              ?  categoryControllert.text  = snapshot.data[index].name_ar
                                              : categoryControllert.text = snapshot.data[index].name ;

                                          arCategory = snapshot.data[index].name_ar ;
                                          engCategory = snapshot.data[index].name ;
                                          selectedCategoryId = snapshot.data[index].id;
                                        });
                                        getAttributes(context.locale.languageCode);
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

  Future<void> _showSubCategoryDialog(bool val) async {
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
                                          !val
                                              ?  subCategoryController.text  = snapshot.data[index].name_ar
                                              : subCategoryController.text = snapshot.data[index].name ;

                                          arSubCategory = snapshot.data[index].name_ar ;
                                          engSubCategory = snapshot.data[index].name ;
                                          selectedSubCategoryId = snapshot.data[index].id;
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

  Future<void> _showValueDialog(bool val,int index,String title,String id) async {
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
                          title,
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
                    future: getValueList(id,selectedCategoryId),
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
                                              ?  attributeValueController[index].text  = snapshot.data[index].name_ar
                                              : attributeValueController[index].text = snapshot.data[index].name ;

                                          LocationModel model=LocationModel(
                                            snapshot.data[index].id,
                                              snapshot.data[index].name,
                                              snapshot.data[index].name_ar,
                                              snapshot.data[index].time,
                                          );
                                          attributes[index].selectedValue = model;
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




  


  String photoUrl="";
  final _formKey = GlobalKey<FormState>();

  bool best=false;
  submitData(){
    final databaseReference = FirebaseDatabase.instance.reference();
    print("url item ${imageURLs.length}");
    String id="itemId${DateTime.now().microsecondsSinceEpoch}";
    databaseReference.child("item").child(id).set({
      'addPublisherId' : addPublisherId,
      'status' : status,
      'name': wordPriceController.text,
      'category': engCategory,
      'subcategory': engSubCategory,
      'categoryAr': arCategory,
      'subcategoryAr': arSubCategory,
      'price_ar': arpriceController.text,
      'price_en': enpriceController.text,
      'numericalPrice': int.parse(numpriceController.text),
      'call': phoneController.text,
      'city': cityController.text,
      'country': countryController.text,
      'datePosted': DateTime.now().toString(),
      'description': descriptionController.text,
      'email': emailController.text,
      'image': imageURLs,
      'location': "${areaController.text}, ${cityController.text}, ${countryController.text}",
      'area': areaController.text,
      'coverImage':imageURLs[0],
      'whatsapp': phoneController.text,
      'payment': paymentController.text,
      'agentName': agentNameController.text,
      'sponsered': isSponsered,
      'best': best,
      'serial': snoController.text,
      'description_ar': ardescriptionController.text,
      'name_ar': arwordPriceController.text,
      'agentName_ar': aragentNameController.text,
      'payment_ar': arpaymentController.text,
      'city_ar': selectedCityAR,
      'country_ar': selectedCountryAR,
      'area_ar': selectedAreaAR,

    }).then((value) async {
      for(int i = 0; i<attributes.length;i++){
        FirebaseDatabase.instance.reference().child("item").child(id).child("attributes").push().set({
          'attribute_id' : attributes[i].attribute.id,
          'name' : attributes[i].attribute.name,
          'name_ar' : attributes[i].attribute.name_ar,
          'value_id' : attributes[i].selectedValue.id,
          'value_name' : attributes[i].selectedValue.name,
          'value_name_ar' : attributes[i].selectedValue.name_ar,

        });
      }
      if(getUserId() == adminId) {
        //sendNotification();
        Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AddItem()));
      }
      else {

        if (await interstitialAd.isLoaded) {
          interstitialAd.show();
          Navigator.pushReplacement(context, new MaterialPageRoute(
              builder: (context) => BottomBar(5)));
          Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
        else {
          Navigator.pushReplacement(context, new MaterialPageRoute(
              builder: (context) => BottomBar(5)));
          Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }



    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }

  sendNotification() async{
    String url='https://fcm.googleapis.com/fcm/send';
    Uri myUri = Uri.parse(url);
    await http.post(
      myUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'New Property Added',
            "sound" : "default",
            'title': 'New property added in ${areaController.text}, ${cityController.text}, ${countryController.text} at ${enpriceController.text}'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': "/topics/user",
        },
      ),
    );
  }

  List<File> imageFiles=[];
  List<String> imageURLs=[];
  List<String> _progress=[];
  File imagefile;
  void fileSet(File file){
    setState(() {
      if(file!=null){
        imagefile=file;
        imageFiles.add(file);
        _progress.add("Uploading");
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
  int photoIndex=-1;

  Future uploadImageToFirebase(BuildContext context) async {
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagefile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
        photoUrl=value;
        imageURLs.add(value);
        print("value $value");
        setState(() {
          _progress[_progress.length-1]="";
        });
      },
    );
  }

  List<Attribute> attributes=[];
  List<TableRow> rows=[];
  bool attributeLoaded=false;

  List<TextEditingController> attributeValueController=[];

  Future getAttributes(String language) async {
    attributes=[];
    attributeValueController=[];
    setState(() {
      attributeLoaded=false;
    });
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("categories").child(selectedCategoryId).child("attribute").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          LocationModel locationModel = new LocationModel(
            individualKey,
            DATA[individualKey]['name'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['time'],
          );
          LocationModel value = new LocationModel(
            "",
            "",
            "",
            0,
          );
          Attribute attribute = new Attribute(locationModel,value);
          attributes.add(attribute);
          attributeValueController.add(TextEditingController());


        }
      }
    });
    setState(() {
      for(int i=0;i<attributes.length;i++){
        rows.add(TableRow(
            children: [
              Container(
                child: Text(language=="en"?attributes[i].attribute.name:attributes[i].attribute.name_ar,textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 5),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                maxLines: 1,
                readOnly: true,
                onTap: (){
                  bool val=language=="en"?true:false;
                  _showValueDialog(
                      val,
                      i,
                      language=="en"?attributes[i].attribute.name:attributes[i].attribute.name_ar,
                      attributes[i].attribute.id,

                  );
                },
                controller: attributeValueController[i],
                decoration: InputDecoration(hintText:'enterNameA'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
              ),
            ]
        ));
      }
      attributeLoaded=true;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              imageFiles.length>0?
              Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Container(
                        child: GestureDetector(
                          onTap: (){
                            if(_progress[_progress.length-1]==""){
                              _showPicker(context);
                            }
                            else
                              Toast.show("Image Uploading", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                          },
                          child: Image.asset("assets/images/add.png",width: 50,height: 50,),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.all(10),
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageFiles.length,
                          itemBuilder: (BuildContext context,int index){
                            return GestureDetector(
                                onTap: (){

                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (_) {
                                                  return FullScreenImage(
                                                    imageUrl: imageFiles[index],
                                                    tag: "generate_a_unique_tag",
                                                  );
                                                }));
                                          },
                                          child: Hero(
                                            child : Container(
                                              height: 85,
                                              width: 85,
                                              margin: EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: FileImage(imageFiles[index]),
                                                    fit: BoxFit.cover,
                                                  )
                                              ),
                                            ),

                                            tag: "generate_a_unique_tag",
                                          ),
                                        ),
                                        Positioned(
                                            top : 5,
                                            right : 10,
                                            child: InkWell(
                                                onTap : ()  {
                                                  print("button press");
                                                  setState(() {
                                                    imageFiles.removeAt(index);
                                                    imageFiles.sort();
                                                    imageURLs.removeAt(index);
                                                    imageURLs.sort();
                                                  });
                                                },

                                                child: Icon(Icons.delete,color: Colors.red,))
                                        ),
                                      ],
                                    ),
                                    Text(_progress[index],style: TextStyle(fontSize: 12),)
                                  ],
                                )
                            );
                          },
                        ),
                      )
                    ],
                  )
              ):
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: GestureDetector(
                  onTap: (){
                    _showPicker(context);
                  },
                  child: Image.asset("assets/images/add.png",width: 50,height: 50,),
                ),
              ),

              Table(
                columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.7)},
                border: TableBorder.all(width: 0.5,color: Colors.grey),
                children: [
                  TableRow(
                      children: [
                        Container(
                          child: Text('name'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                controller: arwordPriceController,
                                decoration: InputDecoration(hintText:'enterNameA'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                controller: wordPriceController,
                                decoration: InputDecoration(hintText:'enterNameE'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )


                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('price'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller:enpriceController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                decoration: InputDecoration(hintText:'priceE'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller:arpriceController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                decoration: InputDecoration(hintText:'priceA'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller:numpriceController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                decoration: InputDecoration(hintText:'numberOnly'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                          ],
                        )


                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('serialNo'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),

                        Container(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller:snoController,
                            maxLines: 1,
                            decoration: InputDecoration(hintText:'enterSerialNo'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),

                  TableRow(
                      children: [
                        Container(

                          child: Text('description'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: descriptionController,
                                decoration: InputDecoration(hintText:'descriptionE'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: ardescriptionController,
                                decoration: InputDecoration(hintText:'descriptionA'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )

                      ]),

                  TableRow(
                      children: [
                        Container(
                          child: Text('phoneNo'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),

                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(hintText:"enterPhoneNo".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('email'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: emailController,
                            decoration: InputDecoration(hintText:"enterEmail".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('agentName'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: agentNameController,

                                decoration: InputDecoration(hintText:"enterAgentNameE".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: aragentNameController,

                                decoration: InputDecoration(hintText:"enterAgentNameA".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )

                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('country'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: countryControllert,
                            readOnly: true,
                            onTap: (){
                              _showCountryDailog(lang);
                            },
                            decoration: InputDecoration(hintText:"selectCountry".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('city'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: cityControllert,
                            readOnly: true,
                            onTap: (){
                              _showCityDailog(lang);
                            },
                            decoration: InputDecoration(hintText:"selectCity".tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('areaAdd'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: areaControllert,
                            readOnly: true,
                            onTap: (){
                              _showAreaDailog(lang);
                            },
                            decoration: InputDecoration(hintText:'selectArea'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),

                  TableRow(
                      children: [
                        Container(
                          child: Text('category'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: categoryControllert,
                            readOnly: true,
                            onTap: (){
                              _showCategoryDialog(lang);
                            },
                            decoration: InputDecoration(hintText:'selectCategory'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),

                  TableRow(
                      children: [
                        Container(
                          child: Text('subCategory'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: TextFormField(
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: subCategoryController,
                            readOnly: true,
                            onTap: (){
                              _showSubCategoryDialog(lang);
                            },
                            decoration: InputDecoration(hintText:'selectSubCategory'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                          ),
                        ),
                      ]),

                  TableRow(
                      children: [
                        Container(
                          child: Text('paymentType'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: paymentController,

                                decoration: InputDecoration(hintText:'enterPaymentTypeE'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                controller: arpaymentController,

                                decoration: InputDecoration(hintText:'enterPaymentTypeA'.tr(),contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )

                      ]),


                ],
              ),

              AttributeTable(),



              if(FirebaseAuth.instance.currentUser.uid==adminId)
                CheckboxListTile(
                    title: Text("best".tr()),
                    value: best,
                    activeColor: primaryColor,
                    onChanged: (bool value){
                      setState(() {
                        best=value;

                      });
                    }
                ),
              CheckboxListTile(
                  title: Text("sponsoredProperty".tr()),
                  value: isSponsered,
                  activeColor: primaryColor,
                  onChanged: (bool value){
                    setState(() {
                      isSponsered=value;

                    });
                  }
              ),


              Container(
                margin: EdgeInsets.all(10),
                child: RaisedButton(
                  onPressed: (){
                    print("url lenght : ${imageURLs.length}");
                    if (_formKey.currentState.validate()) {
                      if(imageURLs.length>0)
                      {
                        if( getUserId() == adminId  )
                        {
                          status = "approved";
                          addPublisherId = getUserId();
                          submitData();
                          getNotificationUser();
                        }
                        else{
                          status = "pending";
                          addPublisherId = getUserId();
                          submitData();
                        }
                      }
                      else
                      {
                        Toast.show("Please add atleast on image", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      }
                    }
                    else{
                      Toast.show("Enter all the fields", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }


                  },
                  color: primaryColor,
                  child: Text("addProperty".tr(),style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        )
    );
  }
  Table AttributeTable(){
    return Table(
      columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.7)},
      border: TableBorder.all(width: 0.5,color: Colors.grey),
      children: rows,
    );
  }
  Future getNotificationUser ()async  {
    String category ;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("userNotification").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {

          if( DATA[individualKey]['country'] == countryController.text && DATA[individualKey]['city']  == cityController.text && DATA[individualKey]['area'] == areaController.text)
          {
            FirebaseDatabase.instance.reference().child("userData").child(DATA[individualKey]['userid']).once().then((DataSnapshot userSnapshot)
            {
              sendPropertyNotification(userSnapshot.value['token']);
            });
          }

        }
      }
    });
  }
  sendPropertyNotification(String token) async{
    String url='https://fcm.googleapis.com/fcm/send';
    Uri myUri = Uri.parse(url);
    await http.post(
      myUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'New Property Added',
            "sound" : "default",
            'title': 'New property added in ${areaController.text}, ${cityController.text}, ${countryController.text} at ${enpriceController.text}'
            /* 'body': 'The Property Type You Have Asked For Is Added',
            'title': 'Your Wish list Property Is Added',
            "sound" : "default"*/
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '$token',
        },
      ),
    );
  }


}


class FullScreenImage extends StatelessWidget {
  final File imageUrl;
  final String tag;

  const FullScreenImage({Key key, this.imageUrl, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
              tag: tag,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image : FileImage(
                        imageUrl,
                      ),
                      fit: BoxFit.contain,

                    )
                ),
              )
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class Attribute{
  LocationModel attribute;
  LocationModel selectedValue;

  Attribute(this.attribute, this.selectedValue);
}