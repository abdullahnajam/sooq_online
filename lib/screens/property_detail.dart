import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/auth/login.dart';
import 'package:propertymarket/model/attribute_model.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/screens/ImagePreview.dart';
import 'package:propertymarket/screens/chat.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

int indexImage = 0 ;

class PropertyDetail extends StatefulWidget {
  Item _property;
  bool lang;

  PropertyDetail(this._property,this.lang);

  @override
  _PropertyDetailState createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUid() {
    final User user = auth.currentUser;
    if(user.uid == null )
      {
        return "";
      }
    else
      {
        return user.uid;

      }
    // here you write the codes to input the data into firestore
  }

  IconData _iconData=Icons.favorite_border;
  Color _color=Colors.black54;
  bool isFavourite = false;
  List<Widget> slideShowWidget=[];

  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  bool isAdmobLoadedForBanner=true;
  bool isAdmobLoadedForInterstitial=true;
  String userAvatar = "" ,userName = "";

  void profilePic()  {
    FirebaseDatabase.instance.reference().child("userData").child(widget._property.addPublisherId).once().then((DataSnapshot peerSnapshot) {
      setState(() {
        userAvatar = peerSnapshot.value['profile'];
      });
    });
  }

  void getuserName(){
    FirebaseDatabase.instance.reference().child("userData").child(widget._property.addPublisherId).once().then((DataSnapshot peerSnapshot) {
      setState(() {
        userName = peerSnapshot.value['username'];
      });
    });
  }

  List<AttributeModel> attributes=[];
  List<TableRow> rows=[];
  bool attributeLoaded=false;

  SharedPref sharedPref=new SharedPref();
  Future getAttributes(bool language) async {
    attributes=[];
    setState(() {
      attributeLoaded=false;
    });
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").child(widget._property.id).child("attributes").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          AttributeModel model = new AttributeModel(
            //String id,attribute_id,name,name_ar,value_id,value_name,value_name_ar;
            individualKey,
            DATA[individualKey]['attribute_id'],
            DATA[individualKey]['name'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['value_id'],
            DATA[individualKey]['value_name'],
            DATA[individualKey]['value_name_ar'],
          );

          attributes.add(model);


        }
      }
    });
    setState(() {
      for(int i=0;i<attributes.length;i++){
        rows.add(TableRow(
            children: [
              Container(
                child: Text(language?attributes[i].name:attributes[i].name_ar,textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 5),
              ),
              Container(
                child: Text(language?attributes[i].value_name:attributes[i].value_name_ar,textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 5),
              ),
            ]
        ));
      }
      attributeLoaded=true;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profilePic();
    getuserName();
    sharedPref.getPref().then((value) => getAttributes(value));
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
    interstitialAd.isLoaded.then((value) => interstitialAd.show());


    checkFavouriteFromDatabase();
    for(int i=0;i<widget._property.image.length;i++){
      slideShowWidget.add(_slider(widget._property.image[i]));
    }

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


  checkFavouriteFromDatabase()async{
    User user=FirebaseAuth.instance.currentUser;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("favourites").child(user.uid).child(widget._property.id).once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        setState(() {
          _iconData=Icons.favorite;
          _color=Colors.red;
          isFavourite=true;
        });
      }
    });
  }
  checkFavourite() async{
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    if(isFavourite){
      User user=FirebaseAuth.instance.currentUser;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child("favourites").child(user.uid).child(widget._property.id).remove().then((value) {
        setState(() {
          _iconData=Icons.favorite_border;
          _color=Colors.black54;
          isFavourite=false;
          pr.hide();
        });
      })
          .catchError((error, stackTrace) {
        print("inner: $error");
        pr.hide();

      });
    }
    else{
      User user=FirebaseAuth.instance.currentUser;
      final databaseReference = FirebaseDatabase.instance.reference();
      databaseReference.child("favourites").child(user.uid).child(widget._property.id).set({
        /*'addPublisherId' : widget._property.addPublisherId,
        'status' : widget._property.status,
        'name': widget._property.name,
        'numericalPrice': widget._property.numericalPrice,
        'beds': widget._property.beds,
        'bath': widget._property.bath,
        'call': widget._property.whatsapp,
        'city': widget._property.city,
        'country': widget._property.country,
        'datePosted': widget._property.datePosted,
        'description': widget._property.description,
        'email': widget._property.email,
        'image': widget._property.image,
        'location':widget._property.location,
        'measurementArea': widget._property.measurementArea,
        'area': widget._property.area,
        'typeOfProperty': widget._property.typeOfProperty,
        'propertyCategory': widget._property.propertyCategory,
        'whatsapp': widget._property.whatsapp,
        'payment': widget._property.payment,
        'furnish': widget._property.furnish,
        'agentName': widget._property.agentName,
        'sponsered': widget._property.sponsered,
        'floor': widget._property.floor,
        'serial': widget._property.serial,
        'description_ar': widget._property.description_ar,
        'name_ar': widget._property.name_ar,
        'agentName_ar': widget._property.agentName_ar,
        'payment_ar': widget._property.payment_ar,
        'furnish_ar': widget._property.furnish_ar,
        'city_ar': widget._property.city_ar,
        'country_ar': widget._property.country_ar,
        'area_ar': widget._property.area_ar,
        'price_ar' : widget._property.price_ar,
        'price_en' : widget._property.price_en,
        'coverImage' : widget._property.coverImage,
*/

      }).then((value) {
        setState(() {
          _iconData=Icons.favorite;
          _color=Colors.red;
          isFavourite=true;
        });
        pr.hide();
      })
          .catchError((error, stackTrace) {
        print("inner: $error");
        pr.hide();

      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            child: ListView(
              children: [
                Container(
                  height: 250,

                  child : InkWell(
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) {
                            return ImagePreview(widget._property.image,indexImage);
                          }));
                    },
                    child:  Stack(
                      children: [
                        Container(
                          child: ImageSlideshow(
                            /// Width of the [ImageSlideshow].
                            width: double.infinity,
                            height: double.infinity,


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
                            onPageChanged: (value) {
                              setState(() {
                                indexImage = value;
                              });
                              print('Page changed: $value');
                            },

                            /// Auto scroll interval.
                            /// Do not auto scroll with null or 0.
                            autoPlayInterval: 1000000,
                          ),
                        ),
                        Positioned(
                          right : 10 ,
                          bottom: 10,
                          child: Container(
                              height: 60,
                              width: 100,
                              child:Image.asset("assets/images/watermark.jpeg")),
                        ),
                      ],
                    )


                  ),

                ),


                Container(
                  alignment: Alignment.center,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text(widget.lang?widget._property.name:widget._property.name_ar,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),)),
                  ),
                ),
                Container(color: Colors.grey[300],height: 3,),
                SizedBox(height: 10,),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/bed.png",width: 20,height: 20,),
                        SizedBox(width: 5,),
                        Text(widget._property.beds),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/bath.png",width: 20,height: 20,),
                        SizedBox(width: 5,),
                        Text(widget._property.bath),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/square.png",width: 20,height: 20,),
                        SizedBox(width: 5,),
                        Text("${widget._property.measurementArea} m"),
                      ],
                    ),


                  ],
                ),*/
                SizedBox(height: 10,),
                Container(color: Colors.grey[300],height: 3,),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('details'.tr(),style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      //type
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.house_outlined,color: Colors.blue,),
                                  SizedBox(width: 10,),
                                  Text('category'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget.lang?widget._property.category:widget._property.categoryAr,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //purpose
                      /*Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline,color : Colors.greenAccent),
                                  SizedBox(width: 10,),
                                  Text('purpose'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget.lang?widget._property.propertyCategory:widget._property.propertyCategoryAr,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),
*/
                      //price
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.monetization_on_outlined,color: Colors.green,),
                                  SizedBox(width: 10,),
                                  Text('price'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget.lang?widget._property.price_en:widget._property.price_ar.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //payment type
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.money,color : Colors.green.shade900),
                                  SizedBox(width: 10,),
                                  Text('payment'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget.lang?widget._property.payment:widget._property.payment_ar,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //area
                      /*Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.square_foot_outlined,color: Colors.orange,),
                                  SizedBox(width: 10,),
                                  Text('area'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget._property.measurementArea,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      // bedroom
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.king_bed_outlined,color :Colors.brown),
                                  SizedBox(width: 10,),
                                  Text('bedroom'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget._property.beds,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //bathroom
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.bathtub_outlined,color :Colors.orangeAccent),
                                  SizedBox(width: 10,),
                                  Text('bathroom'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget._property.bath,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //floor
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.square_foot_outlined),
                                  SizedBox(width: 10,),
                                  Text('floor'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget._property.floor.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),

                      //furnishing
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.all_out,color : Colors.red),
                                  SizedBox(width: 10,),
                                  Text('furnish'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget.lang?widget._property.furnish:widget._property.furnish_ar,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
                        ),
                      ),*/

                      //serial
                      Container(
                        padding:EdgeInsets.only(top: 3,bottom: 3) ,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.vpn_key_outlined,color: Colors.blueAccent,),
                                  SizedBox(width: 10,),
                                  Text('serial'.tr(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(widget._property.serial.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                            ),

                          ],
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
                      ),
                    ],
                  ),
                ),

                Table(
                  columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.7)},
                  border: TableBorder.all(width: 0.5,color: Colors.grey),
                  children: rows,
                ),

                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('location'.tr(),style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(widget.lang?widget._property.location:"${widget._property.area_ar}, ${widget._property.city_ar}, ${widget._property.country_ar}",style: TextStyle(color: Colors.black,fontSize: 15),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('description'.tr(),style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(widget.lang?widget._property.description:widget._property.description_ar,style: TextStyle(color: Colors.black,fontSize: 15),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('agent'.tr(),style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(widget.lang?widget._property.agentName:widget._property.agentName_ar,style: TextStyle(color: Colors.black,fontSize: 15),),
                ),
                AdmobBanner(
                  adUnitId: Platform.isAndroid ? androidAdmobBanner : iosAdmobBanner,
                  adSize: bannerSize,
                  listener: (AdmobAdEvent event,
                      Map<String, dynamic> args) {
                    handleEvent(event, args, 'Banner');
                  }, onBannerCreated: (AdmobBannerController controller) {
                },
                ),

                SizedBox(height: 80,),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            child:  Container(
              width: MediaQuery.of(context).size.width*1,
            color: Colors.white,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12,0,0,5),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12,0,0,5),
                      child: Material(
                        child: Image.network(userAvatar,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              value: loadingProgress.expectedTotalBytes != null &&
                                  loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                          errorBuilder: (context, object, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 35,
                              color: Colors.grey,
                            );
                          },
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(userName),
                    ),
                  ],),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap:()=>launch("tel://${widget._property.whatsapp}"),
                      child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_outlined,color: Colors.white,),
                              SizedBox(width: 5,),
                              Text('call'.tr(),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Colors.white),),
                            ],
                          )
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        final Uri _emailLaunchUri = Uri(
                            scheme: 'mailto',
                            host: widget._property.email,
                            path: widget._property.email,
                            queryParameters: {
                              'subject': 'Hi there, I am looking to list a property'
                            }
                        );
                        launch(_emailLaunchUri.toString());
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined,color: Colors.white,),
                              SizedBox(width: 5,),
                              Text('email'.tr(),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Colors.white),),
                            ],
                          )
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        User user=FirebaseAuth.instance.currentUser;
                        if(user == null)
                          {
                            Navigator.push(context, new MaterialPageRoute(
                                builder: (context) => Login()));
                          }
                        else
                          {
                            if(getUid() != widget._property.addPublisherId)
                            {
                              FirebaseDatabase.instance.reference().child("userData").child(widget._property.addPublisherId).once().then((DataSnapshot peerSnapshot){
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(builder: (context) =>Chat(peerId: widget._property.addPublisherId, name: peerSnapshot.value['username'])));
                              }
                                //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Chat(peerId: widget._property.addPublisherId,name: widget._property.agentName,)));
                              );}
                            else
                            {
                              Toast.show("Cant Chat With Yourself", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP,textColor: Colors.white , backgroundColor: primaryColor);
                              print("cant chat with your self");
                            }
                          }

                        },
                      child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.message,color: Colors.white,),
                              SizedBox(width: 5,),
                              Text('message'.tr(),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Colors.white),),
                            ],
                          )
                      ),
                    ),

                  ],
                ),
              ],
            ),


          ),),
        /*  Align(
            alignment: Alignment.bottomCenter,
            child:
          ),*/
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Container(
                height: 50,
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: _color,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(_iconData),
                      color: _color,
                      onPressed: checkFavourite,
                    ),


                  ],
                ),
              ),
            )
          )
        ],
      ),

   /*   floatingActionButton: Builder(
        builder: (context) =>Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 50),
        child: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.message),
          onPressed: (){

          },
        ),
      ),),*/
    );
  }

  Widget _slider(String image) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover
          ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
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
                      image : NetworkImage(
                        imageUrl,
                      ),
                      fit: BoxFit.contain,

                    )
                ),
              )
          ),
        ),
        onTap: () {
          indexImage = 0 ;
          Navigator.pop(context);
        },
      ),
    );
  }
}
