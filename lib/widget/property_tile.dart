import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:propertymarket/auth/login.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/screens/chat.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
class PropertyTile extends StatefulWidget {
  Item property;
  bool lang;

  PropertyTile(this.property,this.lang);

  @override
  _PropertyTileState createState() => _PropertyTileState();
}

class _PropertyTileState extends State<PropertyTile> {


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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(left: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.property.image[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                      widget.property.sponsered?Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(Icons.star,color: Colors.yellow,),
                        ),
                      ):Container(),
                    ],
                  )
              ),
              Expanded(
                  flex: 7,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            widget.property.sponsered?Row(
                              children: [
                                SizedBox(width: 5,),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 5),
                                  child: Text("",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),textAlign: TextAlign.center,),
                                )
                              ],
                            ):Container(),
                          ],
                        ),


                        Text(widget.property.name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: Colors.black),),
                        SizedBox(height: 5,),
                        Text(timeAgoSinceDate(widget.property.datePosted),style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),
                        SizedBox(height: 5,),
                        Text(widget.property.price_en.toString(),style: TextStyle(fontSize: 22,color: primaryColor,fontWeight: FontWeight.bold),),
                        SizedBox(height: 5,),
                        Text(widget.lang?widget.property.location:"${widget.property.area_ar}, ${widget.property.city_ar}, ${widget.property.country_ar}",style: TextStyle(fontSize: 15,color: Colors.black),),
                        SizedBox(height: 5,),
                        /*Text(widget.lang?"${widget.property.payment.toString()}":"${widget.property.payment_ar.toString()}",style: TextStyle(fontSize: 15,color: Colors.black),),
                        SizedBox(height: 5,),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            /*Row(

                              children: [
                                Row(
                                  children: [
                                    Image.asset("assets/images/bed.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text(widget.property.beds),
                                    SizedBox(width: 5,),
                                    Image.asset("assets/images/bath.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text(widget.property.bath),
                                    SizedBox(width: 5,),
                                    Image.asset("assets/images/square.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text("${widget.property.measurementArea} m"),
                                  ],
                                ),
                              ],
                            ),*/
                            Text(widget.lang?"${widget.property.category}":"${widget.property.categoryAr}  ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                          ],
                        ),
                        SizedBox(height: 10,),


                      ],
                    ),
                  )
              ),
            ],
          ),

        ],
      )
    );
  }
}
