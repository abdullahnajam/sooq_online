import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/admin/add_attributes.dart';
import 'package:propertymarket/admin/add_sub_category.dart';
import 'package:propertymarket/admin/view_cities.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/model/slideshow.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:toast/toast.dart';
class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  submitData(String url){
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("categories").push().set({
      'name': _controller.text,
      'name_ar': _arcontroller.text,
      'image': url,
      'time': DateTime.now().millisecondsSinceEpoch,


    }).then((value) {
      Toast.show("Submitted", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AddCategory()));


    }).catchError((onError){
      Toast.show(onError.toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

    });
  }
  Future<List<CategoryModel>> getCategoryList() async {
    List<CategoryModel> list=new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("categories").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          CategoryModel partnerModel = new CategoryModel(
            individualKey,
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['name'],
            DATA[individualKey]['image'],
            DATA[individualKey]['time '],

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
    String photoUrl="";
    File imagefile;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                height: MediaQuery.of(context).size.height*0.55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text("Category",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color:Colors.black,fontWeight: FontWeight.w600),),
                    ),
                    Expanded(
                        child:ListView(
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(hintText:"Enter Category",contentPadding: EdgeInsets.only(left: 10)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextField(
                                controller: _arcontroller,
                                decoration: InputDecoration(hintText:"Enter Category (Arabic)",contentPadding: EdgeInsets.only(left: 10)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: photoUrl != "" ?  InkWell(
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
                            ),
                            Container(
                                margin: EdgeInsets.all(10),
                                child: RaisedButton(
                                  color: primaryColor,
                                  onPressed: (){
                                    if(_controller.text!="" && photoUrl != ""){
                                      submitData(photoUrl);
                                    }
                                    else{
                                      Toast.show("Enter Value", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                                    }
                                  },
                                  child: Text("Add Category",style: TextStyle(color: Colors.white),),
                                )
                            ),

                          ],
                        )
                    ),
                    SizedBox(height: 15,),
                  ],
                ),
              ),
            );
          },
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
                      child: Text("Categories",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13),),
                    ),


                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<CategoryModel>>(
                  future: getCategoryList(),
                  builder: (context,snapshot){
                    if (snapshot.hasData) {
                      if (snapshot.data != null && snapshot.data.length>0) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  leading: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data[index].image,
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                  title: Text(snapshot.data[index].name),
                                  subtitle: Text(snapshot.data[index].name_ar),
                                  trailing: PopupMenuButton(
                                    onSelected: (result){

                                       if (result == 1) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (context) => AddSubCategory(snapshot.data[index].id)));
                                      }
                                    },
                                    icon: Icon(Icons.more_vert),
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[

                                      PopupMenuItem(
                                        value: 1,
                                        child: Text("Sub Categories"),
                                      ),
                                      PopupMenuItem(
                                        onTap: ()async{
                                          final databaseReference = FirebaseDatabase.instance.reference();
                                          await databaseReference.child("categories").child(snapshot.data[index].id).remove().then((value) {
                                            Navigator.pushReplacement(
                                                context, MaterialPageRoute(builder: (BuildContext context) => AddCategory()));
                                          });
                                        },
                                        child: Text("Delete"),
                                      ),

                                    ],
                                  ),
                                ),
                              );

                              return GestureDetector(

                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        child: Text(snapshot.data[index].name,style: TextStyle(color: Colors.black,fontSize: 22),),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              margin:EdgeInsets.all(5),
                                              child: RaisedButton(
                                                onPressed: ()async{
                                                  final databaseReference = FirebaseDatabase.instance.reference();
                                                  await databaseReference.child("categories").child(snapshot.data[index].id).remove().then((value) {
                                                    Navigator.pushReplacement(
                                                        context, MaterialPageRoute(builder: (BuildContext context) => AddCategory()));
                                                  });
                                                },
                                                color: Colors.red,
                                                child: Text("Delete",style: TextStyle(color: Colors.white),),


                                              )
                                          ),
                                          Container(
                                              margin:EdgeInsets.all(5),
                                              child: RaisedButton(
                                                onPressed: (){
                                                  Navigator.pushReplacement(
                                                      context, MaterialPageRoute(builder: (BuildContext context) => ViewCity(snapshot.data[index].id)));
                                                },
                                                color: primaryColor,
                                                child: Text("View Cities",style: TextStyle(color: Colors.white),),


                                              )
                                          )
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
        )

    );
  }
}
