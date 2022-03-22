import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/admin/view_Trending.dart';
import 'package:propertymarket/admin/view_news.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

class AddTrending extends StatefulWidget {
  @override
  _AddTrendingState createState() => _AddTrendingState();
}

class _AddTrendingState extends State<AddTrending> {
  String videoURL;
  File imagefile;


  File _video;
  final picker = ImagePicker();
  VideoPlayerController _controller;


// This funcion will helps you to pick a Video File
  _pickVideo() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);
    _video = File(pickedFile.path);
    _controller = VideoPlayerController.file(_video);
    uploadVideoToFirebase(context);
    _initializeVideoPlayerFuture = _controller.initialize().then((value) {
      setState(() {
      });
    });
  }


  final ardescriptionController=TextEditingController();
  final descriptionController=TextEditingController();
  final artitle=TextEditingController();
  final title=TextEditingController();
/*
  final blogLink=TextEditingController();
*/
  final _formKey = GlobalKey<FormState>();


  submitData(){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("trending").push().set({
      'video':videoURL,
      'date':DateTime.now().toString(),
      'details': descriptionController.text,
      'details_ar': ardescriptionController.text,
      'title': title.text,
      'title_ar' : artitle.text,
      'icon' : photoUrl,
    }).then((value) {
      Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ViewTrending()));


    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }
  Future uploadVideoToFirebase(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(_video);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
            videoURL=value;
           pr.hide();
      },
    );
  }


  File imageFiles;
  String photoUrl="";
  bool _progress = false ;


  Future uploadImageToFirebase(BuildContext context) async {
    final ProgressDialog pr = ProgressDialog(context);
    await pr.show();
    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(imagefile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) {
            setState(() {
              pr.hide();
              photoUrl=value;
            });
            print("value $value");

          },
    ).onError((error, stackTrace){
      Toast.show(error.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    });
  }
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


  Future<void> _initializeVideoPlayerFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              _video==null?

              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: GestureDetector(
                  onTap: (){
                    _pickVideo();
                  },
                  child: Image.asset("assets/images/addVideo.png"),
                ),
              ):InkWell(
                onTap: (){
                  _pickVideo();
                },
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      _controller.play();
                      return Container(
                        width: double.infinity,
                        height: 350,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      );
                    } else {
                      return Container(
                        color: Colors.blue,
                        /*child: Image.asset("assets/images/addVideo.png"),*/
                        //child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),

              Table(
                columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.7)},
                border: TableBorder.all(width: 0.5,color: Colors.grey),
                children: [
                  TableRow(
                      children: [
                        Container(
                          child: Text('Icon',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        photoUrl != "" ?  InkWell(
                          onTap: (){
                            _showPicker(context);
                          },
                          child: Container(
                            height: 120,
                            child: Image.network(photoUrl)
                          ),
                        ) : InkWell(
                          onTap: (){
                            _showPicker(context);
                          },
                          child: Container(
                              height: 120,
                              child: Image.asset("assets/images/add.png")
                          ),
                        ) ,

                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('Title',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
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
                                controller: title,
                                decoration: InputDecoration(hintText:"Enter Title",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
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
                                controller: artitle,
                                decoration: InputDecoration(hintText:"Enter Title (arabic)",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
                              ),
                            ),

                          ],
                        )


                      ]),
                  TableRow(
                      children: [
                        Container(
                          child: Text('Description',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w600),),
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
                                decoration: InputDecoration(hintText:"Enter Description",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
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
                                decoration: InputDecoration(hintText:"Enter Description (arabic)",contentPadding: EdgeInsets.only(left: 10), border: InputBorder.none,),
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
                      if(videoURL!=null && photoUrl != "")
                        submitData();

                      else if (videoURL ==null)
                        Toast.show("Please add Video", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

                      else if (photoUrl == "")
                        Toast.show("Please add Icon", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);


                    }
                    else{
                      Toast.show("Enter all the fields", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                    }


                  },
                  color: primaryColor,
                  child: Text("Add Trending",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        )
    );
  }

}
