import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/model/trending_model.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:video_player/video_player.dart';

class TrendingDetails extends StatefulWidget {
  TrendingModel trending;
  bool language;

  TrendingDetails(this.trending,this.language);

  @override
  _TrendingDetailsState createState() => _TrendingDetailsState();
}

class _TrendingDetailsState extends State<TrendingDetails> {
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
                  child: Text('trending'.tr(),style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
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


          SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(
                  height: 15,
                ),
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
                              image: NetworkImage(widget.trending.icon),

                              fit: BoxFit.contain,
                            )
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.language?widget.trending.title:widget.trending.title_ar,maxLines: 1,style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500
                              ),),

                            ],
                          )
                      ),

                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  width: double.infinity,
                  child: VideoWidget(
                    play: true,
                    url: widget.trending.video,
                  ),
                ),

                Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.language?widget.trending.details:widget.trending.details_ar,style: TextStyle(fontSize: 16,),),
                        ]
                    )
                ),
                SizedBox(
                  height: 10,
                ),


              ],
            ),
          ),

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

class VideoWidget extends StatefulWidget {

  final bool play;
  final String url;

  const VideoWidget({Key key, @required this.url, @required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}


class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController videoPlayerController ;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = new VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  } // This closing tag was missing

  @override
  void dispose() {
    videoPlayerController.dispose();
    //    widget.videoPlayerController.dispose();
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
              controller: ChewieController(

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
              ),
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

