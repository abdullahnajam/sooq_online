import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:propertymarket/model/news_model.dart';
import 'package:propertymarket/model/trending_model.dart';
import 'package:propertymarket/screens/news_details.dart';
import 'package:propertymarket/screens/trending_details.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_player/video_player.dart';

bool videoPauseTrending = false;

class Trending extends StatefulWidget {
  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
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

  Future<List<TrendingModel>> getTrendingList() async {
    List<TrendingModel> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("trending").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          TrendingModel trendingModel = new TrendingModel(
            individualKey,
            DATA[individualKey]['video'],
            DATA[individualKey]['icon'],
            DATA[individualKey]['title'],
            DATA[individualKey]['title_ar'],
            DATA[individualKey]['details'],
            DATA[individualKey]['details_ar'],
            DATA[individualKey]['date'],

          );

          list.add(trendingModel);

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

  bool videoplay = true;

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
                                  child: Text('trending'.tr(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<List<TrendingModel>>(
                              future: getTrendingList(),
                              builder: (context,snapshot){
                                if (snapshot.hasData) {
                                  if (snapshot.data != null && snapshot.data.length>0) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {

                                          return InkWell(
                                              onTap: (){
                                                /* Navigator.push(
                                      context, MaterialPageRoute(builder: (BuildContext context) => NewsDetails(snapshot.data[index], true)));*/
                                              },
                                              child: Container(
/*
                                  margin: EdgeInsets.all(5),
*/
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,

                                                  children: [

                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.grey,
                                                                border: Border.all(color: Colors.grey),
                                                                image: DecorationImage(
                                                                  image: NetworkImage(snapshot.data[index].icon),

                                                                  fit: BoxFit.contain,
                                                                )
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                                padding: EdgeInsets.all(10),
                                                                child: Text(prefshot.data?snapshot.data[index].title:snapshot.data[index].title_ar,style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.w500
                                                                ),),
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),


                                                    Container(
                                                      height: MediaQuery.of(context).size.height*0.4,
                                                      width: double.infinity,
                                                      child: VideoWidget(
                                                        play: true,
                                                        url: snapshot.data[index].video,
                                                      ),
                                                    ),

                                                    Container(
                                                        padding: EdgeInsets.all(10),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(prefshot.data?snapshot.data[index].details:snapshot.data[index].details_ar,maxLines: 3,style: TextStyle(fontSize: 16,),),
                                                              SizedBox(height: 5,),
                                                              Text(timeAgoSinceDate(snapshot.data[index].date),style: TextStyle(color:Colors.black,fontSize: 10),),
                                                            ]
                                                        )
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),

                                                    InkWell(
                                                      onTap: ()async {
                                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TrendingDetails(snapshot.data[index], prefshot.data)));                                          print('Interstitial ad is still loading...');

                                                        /*if (await interstitialAd.isLoaded) {
                                                          interstitialAd.show();
                                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TrendingDetails(snapshot.data[index], prefshot.data)));                                        }
                                                        else {
                                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TrendingDetails(snapshot.data[index], prefshot.data)));                                          print('Interstitial ad is still loading...');
                                                        }*/
                                                      },
                                                      child: Center(
                                                        child: Container(
                                                          height: 40,
                                                          width: 300,
                                                          decoration: BoxDecoration(
                                                            borderRadius : BorderRadius.circular(12),
                                                            color: primaryColor,

                                                          ),
                                                          child: Center(child: Text("ShowDetail".tr(),style: TextStyle(
                                                            color: Colors.white,
                                                          ),)),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: 20,
                                                    ),





                                                  ],
                                                ),

                                              )                              );
                                        });
                                  }
                                  else {
                                    return new Center(
                                      child: Container(
                                          child: Text("noData".tr())
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
                    child: Text("noData".tr())
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

class VideoWidget extends StatefulWidget {

  final bool play ;
  final String url;


  const VideoWidget({Key key, @required this.url, @required this.play })
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}


class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController videoPlayerController ;
  Future<void> _initializeVideoPlayerFuture;
  ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = new VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    _chewieController =  ChewieController(

      videoPlayerController: videoPlayerController,
      aspectRatio: 2/1.6,
      // Prepare the video to be played and display the first frame
      autoInitialize: true,
      looping: false,
      autoPlay: false,
      // Errors can occur for example when trying to play a video
      // from a non-existent URL
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

  } // This closing tag was missing

  @override
  void dispose() {
    videoPlayerController.dispose();
   //_chewieController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {



    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return new Padding(
            padding: const EdgeInsets.all(0.0),
            child: Chewie(
              key: new PageStorageKey(widget.url),
              controller:  _chewieController  ,
            ),
          );
        }
        else {
          return Container(
            height: size.height*0.45,
            width: size.width*0.95,
            decoration: BoxDecoration(
              //border: Border.all(color: Colors.black),
              color: Colors.grey.shade300,
            ),
            child: Center(
              child: CircularProgressIndicator(),),
          );
        }
      },
    );
  }
}
