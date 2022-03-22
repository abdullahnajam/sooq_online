import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/admin/admin_search_list.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/model/property.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';

import 'admin_home.dart';
class AdminPropertyDetail extends StatefulWidget {
  Item _property;

  AdminPropertyDetail(this._property);

  @override
  _AdminPropertyDetailState createState() => _AdminPropertyDetailState();
}

class _AdminPropertyDetailState extends State<AdminPropertyDetail> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
        drawer: AdminDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: double.maxFinite,
                child: ListView(
                  children: [
                    SizedBox(height: 25,),
                    Stack(
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
                          child: Text("Property Detail",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                        ),
                      ],
                    ),
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: DecorationImage(
                            image: NetworkImage(widget._property.image[0]),
                            fit: BoxFit.cover
                        ),

                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      color: Colors.grey[200],
                      child: Text(widget._property.name,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
                    ),
                    Container(color: Colors.grey[300],height: 3,),

                    SizedBox(height: 10,),
                    Container(color: Colors.grey[300],height: 3,),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text("Details",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [

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
                                      Icon(Icons.monetization_on_outlined),
                                      SizedBox(width: 10,),
                                      Text("Price",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(widget._property.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                                ),

                              ],
                            ),
                          ),

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
                                      Icon(Icons.category_outlined),
                                      SizedBox(width: 10,),
                                      Text("Category",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(widget._property.category,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                                ),

                              ],
                            ),
                          ),
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
                                      Icon(Icons.category_outlined),
                                      SizedBox(width: 10,),
                                      Text("Sub Category",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(widget._property.subcategory,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text("Location",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text(widget._property.location,style: TextStyle(color: Colors.grey,fontSize: 15),),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text("Description",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text(widget._property.description,style: TextStyle(color: Colors.grey,fontSize: 15),),
                    ),
                    SizedBox(height: 50,),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.redAccent,
                  ),

                  padding: EdgeInsets.only(top: 10,bottom: 10),
                  child: InkWell(
                    onTap: ()async{
                      final databaseReference = FirebaseDatabase.instance.reference();
                      await databaseReference.child("property").child(widget._property.id).remove().then((value) {
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (BuildContext context) => AdminSearchList()));
                      });
                    },
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline,color: Colors.white),
                          Text("Delete",style: TextStyle(color: Colors.white),)
                        ],
                      )
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
