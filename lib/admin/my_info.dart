import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/model/info.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  Future<MyInformation> getSlideList() async {
    MyInformation _myInfo;
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("info").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        _myInfo = new MyInformation(
          dataSnapshot.value['email'],
          dataSnapshot.value['phone'],
        );

      }
    });
    return _myInfo;
  }
  submitData(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("info").set({
      'email': _controller.text,
      'phone': _pcontroller.text,


    }).then((value) {
      Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyInfo()));


    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }
  final _controller=TextEditingController();
  final _pcontroller=TextEditingController();
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text("Contact Info",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText:"Enter email",contentPadding: EdgeInsets.only(left: 10)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _pcontroller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText:"Enter phone",contentPadding: EdgeInsets.only(left: 10)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                      color: primaryColor,
                      onPressed: (){
                        if(_controller.text!="" && _pcontroller.text!=""){
                          submitData();
                        }
                        else{
                          Toast.show("Enter Values", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        }
                      },
                      child: Text("Add Contact Info",style: TextStyle(color: Colors.white),),
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
                      child: Text("My Info",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                    ),


                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<MyInformation>(
                  future: getSlideList(),
                  builder: (context,snapshot){
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        return Column(
                          children: [
                            Container(
                              child: ListTile(
                                leading: Icon(Icons.phone),
                                title: Text(snapshot.data.phone),
                              )
                            ),
                            Divider(color: Colors.grey,),
                            Container(
                                child: ListTile(
                                  leading: Icon(Icons.email),
                                  title: Text(snapshot.data.email),
                                )
                            ),
                          ],
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
              )

            ],
          ),
        )

    );
  }
}
