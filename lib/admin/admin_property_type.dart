import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/model/property_type.dart';
import 'package:propertymarket/model/slideshow.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
class ViewPropertyType extends StatefulWidget {
  @override
  _ViewPropertyTypeState createState() => _ViewPropertyTypeState();
}

class _ViewPropertyTypeState extends State<ViewPropertyType> {
  submitData(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("type").push().set({
      'name': _controller.text,
      'name_ar': _arcontroller.text,


    }).then((value) {
      Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ViewPropertyType()));


    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }
  Future<List<PropertyType>> getSlideList() async {
    List<PropertyType> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("type").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          PropertyType partnerModel = new PropertyType(
            individualKey,
            DATA[individualKey]['name'],
            DATA[individualKey]['name_ar'],
          );
          print("key ${partnerModel.id}");
          list.add(partnerModel);

        }
      }
    });
    return list;
  }
  final _controller=TextEditingController();
  final _arcontroller=TextEditingController();
  Future<void> _addTypeDailog() async {
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
            height: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text("Add Property Type",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText:"Enter Types",contentPadding: EdgeInsets.only(left: 10)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _arcontroller,
                    decoration: InputDecoration(hintText:"Enter Types (arabic)",contentPadding: EdgeInsets.only(left: 10)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: RaisedButton(
                    color: primaryColor,
                    onPressed: (){
                      if(_controller.text!=""){
                        submitData();
                      }
                      else{
                        Toast.show("Enter Value", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      }
                    },
                    child: Text("Add Property Type",style: TextStyle(color: Colors.white),),
                  )
                ),
                SizedBox(height: 15,),
              ],
            ),
          ),
        );
      },
    );
  }

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        key: _drawerKey,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            _addTypeDailog();
          },
        ),
        drawer: AdminDrawer(),
        body: SafeArea(
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
                      child: Text("Property Type",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                    ),


                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<PropertyType>>(
                  future: getSlideList(),
                  builder: (context,snapshot){
                    if (snapshot.hasData) {
                      if (snapshot.data != null && snapshot.data.length>0) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(

                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        child: Text(snapshot.data[index].name,style: TextStyle(color: Colors.black,fontSize: 22),),
                                      ),
                                      Container(
                                        margin:EdgeInsets.all(5),
                                        child: RaisedButton(
                                          onPressed: ()async{
                                            final databaseReference = FirebaseDatabase.instance.reference();
                                            await databaseReference.child("type").child(snapshot.data[index].id).remove().then((value) {
                                              Navigator.pushReplacement(
                                                  context, MaterialPageRoute(builder: (BuildContext context) => ViewPropertyType()));
                                            });
                                          },
                                          color: Colors.red,
                                          child: Text("Delete",style: TextStyle(color: Colors.white),),


                                        )
                                      )
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
              )

            ],
          ),
        )

    );
  }
}
