import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/model/news_model.dart';
import 'package:propertymarket/values/constants.dart';

class NewsDetails extends StatefulWidget {
  NewsModel news;
  bool language;

  NewsDetails(this.news,this.language);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;
  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;
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
    print("this is the banner size for new details ${bannerSize.height} ${bannerSize.width}");
  }
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
      body: ListView(
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
                  child: Text('newsDetail'.tr(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
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

          Container(
            height: 200,
            child: CachedNetworkImage(
              imageUrl: widget.news.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),

          ),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.all(10),
            child: Text(widget.language?widget.news.details:widget.news.details_ar,),
          ),
          SizedBox(height: 10,),


          AdmobBanner(
            adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
            adSize: bannerSize,
            listener: (AdmobAdEvent event,
                Map<String, dynamic> args) {
              print("admob");
              handleEvent(event, args, 'Banner');
            }, onBannerCreated: (AdmobBannerController controller) {
          },
          )

        ],
      ),
    );
  }
}
