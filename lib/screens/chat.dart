import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:just_audio/just_audio.dart';


// Note online status must get check




class Chat extends StatelessWidget {
  final String peerId ,name;

  Chat({Key key,  this.peerId,this.name }) : super(key: key);
  static String timeAgoSinceDate(var dateString, {bool numericDates = true}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dateString);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          children: [
            Text(
              name,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<DocumentSnapshot>(
              stream:  FirebaseFirestore.instance.collection('user status').doc(peerId).snapshots() ,
              builder: ( BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshots){

                if (!snapshots.hasData)
                  {
                    return Container();
                  }

                if (snapshots.data.exists)
                  {
                    if(snapshots.data != null ){
                      if(snapshots.data['isOnline'])
                      {


                        return Text("online",style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),);
                      }
                      else if (snapshots.data['isOnline'] == false)
                      {
                        return Text("lastSeen".tr() + " : ${timeAgoSinceDate(snapshots.data['lastSeen'])}",style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),);
                      }
                    }
                  }


                    return Container();


              },
            ),


    ],
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
        peerId: peerId,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;

  ChatScreen({Key key,  this.peerId, }) : super(key: key);

  @override
  State createState() => ChatScreenState(peerId: peerId, );
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key,  this.peerId, });

  String peerId;
  String id;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";
  SharedPreferences prefs;

  File imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  List bothUser = ["" , ""];
  int unseenMessageNo ;
  String recordFilePath;
  int i = 0;
  int tempIndex;
  String peerAvatar = "", userAvatar = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isPlayingMsg = false, isRecording = false, isSending = false;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

             /* // Sticker
              isShowSticker ? buildSticker() : Container(),*/

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      /*onWillPop: onBackPress,*/
    );
  }




  final CollectionReference userDetails =
  FirebaseFirestore.instance.collection('users');

  Future setUser() async {
    return await userDetails.doc(groupChatId).set({
      "id": FieldValue.arrayUnion(bothUser),
      "time": DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUid() {
    final User user = auth.currentUser;
    return user.uid;
    // here you write the codes to input the data into firestore
  }

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void profilePic()  {
    FirebaseDatabase.instance.reference().child("userData").child(peerId).once().then((DataSnapshot peerSnapshot) {
      setState(() {
        peerAvatar = peerSnapshot.value['profile'];
      });
    });
    FirebaseDatabase.instance.reference().child("userData").child(id).once().then((DataSnapshot userSnapshot) {
      setState(() {
        userAvatar = userSnapshot.value['profile'];
      });
    });
  }

  @override
  void initState() {
    id = getUid();
    profilePic();
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
    bothUser = [peerId,id];
    getToken();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    print ("group chat id is : $groupChatId");
    //FirebaseFirestore.instance.collection('users').doc(id).update({'chattingWith': peerId});

    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  /*void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }*/

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = audio
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });

      // it increments the unseen message
      unseenMessageIncrementer();

      // user for my chats set
      setUser();

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

     // var token;
      FirebaseDatabase.instance.reference().child("userData").child(peerId).once().then((DataSnapshot peerSnapshot){
        FirebaseDatabase.instance.reference().child("userData").child(id).once().then((DataSnapshot userSnapshot){
          sendNotification(peerSnapshot.value['token'] , userSnapshot.value['username'] );
          print("user name : ${userSnapshot.value['username']} ");
          print("token is : ${peerSnapshot.value['token'] }");

        });
      });




    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: Colors.black, textColor: Colors.red);
    }
  }

  CollectionReference users = FirebaseFirestore.instance.collection('unseen Message');

  Future unseenMessageIncrementer() async{
    users.doc(peerId).collection('unseen Message').doc(id).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        unseenMessageNo = data['unseen'] ;
      }
      else
        {
          unseenMessageNo = 0 ;
        }
    }).then((value) => {
      users.doc(peerId).collection('unseen Message').doc(id).set({
      'unseen': unseenMessageNo+1, // id of sender at that point
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"))
    });


  }

  Future unseenMessageSeen() async{
    users.doc(id).collection('unseen Message').doc(peerId).get().then((DocumentSnapshot documentSnapshot) {
      if(documentSnapshot.exists)
        {
          users.doc(id).collection('unseen Message').doc(peerId).update({
            'unseen': 0,
          });
        }
    });

  }

  sendNotification(String token, String senderName) async{
    String url='https://fcm.googleapis.com/fcm/send';
    Uri myUri = Uri.parse(url);
    await http.post(
      myUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'You Have Recived A Message From $senderName',
            'title': 'A New Message',
            "sound" : "default"
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '$token',
        },
      ),
    );

  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document != null) {
      if (document.get('idFrom') == id) {
        // Right (my message)
        return Row(
          children: <Widget>[

            document.get('type') == 0
                // Text
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          document.get('content'),
                          style: TextStyle(color: Colors.black),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateFormat('dd MMM kk:mm')
                                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                            style: TextStyle(color: Colors.black87, fontSize: 10.0, fontStyle: FontStyle.italic),
                          ),
                        ),

                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                  )
                : document.get('type') == 1
                    // Image
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              document.get("content"),
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      value: loadingProgress.expectedTotalBytes != null &&
                                              loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhoto(
                                  url: document.get('content'),
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                      )
                    // Sticker
                    : Padding(
              padding: EdgeInsets.fromLTRB(10,0,10,10),
              child: Container(
                width: 200.0,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:  Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          print("first tap");
                          _loadFile(document.get('content'));
                          tempIndex = index;
                        },
                        onTapCancel: (){
                          print("second tap");
                          RecordMp3.instance.stop();
                        },

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                isPlayingMsg && tempIndex == index  ?  Icon( Icons.cancel  ,color : Colors.black) :Icon( Icons.play_arrow  ,color : Colors.black) ,
                                Text(
                                  'Audio',
                                  maxLines: 10,style : TextStyle (
                                  color  : Colors.black,
                                )
                                ),
                              ],
                            ),
                          ],
                        )),
                    Text(
                      DateFormat('dd MMM kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                      style: TextStyle(color: Colors.black87, fontSize: 10.0, fontStyle: FontStyle.italic),
                    ),

                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                child: Image.network(userAvatar,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      value: loadingProgress.expectedTotalBytes != null &&
                          loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
                  errorBuilder: (context, object, stackTrace) {
                    return Icon(
                      Icons.account_circle,
                      size: 35,
                      color: Colors.grey,
                    );
                  },
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(18.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
            ),

          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                /*  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(peerAvatar,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  value: loadingProgress.expectedTotalBytes != null &&
                                          loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35.0),*/
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      child: Image.network(peerAvatar,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            value: loadingProgress.expectedTotalBytes != null &&
                                loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 35,
                            color: Colors.grey,
                          );
                        },
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(18.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                  document.get('type') == 0
                      ? Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.get('content'),
                                style: TextStyle(color: Colors.white),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  DateFormat('dd MMM kk:mm')
                                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                                  style: TextStyle(color: Colors.white, fontSize: 10.0, fontStyle: FontStyle.italic),
                                ),
                              ),

                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : document.get('type') == 1
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    document.get('content'),
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            value: loadingProgress.expectedTotalBytes != null &&
                                                    loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) => Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => FullPhoto(url: document.get('content'))));
                                },
                                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                            )
                          : Padding(
                    padding: EdgeInsets.fromLTRB(10,0,10,0),
                    child: Container(
                      width: 200.0,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                _loadFile(document.get('content'));
                                tempIndex = index;
                              },
                              onSecondaryTap: () {
                                //stopRecord();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      isPlayingMsg && tempIndex == index  ?  Icon( Icons.cancel  ,color : Colors.white) :Icon( Icons.play_arrow  ,color : Colors.white) ,
                                      Text(
                                        'Audio',
                                        maxLines: 10,style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),

                          Text(
                            DateFormat('dd MMM kk:mm')
                                .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                            style: TextStyle(color: Colors.white, fontSize: 10.0, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

/*              // Time
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm')
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                        style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
                      ),
                      margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container()*/
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

/*  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance.collection('users').doc(id).update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }*/


  Widget buildSticker() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1', 2),
                  child: Image.asset(
                    'images/mimi1.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', 2),
                  child: Image.asset(
                    'images/mimi2.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', 2),
                  child: Image.asset(
                    'images/mimi3.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi4', 2),
                  child: Image.asset(
                    'images/mimi4.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', 2),
                  child: Image.asset(
                    'images/mimi5.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', 2),
                  child: Image.asset(
                    'images/mimi6.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi7', 2),
                  child: Image.asset(
                    'images/mimi7.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', 2),
                  child: Image.asset(
                    'images/mimi8.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', 2),
                  child: Image.asset(
                    'images/mimi9.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
        padding: EdgeInsets.all(5.0),
        height: 180.0,
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
/*
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,6,0),
            child: GestureDetector(
              onLongPress: () {
                startRecord();
                setState(() {
                  isRecording = true;
                });
              },
              onLongPressEnd: (details) {
                stopRecord();
                setState(() {
                  isRecording = false;
                });
              },
              child: Icon(Icons.mic , color: primaryColor,),
            ),
          ),
*/
          Container(
              height: 30,
              margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: isRecording
                        ? Colors.white
                        : Colors.black12,
                    spreadRadius: 4)
              ], color: primaryColor, shape: BoxShape.circle),
              child: GestureDetector(
                onLongPress: () {
                  startRecord();
                  setState(() {
                    isRecording = true;
                  });
                },


                onLongPressEnd: (details) {
                  stopRecord();
                  setState(() {
                    isRecording = false;
                  });
                },





                child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 20,
                    )),
              )),


          // Edit text
          isRecording ? Flexible(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                padding: EdgeInsets.only(left: 30),
              child: Text("Recording ...", style: TextStyle(color: primaryColor, fontSize: 18.0),)
            ),
          ) :
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                child: TextField(
                  onSubmitted: (value) {
                    onSendMessage(textEditingController.text, 0);
                  },
                  style: TextStyle(color: primaryColor, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'typeYourMessage'.tr(),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),
          ),


          isRecording ? Container() :
          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage.addAll(snapshot.data.docs);
                  unseenMessageSeen();
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
    );
  }

  Future _loadFile(String url) async {
    final bytes = await readBytes(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        recordFilePath = file.path;
        isPlayingMsg = true;
        print(isPlayingMsg);
      });
      await play();
      setState(() {
        isPlayingMsg = false;
        print(isPlayingMsg);
      });
    }
  }



  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setUrl(recordFilePath);
      await audioPlayer.play();

    }
  }



  String token;
  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print(token);
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();

      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      setState(() {
        isSending = true;
      });
      await uploadAudio();

      setState(() {
        isPlayingMsg = false;
      });
    }
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }

  uploadAudio() {
    final Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(
        'profilepics/audio${DateTime.now().millisecondsSinceEpoch.toString()}}.jpg');

    UploadTask task = firebaseStorageRef.putFile(File(recordFilePath));
    task.then((value) async {
      print('##############done#########');
      var audioURL = await value.ref.getDownloadURL();
      String strVal = audioURL.toString();
      await onSendMessage(strVal ,2);
    }).catchError((e) {
      print(e);
    });
  }




}

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key,  this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FULL PHOTO',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(url: url),
    );
  }

}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key,  this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key,  this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }
}

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }


}

