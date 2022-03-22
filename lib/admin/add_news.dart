import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/admin/view_news.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
class AddNews extends StatefulWidget {
  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  String imageUrl;
  File imagefile;

  final ardescriptionController=TextEditingController();
  final descriptionController=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void fileSet(File file){
    setState(() {
      if(file!=null){
        imagefile=file;
      }
    });
    uploadImageToFirebase(context);
  }
  submitData(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("news").push().set({
      'image':imageUrl,
      'date':DateTime.now().toString(),
      'details': descriptionController.text,
      'details_ar': ardescriptionController.text,
    }).then((value) {
      Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ViewNews()));


    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }
  Future uploadImageToFirebase(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagefile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
        imageUrl=value;
        pr.hide();
      },
    );
  }
  Future<File> _chooseGallery() async{
    await ImagePicker().getImage(source: ImageSource.gallery).then((value) => fileSet(File(value.path)));

  }
  Future<File> _choosecamera() async{
    await ImagePicker().getImage(source: ImageSource.camera).then((value) => fileSet(File(value.path)));

  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              imagefile==null?

              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: GestureDetector(
                  onTap: (){
                    _showPicker(context);
                  },
                  child: Image.asset("assets/images/add.png"),
                ),
              ):InkWell(
                onTap: (){
                  _showPicker(context);
                },
                child: Image.file(imagefile,height: 200,width: 200,fit: BoxFit.cover,),
              ),

              Table(
                columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.7)},
                border: TableBorder.all(width: 0.5,color: Colors.grey),
                children: [
                  TableRow(
                      children: [
                        Container(
                          child: Text('Detail',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        Column(
                          children: [
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                controller: descriptionController,
                                decoration: InputDecoration(hintText:"Enter Detail",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),
                            Divider(color: Colors.grey[600],),
                            Container(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                controller: ardescriptionController,
                                decoration: InputDecoration(hintText:"Enter Detail (arabic)",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )


                      ]),







                ],
              ),


              Container(
                margin: EdgeInsets.all(10),
                child: RaisedButton(
                  onPressed: (){
                    if (_formKey.currentState.validate()) {
                      if(imageUrl!=null)
                        submitData();
                      else
                        Toast.show("Please add image", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }
                    else{
                      Toast.show("Enter all the fields", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }


                  },
                  color: primaryColor,
                  child: Text("Add Property",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        )
    );
  }
}
