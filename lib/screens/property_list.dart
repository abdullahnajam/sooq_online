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
class PropertyList extends StatefulWidget {
  String country,city,area,category,subCategory;
  String countryAr,cityAr,areaAr,categoryAr,subCategoryAr;


  PropertyList(
      this.country,
      this.city,
      this.area,
      this.category,
      this.subCategory,
      this.countryAr,
      this.cityAr,
      this.areaAr,
      this.categoryAr,
      this.subCategoryAr);

  @override
  _PropertyListState createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
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
    getPropertyList();
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
  List<Item> sponsor=[];
  List<Item> latest=[];
  List<Item> searchList=[];
  List<Item> filterList=[];
  List<Item> originalSearchList=[];

  List<Item> searchSponsor=[];
  List<Item> searchRest=[];

  getPropertyList() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
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
          print("filter ${property.subcategory}==${widget.category}");
          if(property.sponsered){
            searchSponsor.add(property);
          }
          else{
            searchRest.add(property);
          }

          if(widget.country=="" && widget.city=="" && widget.area==""){
            print("filter1 ${property.subcategory}==${widget.subCategory}");
            if(property.subcategory==widget.subCategory){
              latest.add(property);
              if(property.sponsered){
                sponsor.add(property);
              }
              else{
                setState(() {
                  list.add(property);
                });
              }
            }
          }
          else{
            if(property.country==widget.country && property.city==widget.city && property.area==widget.area && property.subcategory==widget.subCategory){
              latest.add(property);
              if(property.sponsered){
                sponsor.add(property);
              }
              else{
                setState(() {
                  list.add(property);
                });
              }
            }
          }



        }
        searchSponsor.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
        searchSponsor=searchSponsor.reversed.toList();
        searchRest.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
        searchRest=searchRest.reversed.toList();
        searchRest = new List.from(searchSponsor)..addAll(searchRest);

        sponsor.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
        sponsor=sponsor.reversed.toList();
        list.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
        list=list.reversed.toList();
        list = new List.from(sponsor)..addAll(list);
        originalSearchList=list;
      }
    });
    setState(() {
      isLoaded=true;
    });
  }



  getFilterList(){
    if(priceToController.text=="")
      priceToController.text="0";
    if(priceFromController.text=="")
      priceFromController.text="0";
    if(areaToController.text=="")
      areaToController.text="0";
    if(areaFromController.text=="")
      areaFromController.text="0";
    double price=double.parse(priceFromController.text);
    double priceLow=double.parse(priceToController.text);
    print("pp $price");
    print("bed $bedroom priceTo ${priceToController.text} < price < priceFrom ${priceFromController.text}");
    print("areaTo ${areaToController.text} areaFrom ${areaFromController.text}");
    List<Item> temp=[];
    List<Item> temp2=[];
    List<Item> temp3=[];
    filterList=originalSearchList;
    if(!priceAll){
      print(filterList.length);
      for(int i=0;i<filterList.length;i++){
        print("index $i $priceLow numPrice ${filterList[i].numericalPrice} $price");
        if(filterList[i].numericalPrice>=priceLow && filterList[i].numericalPrice<=price){
          temp.add(filterList[i]);
        }

      }
    }
    else{
      temp=filterList;
    }
    for(int i=0;i<temp.length;i++){
    }
    /*if(!bedAll){
      for(int i=0;i<temp.length;i++){
        if(double.parse(temp[i].beds)==bedroom){
          temp2.add(temp[i]);
        }
      }
    }
    else{
      temp2=temp;
    }
    for(int i=0;i<temp2.length;i++){
     // print("Temp 2 $i : ${temp2[i].numericalPrice}, ${temp2[i].beds}, ${temp2[i].measurementArea}");
    }
    if(!areaAll){

      for(int i=0;i<temp2.length;i++){
        if((int.parse(temp2[i].measurementArea)>=double.parse(areaToController.text) && int.parse(temp2[i].measurementArea)<=double.parse(areaFromController.text))) {
          temp3.add(temp2[i]);
        }
      }
    }
    else{
      temp3=temp2;
    }*/
    for(int i=0;i<temp3.length;i++){
      //print("Temp 3 $i : ${temp3[i].numericalPrice}, ${temp3[i].beds}, ${temp3[i].measurementArea}");
    }
    setState(() {
      list=temp3;
    });
  }

  geSortByNewtPropertyList() async {
    setState(() {
      list.clear();
    });
    print(list.length);
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;


        for(var individualKey in KEYS) {
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

          if(property.country=="" && property.city=="" && property.area==""){
            if(property.subcategory==widget.subCategory){
              if(property.sponsered){
                sponsor.add(property);
              }
              else{
                setState(() {
                  list.add(property);
                });
              }
            }
          }
          else{
            if(property.country==widget.country && property.city==widget.city && property.area==widget.area && property.subcategory==widget.subCategory){
              if(property.sponsered){
                sponsor.add(property);
              }
              else{
                setState(() {
                  list.add(property);
                });
              }
            }
          }



        }
        setState(() {
          list.reversed;
          list = new List.from(sponsor)..addAll(list);
          print(list.length);
        });

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
                                      onTap: (){
                                        showSearchDialog(context);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        margin: EdgeInsets.only(top: 60,left: MediaQuery.of(context).size.width*0.1,right: MediaQuery.of(context).size.width*0.1),
                                        child: widget.country=="" && widget.city==""?
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [

                                            Padding(
                                                padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                                                child: Text("${'area'.tr()}, ${'city'.tr()}, ${'country'.tr()}",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                                              ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10,right: 10),
                                              width: 30,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[700],
                                                  borderRadius: BorderRadius.circular(5)

                                              ),
                                              child: Icon(Icons.keyboard_arrow_down_sharp,color: Colors.white,size: 15,),
                                            )
                                          ],
                                        )
                                            :
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if(context.locale.languageCode=="en")
                                              Padding(
                                              padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                                              child: Text("${widget.area}, ${widget.city}, ${widget.country}",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                                            )
                                            else
                                              Padding(
                                                padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                                                child: Text("${widget.areaAr}, ${widget.cityAr}, ${widget.countryAr}",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[600])),
                                              ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10,right: 10),
                                              width: 30,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[700],
                                                borderRadius: BorderRadius.circular(5)

                                              ),
                                              child: Icon(Icons.keyboard_arrow_down_sharp,color: Colors.white,size: 15,),
                                            )
                                          ],
                                        )
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
                            InkWell(

                              onTap: ()async{
                                if (await interstitialAd.isLoaded) {
                                  interstitialAd.show();
                                  if(snapshot.data){

                                    final result = await showSearch<String>(
                                      context: context,
                                      delegate: NameSearchEn(searchRest),
                                    );
                                  }
                                  else{
                                    final result = await showSearch<String>(
                                      context: context,
                                      delegate: NameSearch(searchRest),
                                    );
                                  }
                                }
                                else {
                                  if(snapshot.data){

                                    final result = await showSearch<String>(
                                      context: context,
                                      delegate: NameSearchEn(searchRest),
                                    );
                                  }
                                  else{
                                    final result = await showSearch<String>(
                                      context: context,
                                      delegate: NameSearch(searchRest),
                                    );
                                  }

                                  print('Interstitial ad is still loading...');
                                }


                                //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SearchProperty()));
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                height: 45,
                                margin: EdgeInsets.only(left: 10,right: 10,top: 10),
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

                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        sortOpened=false;
                                        filterOpened=true;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 10,right: 10),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: primaryColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('filter'.tr(),style: TextStyle(color: primaryColor,fontSize: 16,fontWeight: FontWeight.w500),),
                                          SizedBox(width: 5,),
                                          Image.asset("assets/images/filter.png",width: 20,height: 20,color: primaryColor,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        sortOpened=true;
                                        filterOpened=false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 10,right: 10),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: primaryColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('sort'.tr(),style: TextStyle(color: primaryColor,fontSize: 16,fontWeight: FontWeight.w500),),
                                          SizedBox(width: 5,),
                                          Image.asset("assets/images/sort.png",width: 20,height: 20,color: primaryColor,)
                                        ],
                                      ),
                                    ),
                                  )

                                ],
                              ),
                              margin: EdgeInsets.only(top: 10,right: 10,left: 10),
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
                          child: AnimatedContainer(
                            height: sortOpened?350:0,
                            width: MediaQuery.of(context).size.width,
                            duration: const Duration(seconds: 2),
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30),
                                )
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text('sortBy'.tr(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500,color: Colors.black),),
                                ),
                                Container(
                                    child: ListTile(
                                      onTap: (){
                                        setState(() {
                                          originalSearchList.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
                                          list=originalSearchList.reversed.toList();
                                          sortOpened=false;
                                        });

                                      },
                                      leading: Icon(Icons.timer,color: Colors.black,),
                                      title: Text('latest'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: Colors.black),),

                                    )
                                ),
                                Container(
                                    child: ListTile(
                                      onTap: (){
                                        setState(() {
                                          originalSearchList.sort((a, b) => a.numericalPrice.compareTo(b.numericalPrice));
                                          list=originalSearchList;
                                          sortOpened=false;
                                        });

                                      },
                                      leading: Icon(Icons.arrow_upward,color: Colors.black,),
                                      title: Text('LowToHigh'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: Colors.black),),

                                    )
                                ),
                                Container(

                                    child: ListTile(
                                      onTap: (){
                                        print("tapped");
                                        setState(() {
                                          originalSearchList.sort((a, b) => a.numericalPrice.compareTo(b.numericalPrice));
                                          list=originalSearchList.reversed.toList();
                                          sortOpened=false;
                                        });
                                      },
                                      leading: Icon(Icons.arrow_downward,color: Colors.black,),
                                      title: Text('HighToLow'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color: Colors.black),),

                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            height: filterOpened?MediaQuery.of(context).size.height*0.72:0,
                            width: MediaQuery.of(context).size.width,
                            duration: const Duration(seconds: 2),
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30),
                                )
                            ),
                            child: ListView(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Text('filter'.tr(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500,color: Colors.black),),
                                ),
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('bedroom'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black),),
                                      Row(
                                        children: [
                                          Text('all'.tr(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color: Colors.black),),
                                          Checkbox(
                                            value: bedAll,
                                            onChanged: (bool value) {
                                              setState(() {
                                                bedAll = value;
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ),

                                Slider(
                                  value: bedroom,
                                  onChanged: (newBedroom){
                                    setState(() {
                                      bedroom=newBedroom;
                                    });
                                  },
                                  min: 0,
                                  max: 6,
                                  divisions: 6,
                                  label: "$bedroom",

                                ),

                                Container(
                                    margin: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('price'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black),),
                                        Row(
                                          children: [
                                            Text('all'.tr(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color: Colors.black),),
                                            Checkbox(
                                              value: priceAll,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  priceAll = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child:TextFormField(
                                          controller: priceToController,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(15),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.5
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            hintText: "Enter Price",
                                            // If  you are using latest version of flutter then lable text and hint text shown like this
                                            // if you r using flutter less then 1.20.* then maybe this is not working properly
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Text('to'.tr(),textAlign: TextAlign.center,),
                                          )
                                      ),
                                      Expanded(
                                          flex: 4,
                                          child:TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: priceFromController,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                    width: 0.5
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(7.0),
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.5,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText: "Enter Price",
                                              // If  you are using latest version of flutter then lable text and hint text shown like this
                                              // if you r using flutter less then 1.20.* then maybe this is not working properly
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                          ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                    margin: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('area'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black),),
                                        Row(
                                          children: [
                                            Text('all'.tr(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,color: Colors.black),),
                                            Checkbox(
                                              value: areaAll,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  areaAll = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child:TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: areaToController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(15),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.5
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            hintText: "Enter Area",
                                            // If  you are using latest version of flutter then lable text and hint text shown like this
                                            // if you r using flutter less then 1.20.* then maybe this is not working properly
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Text('to'.tr(),textAlign: TextAlign.center,),
                                          )
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child:TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: areaFromController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(15),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 0.5
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            hintText: "Enter Area",
                                            // If  you are using latest version of flutter then lable text and hint text shown like this
                                            // if you r using flutter less then 1.20.* then maybe this is not working properly
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      filterOpened=false;
                                    });
                                    getFilterList();

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
                                        )
                                    ),
                                    child: Text('findProperty'.tr(),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 20),),
                                  ),
                                )

                              ],
                            ),
                          ),
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
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engCategory,engSubCategory,arCountry,arCity,arArea,arCategory,arSubCategory)));
                            }
                          }
                          else {
                            if(selectedCityId!=null && selectedCountryId!=null && _selectedAreaName!=null && selectedTypeId!=null){
                              Navigator.pop(context);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => PropertyList(engCountry,engCity,engArea,engCategory,engSubCategory,arCountry,arCity,arArea,arCategory,arSubCategory)));
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
