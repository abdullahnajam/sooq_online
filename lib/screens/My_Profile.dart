import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:propertymarket/model/User_Model.dart';
import 'package:propertymarket/model/property.dart';
import 'package:propertymarket/screens/property_detail.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:toast/toast.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  String token , username , email , userID ;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("myProfile".tr()),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: size.height*0.28,
              decoration: BoxDecoration(
                color: primaryColor,
                  borderRadius: BorderRadius.only(topRight: Radius.zero , topLeft: Radius.zero , bottomLeft: Radius.circular(22)  , bottomRight: Radius.circular(22) )
              ),
              child: FutureBuilder<List<UserModel>>(
                future: userData(),
                builder: (context,snapshot){
                  if (snapshot.hasData ) {
                    if (snapshot.data != null && snapshot.data.length>0  ) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            print(snapshot.data[index].profilePic);
                            return Column(
                              children: [

                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        height: 90,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey,
                                            border: Border.all(color: Colors.grey),
                                            image: DecorationImage(
                                              image: NetworkImage(snapshot.data[index].profilePic),
                                              fit: BoxFit.contain,
                                            )
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top : 80 ,
                                        left : 220,
                                        child:  InkWell(
                                          onTap : (){
                                            token = snapshot.data[index].token;
                                            username = snapshot.data[index].username;
                                            email = snapshot.data[index].email;
                                            userID = snapshot.data[index].id;
                                            _showPicker(context);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,color: Colors.white,size: 20,),
                                              Text("Edit",style: TextStyle(
                                                color: Colors.white,
                                              ),)
                                            ],
                                          ),
                                        ),
                                    )
                                  ],
                                ),

                                Divider(
                                  height: 1,
                                  endIndent: 110,
                                  indent: 110,
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                Text(snapshot.data[index].username,style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),
                                Text(snapshot.data[index].email,style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),),
                                Divider(
                                  endIndent: 110,
                                  indent: 110,
                                  thickness: 1,
                                  color: Colors.white,
                                ),


                              ],
                            );
                          });
                    }
                    else {
                      return new Center(
                        child: Container(
                            child: Text("noData".tr())
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

  Future<List<UserModel>> userData() async {
    List<UserModel> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("userData").orderByChild('id').equalTo(Uid).once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          UserModel userModel = new UserModel(
            DATA[individualKey]["token"],
            DATA[individualKey]["username"],
            DATA[individualKey]["email"],
            DATA[individualKey]["profile"],
            DATA[individualKey]["id"],

          );
            list.add(userModel);
        }
      }
    });
    return list;
  }
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

  Future<List<Property>> getPropertyListApproved() async {
    List<Property> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("property").orderByChild("status").equalTo("approved").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          Property property = new Property(
            individualKey,
            DATA[individualKey]['status'],
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['image'],
            DATA[individualKey]['name'],
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['typeOfProperty'],
            DATA[individualKey]['propertyCategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['beds'].toString(),
            DATA[individualKey]['bath'].toString(),
            DATA[individualKey]['measurementArea'].toString(),
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['furnish'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['floor'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['furnish_ar'],
            DATA[individualKey]['payment_ar'],
            DATA[individualKey]['typeOfProperty_ar'],
            DATA[individualKey]['propertyCategoryAr'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
          );
          if (DATA[individualKey]["addPublisherId"]  == Uid )
          {
            list.add(property);
          }
        }
      }
    });
    return list;
  }

  Future<List<Property>> getPropertyListPending() async {
    List<Property> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("property").orderByChild("status").equalTo("pending").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          Property property = new Property(
            individualKey,
            DATA[individualKey]['status'],
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['image'],
            DATA[individualKey]['name'],
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['typeOfProperty'],
            DATA[individualKey]['propertyCategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['beds'].toString(),
            DATA[individualKey]['bath'].toString(),
            DATA[individualKey]['measurementArea'].toString(),
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['furnish'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['floor'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['furnish_ar'],
            DATA[individualKey]['payment_ar'],
            DATA[individualKey]['typeOfProperty_ar'],
            DATA[individualKey]['propertyCategoryAr'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
          );
          if (DATA[individualKey]["addPublisherId"]  == Uid )
          {
            list.add(property);
          }
        }
      }
    });
    return list;
  }

  Future<List<Property>> getPropertyListRejected() async {
    List<Property> list=[];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("property").orderByChild("status").equalTo("rejected").once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null  ){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          Property property = new Property(
            individualKey,
            DATA[individualKey]['status'],
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['image'],
            DATA[individualKey]['name'],
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['typeOfProperty'],
            DATA[individualKey]['propertyCategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['beds'].toString(),
            DATA[individualKey]['bath'].toString(),
            DATA[individualKey]['measurementArea'].toString(),
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['furnish'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['floor'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['name_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['furnish_ar'],
            DATA[individualKey]['payment_ar'],
            DATA[individualKey]['typeOfProperty_ar'],
            DATA[individualKey]['propertyCategoryAr'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
          );
          if (DATA[individualKey]["addPublisherId"]  == Uid )
          {
            list.add(property);
          }
        }
      }
    });
    return list;
  }

  File imageFiles;
  File imagefile;
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
        photoUrl=value;
        print("value $value");
        setState(() {
          _progress = true;
          pr.hide();
          print("user id : $userID");
                final databaseReference = FirebaseDatabase.instance.reference();
                databaseReference.child("userData").child(userID).set({
                  'token':token,
                  'id' : userID,
                  'email': email,
                  'username' : username,
                  'profile': photoUrl,
                }).then((value)
                {
                  setState(() {

                  });
                });



        });

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

}


/*            Container(
              child: Column(
                children: [
                  DefaultTabController(
                      length: 3,
                      child:Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                Tab(text: 'approved'.tr()),
                                Tab(text: 'pending'.tr()),
                                Tab(text: 'rejected'.tr()),
                              ],
                            ),
                          ),



                          Container(
                            //height of TabBarView
                            height: MediaQuery.of(context).size.height*0.48,

                            child: TabBarView(children: <Widget>[

                              // approved adds
                               Container(
                                  child: FutureBuilder<List<Property>>(
                                    future: getPropertyListApproved(),
                                    builder: (context,snapshot){
                                      if (snapshot.hasData ) {
                                        if (snapshot.data != null && snapshot.data.length>0  ) {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: (){
                                                    SharedPref sp = SharedPref();
                                                  sp.getPref().then((value){
                                                    Navigator.push(
                                                        context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(snapshot.data[index],value)));
                                                  });
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
                                                                  Text(snapshot.data[index].location,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Flat for ${snapshot.data[index].propertyCategory}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Serial Number # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Image.asset("assets/images/bed.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].beds),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/bath.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].bath),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/square.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text("${snapshot.data[index].measurementArea} Sq. ft."),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
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
                                                child: Text("noData".tr())
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
                                  child: FutureBuilder<List<Property>>(
                                    future: getPropertyListPending(),
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
                                                        context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(snapshot.data[index],true)));
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
                                                                  Text(snapshot.data[index].location,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Flat for ${snapshot.data[index].propertyCategory}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Serial Number # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Image.asset("assets/images/bed.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].beds),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/bath.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].bath),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/square.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text("${snapshot.data[index].measurementArea} Sq. ft."),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
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
                                                child: Text("noData".tr())
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
                                  child: FutureBuilder<List<Property>>(
                                    future: getPropertyListRejected(),
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
                                                        context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(snapshot.data[index],true)));
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
                                                                  Text(snapshot.data[index].location,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.black),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Flat for ${snapshot.data[index].propertyCategory}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 5,),
                                                                  Text("Serial Number # ${snapshot.data[index].serial}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300),),
                                                                  SizedBox(height: 7,),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Image.asset("assets/images/bed.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].beds),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/bath.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text(snapshot.data[index].bath),
                                                                          SizedBox(width: 5,),
                                                                          Image.asset("assets/images/square.png",width: 15,height: 15,),
                                                                          SizedBox(width: 5,),
                                                                          Text("${snapshot.data[index].measurementArea} Sq. ft."),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
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
                                                child: Text("noData".tr())
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
            ),*/