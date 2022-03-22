import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/add_news.dart';
import 'package:propertymarket/model/news_model.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/screens/news_details.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart';
class ViewNews extends StatefulWidget {
  @override
  _ViewNewsState createState() => _ViewNewsState();
}

class _ViewNewsState extends State<ViewNews> {
  SharedPref sharedPref=new SharedPref();

  deleteItem(String id)async{
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("news").child(id).remove().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (BuildContext context) => ViewNews()));
    });
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

    return list;
  }
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }
  bool addContainer=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: AdminDrawer(),
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNews()));
        },
      ),
      body:SafeArea(
        child: Column(
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
                  GestureDetector(
                    child: Container(
                        margin: EdgeInsets.only(left: 15),
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.menu,color: primaryColor,)
                    ),
                    onTap: ()=>_openDrawer(),
                  ),
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
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (BuildContext context) => NewsDetails(snapshot.data[index], true)));
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
                                        placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(snapshot.data[index].details,maxLines: 2,),
                                                SizedBox(height: 5,),
                                                Text(timeAgoSinceDate(snapshot.data[index].date),style: TextStyle(color:Colors.black,fontSize: 10),),
                                              ],
                                            )
                                        )
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(Icons.delete_forever_outlined),
                                        color: Colors.redAccent,
                                        onPressed: (){
                                          deleteItem(snapshot.data[index].id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

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

          ],
        ),
      ),
    );
  }
}
