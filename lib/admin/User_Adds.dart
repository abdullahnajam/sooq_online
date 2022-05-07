
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/admin_property_detail_view.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';
import 'edit_property.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
class UserAdds extends StatefulWidget {

  @override
  _UserAddsState createState() => _UserAddsState();
}

class _UserAddsState extends State<UserAdds> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUserId() {
    // getting current user id
    final User user = auth.currentUser;
    return user.uid;
  }
  var Uid;

  @override
  void initState() {

    Uid = this.getUserId();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }


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

  List<Item> names1 = new List();
  List<Item> filteredNames1 = new List();

  Future<List<Item>> getItemListApproved() async {
    List<Item> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
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
            DATA[individualKey]['agentName_ar'],
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
          if (DATA[individualKey]["addPublisherId"]  != adminId )
          {
            list.add(property);
          }
        }
      }
    });
    list = list.reversed.toList();
    return list;
  }

  Future<List<Item>> getItemListPending() async {
    List<Item> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("pending").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
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
            DATA[individualKey]['agentName_ar'],
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
          if (DATA[individualKey]["addPublisherId"]  != adminId  )
          {
            list.add(property);
          }
        }
      }
    });
    list = list.reversed.toList();
    return list;
  }

  Future<List<Item>> getItemListRejected() async {
    List<Item> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").orderByChild("status").equalTo("rejected").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
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
            DATA[individualKey]['agentName_ar'],
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
          if (DATA[individualKey]["addPublisherId"]  != adminId  )
          {
            list.add(property);
          }
        }
      }
    });
    list = list.reversed.toList();
    return list;
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Navigator.canPop(context);
      },
      child: Scaffold(
            drawer: AdminDrawer(),
            key: _drawerKey,
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text("User Adds"),
            ),
            backgroundColor: Color(0xffF5F5F5),
            body: Container(
              child: Column(
                children: [
                  DefaultTabController(
                      length: 3,
                      child:Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: primaryColor,
                              indicator : BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor,
                              ),
                              /*indicator:  UnderlineTabIndicator(
                                borderSide: BorderSide(width: 0.0,color: Colors.white),
                                insets: EdgeInsets.symmetric(horizontal:16.0)
                            ),*/

                              tabs: [
                                Tab(text: 'Approved'),
                                Tab(text: 'Pending'),
                                Tab(text: 'Rejected'),
                              ],
                            ),
                          ),



                          Container(
                            //height of TabBarView
                            height: MediaQuery.of(context).size.height*0.75,

                            child: TabBarView(children: <Widget>[

                              // approved adds
                               Container(
                                  child: FutureBuilder<List<Item>>(
                                    future: getItemListApproved(),
                                    builder: (context,snapshot){
                                      if (snapshot.hasData ) {
                                        if (snapshot.data != null && snapshot.data.length>0  ) {


                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                        context, MaterialPageRoute(builder: (BuildContext context) => AdminPropertyDetail(snapshot.data[index])));
                                                  },

                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 3,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: CachedNetworkImage(
                                                                imageUrl: snapshot.data[index].image[0],
                                                                fit: BoxFit.cover,
                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            flex: 7,
                                                            child: Container(
                                                              margin: EdgeInsets.all(5),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(timeAgoSinceDate(snapshot.data[index].datePosted),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 10,),
                                                                  Text(snapshot.data[index].name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text(context.locale.languageCode=="en"?snapshot.data[index].location:"${snapshot.data[index].area_ar}, ${snapshot.data[index].city_ar}, ${snapshot.data[index].country_ar}",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text("${'serail'.tr()} # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),

                                                                  SizedBox(height: 10,),

                                                                ],
                                                              ),
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                );
                                              });
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


                              //pending adds
                              Container(
                                  child: FutureBuilder<List<Item>>(
                                    future: getItemListPending(),
                                    builder: (context,snapshot){
                                      if (snapshot.hasData ) {
                                        if (snapshot.data != null && snapshot.data.length>0  ) {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                        context, MaterialPageRoute(builder: (BuildContext context) => EditProperty(snapshot.data[index])));
                                                  },

                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 3,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: CachedNetworkImage(
                                                                imageUrl: snapshot.data[index].image[0],
                                                                fit: BoxFit.cover,
                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            flex: 7,
                                                            child: Container(
                                                              margin: EdgeInsets.all(5),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(timeAgoSinceDate(snapshot.data[index].datePosted),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 10,),
                                                                  Text(snapshot.data[index].name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text(context.locale.languageCode=="en"?snapshot.data[index].location:"${snapshot.data[index].area_ar}, ${snapshot.data[index].city_ar}, ${snapshot.data[index].country_ar}",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                   SizedBox(height: 5,),
                                                                  Text("${'serail'.tr()} # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),


                                                                ],
                                                              ),
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                );
                                              });
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


                              //rejected adds
                               Container(
                                  child: FutureBuilder<List<Item>>(
                                    future: getItemListRejected(),
                                    builder: (context,snapshot){
                                      if (snapshot.hasData ) {
                                        if (snapshot.data != null && snapshot.data.length>0  ) {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                        context, MaterialPageRoute(builder: (BuildContext context) => AdminPropertyDetail(snapshot.data[index])));
                                                  },

                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 3,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: CachedNetworkImage(
                                                                imageUrl: snapshot.data[index].image[0],
                                                                fit: BoxFit.cover,
                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ),
                                                            )
                                                        ),
                                                        Expanded(
                                                            flex: 7,
                                                            child: Container(
                                                              margin: EdgeInsets.all(5),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(timeAgoSinceDate(snapshot.data[index].datePosted),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 10,),
                                                                  Text(snapshot.data[index].name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text(context.locale.languageCode=="en"?snapshot.data[index].location:"${snapshot.data[index].area_ar}, ${snapshot.data[index].city_ar}, ${snapshot.data[index].country_ar}",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text("${'serail'.tr()} # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),


                                                                ],
                                                              ),
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                );
                                              });
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

                            ]),
                          )
                        ],
                      )
                  ),
                ],
              ),
            )
        ),
    );
  }
}

