import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/model/slideshow.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';

enum language { arabic, english }
class AddSlideShow extends StatefulWidget {
  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<AddSlideShow> {
  bool addContainer=false;
  language _language = language.arabic;
  bool isArabic=true;
  Future<List<SlideShow>> getSlideList() async {
    List<SlideShow> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("slideshow").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          SlideShow partnerModel = new SlideShow(
            individualKey,
            DATA[individualKey]['image'],
              DATA[individualKey]['language'],
            DATA[individualKey]['date'],
          );
          print("key ${partnerModel.id}");
          list.add(partnerModel);

        }
      }
    });
    return list;
  }

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }

  File imagefile;
  void fileSet(File file){
    setState(() {
      if(file!=null){
        imagefile=file;

      }
    });
    uploadImageToFirebase(context);
  }
  Future<File> _chooseGallery() async{
    await ImagePicker().getImage(source: ImageSource.gallery).then((value) => fileSet(File(value.path)));

  }
  Future<File> _choosecamera() async{
    await ImagePicker().getImage(source: ImageSource.camera).then((value) => fileSet(File(value.path)));

  }
  String photoUrl;
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Radio(
                          value: language.arabic,
                          groupValue: _language,
                          onChanged: (language value) {
                            setState(() {
                              isArabic = true;
                              _language = value;
                            });
                          },
                        ),
                        new Text(
                          "Arabic",
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: language.english,
                          groupValue: _language,
                          onChanged: (language value) {
                            setState(() {
                              isArabic = false;
                              _language = value;
                            });
                          },
                        ),
                        new Text(
                          "English",
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _chooseGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _choosecamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }



  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = imagefile.path;
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagefile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
        photoUrl=value;
        if(isArabic){
          final databaseReference = FirebaseDatabase.instance.reference();
          databaseReference.child("slideshow").push().set({
            'image': photoUrl,
            'language':"ar",
            'date':DateTime.now().toString()
          }).then((value) {
            pr.hide();
            Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AddSlideShow()));


          }).catchError((onError){
            Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

          });
        }
        else{
          final databaseReference = FirebaseDatabase.instance.reference();
          databaseReference.child("slideshow").push().set({
            'image': photoUrl,
            'language':"en",
            'date':DateTime.now().toString()
          }).then((value) {
            pr.hide();
            Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AddSlideShow()));


          }).catchError((onError){
            Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

          });
        }

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        key: _drawerKey,
        drawer: AdminDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
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
                          child: Text("SlideShow",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                        ),


                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<SlideShow>>(
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
                                          ClipRRect(
                                            borderRadius:  BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: snapshot.data[index].image,
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: double.maxFinite,
                                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  Center(child: CircularProgressIndicator(),),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin:EdgeInsets.all(5),
                                                child: Text(snapshot.data[index].language=='ar'?"Arabic":"English",style: TextStyle(color: Colors.black),),
                                              ),
                                              Container(
                                                  margin:EdgeInsets.all(5),
                                                  child: RaisedButton(
                                                    onPressed: ()async{
                                                      final databaseReference = FirebaseDatabase.instance.reference();
                                                      await databaseReference.child("slideshow").child(snapshot.data[index].id).remove().then((value) {
                                                        Navigator.pushReplacement(
                                                            context, MaterialPageRoute(builder: (BuildContext context) => AddSlideShow()));
                                                      });
                                                    },
                                                    color: Colors.red,
                                                    child: Text("Delete",style: TextStyle(color: Colors.white),),


                                                  )
                                              ),

                                            ],
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
              Align(
                  alignment: Alignment.bottomRight,
                  child: AnimatedContainer(
                    margin: EdgeInsets.all(20),
                    height: addContainer?0:60,
                    duration: const Duration(seconds: 0),
                    curve: Curves.fastOutSlowIn,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: (){
                        setState(() {
                          addContainer=true;
                        });
                      },
                    ),
                  )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  color: Colors.white,
                  height: addContainer?220:0,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(seconds: 0),
                  curve: Curves.fastOutSlowIn,
                  child: Wrap(
                    children: <Widget>[

                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: (){
                                  setState(() {
                                    addContainer=false;
                                  });
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text("Add Image",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),)
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Radio(
                              value: language.arabic,
                              groupValue: _language,
                              onChanged: (language value) {
                                setState(() {
                                  isArabic = true;
                                  _language = value;
                                });
                              },
                            ),
                            new Text(
                              "Arabic",
                              style: new TextStyle(fontSize: 16.0),
                            ),
                            new Radio(
                              value: language.english,
                              groupValue: _language,
                              onChanged: (language value) {
                                setState(() {
                                  isArabic = false;
                                  _language = value;
                                });
                              },
                            ),
                            new Text(
                              "English",
                              style: new TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      new ListTile(
                          leading: new Icon(Icons.photo_library),
                          title: new Text('Photo Library'),
                          onTap: () {
                            _chooseGallery();
                          }),
                      new ListTile(
                        leading: new Icon(Icons.photo_camera),
                        title: new Text('Camera'),
                        onTap: () {
                          _choosecamera();
                        },
                      ),
                    ],
                  ),
                )
              )
            ],
          )
        )

    );
  }
}
