import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/screens/property_list.dart';

import '../values/constants.dart';

class SubCategory extends StatefulWidget {

  CategoryModel categoryModel;
  String country,city,area;
  String countryAr,cityAr,areaAr;


  SubCategory(this.categoryModel, this.country, this.city, this.area,
      this.countryAr, this.cityAr, this.areaAr);

  @override
  _SubCategoryState createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {

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
    await databaseReference.child("categories").child(widget.categoryModel.id).child("sub_categories").once().then((DataSnapshot dataSnapshot){
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 0.2, color: Colors.grey[500]),
                      ),

                    ),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text('subCategories'.tr(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<CategoryModel>>(
                      future: getCategoryList(),
                      builder: (context,snapshot){
                        if (snapshot.hasData) {
                          if (snapshot.data != null && snapshot.data.length>0) {
                            return ListView.builder(
                              itemCount: snapshot.data.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context,int index){
                                return InkWell(
                                  onTap: ()async{
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PropertyList(widget.country,widget.city,widget.area,widget.categoryModel.name,snapshot.data[index].name,widget.countryAr,widget.cityAr,widget.areaAr,widget.categoryModel.name_ar,snapshot.data[index].name_ar,widget.categoryModel.id,snapshot.data[index].id)));

                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(15),
                                    child: Row(
                                      children: [

                                        Expanded(
                                            flex: 7,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(context.locale.languageCode=="en"?snapshot.data[index].name:snapshot.data[index].name_ar,maxLines: 2,),
                                                    //SizedBox(height: 5,),
                                                    //Text(timeAgoSinceDate(snapshot.data[index].date),style: TextStyle(color:Colors.black,fontSize: 10),),
                                                  ],
                                                )
                                            )
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: CachedNetworkImage(
                                            imageBuilder: (context, imageProvider) => Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                    image: imageProvider, fit: BoxFit.cover),
                                              ),
                                            ),
                                            imageUrl: snapshot.data[index].image,
                                            fit: BoxFit.cover,
                                            height: 60,
                                            placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),

                                      ],
                                    ),

                                  ),
                                );
                              },
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
                  AdmobBanner(
                    adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                    adSize: bannerSize,
                    listener: (AdmobAdEvent event,
                        Map<String, dynamic> args) {
                      handleEvent(event, args, 'Banner');
                    }, onBannerCreated: (AdmobBannerController controller) {
                  },
                  )
                ],
              ),

            ],
          )
      ),
    );
  }
}
