import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/model/location.dart';
import 'package:propertymarket/model/news_model.dart';
import 'package:propertymarket/screens/news_details.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart';
class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  SharedPref sharedPref=new SharedPref();

  static String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} ${'yearAgo'.tr()}';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1yearAgo'.tr() : 'lastYear'.tr();
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} ${'monthsAgo'.tr()}';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1monthAgo'.tr() : 'lastMonth'.tr();
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} ${'weeksAgo'.tr()}';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1weekAgo'.tr() : 'lastWeek'.tr();
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} ${'daysAgo'.tr()}';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1dayAgo'.tr() : 'yesterday'.tr();
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} ${'hoursAgo'.tr()}';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1hourAgo'.tr() : 'anHourAgo'.tr();
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} ${'minutesAgo'.tr()}';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1minuteAgo'.tr() : 'aminuteAgo'.tr();
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} ${'secondsAgo'.tr()}';
    } else {
      return 'justNow'.tr();
    }
  }

  Future<List<NewsModel>> getNewsList() async {
    List<NewsModel> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("news").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          NewsModel newsModel = new NewsModel(
            individualKey,
            DATA[individualKey]['image'],
            DATA[individualKey]['details'],
            DATA[individualKey]['details_ar'],
            DATA[individualKey]['date'],

          );

          list.add(newsModel);

        }
      }
    });
    list.sort((a, b) => DateTime.parse(a.date).millisecondsSinceEpoch.compareTo(DateTime.parse(b.date).millisecondsSinceEpoch));
    list=list.reversed.toList();
    return list;
  }

  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Admob.requestTrackingAuthorization();
    bannerSize = AdmobBannerSize.LARGE_BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: Platform.isAndroid ? androidInterstitialVideo : iosAdmobInterstitialVideo,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    interstitialAd.load();
  }

  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: sharedPref.getPref(),
        builder: (context,prefshot){
          if (prefshot.hasData) {
            if (prefshot.data != null) {
              return SafeArea(
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
                                  child: Text('news'.tr(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<List<NewsModel>>(
                              future: getNewsList(),
                              builder: (context,snapshot){
                                if (snapshot.hasData) {
                                  if (snapshot.data != null && snapshot.data.length>0) {
                                    return ListView.separated(
                                      separatorBuilder: (context, position) {
                                        return Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: (position != 0 && position % 3 == 0) ?
                                            AdmobBanner(
                                              adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                                              adSize: bannerSize,
                                              listener: (AdmobAdEvent event,
                                                  Map<String, dynamic> args) {
                                                handleEvent(event, args, 'Banner');
                                              }, onBannerCreated: (AdmobBannerController controller) {
                                            },
                                            ): Divider());
                                      },
                                      itemCount: snapshot.data.length,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext context,int index){
                                        return InkWell(
                                          onTap: ()async{
                                            if (await interstitialAd.isLoaded) {
                                              interstitialAd.show();
                                              Navigator.push(
                                                  context, MaterialPageRoute(builder: (BuildContext context) => NewsDetails(snapshot.data[index], prefshot.data)));                                        }
                                            else {

                                              Navigator.push(
                                                  context, MaterialPageRoute(builder: (BuildContext context) => NewsDetails(snapshot.data[index], prefshot.data)));                                          print('Interstitial ad is still loading...');
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: CachedNetworkImage(
                                                    imageUrl: snapshot.data[index].image,
                                                    fit: BoxFit.cover,
                                                    height: 60,
                                                    placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(prefshot.data?snapshot.data[index].details:snapshot.data[index].details_ar,maxLines: 2,),
                                                            SizedBox(height: 5,),
                                                            Text(timeAgoSinceDate(snapshot.data[index].date),style: TextStyle(color:Colors.black,fontSize: 10),),
                                                          ],
                                                        )
                                                    )
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
                          )
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AdmobBanner(
                          adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                          adSize: AdmobBannerSize.BANNER,
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
          else if (prefshot.hasError) {
            return Text('Error : ${prefshot.error}');
          } else {
            return new Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
