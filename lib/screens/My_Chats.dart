import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:propertymarket/model/PeerUser_Model.dart';
import 'package:propertymarket/screens/chat.dart';
import 'package:propertymarket/values/constants.dart';
import 'package:easy_localization/easy_localization.dart';

class MyChats extends StatefulWidget {
  const MyChats({Key key}) : super(key: key);

  @override
  _MyChatsState createState() => _MyChatsState();
}

class _MyChatsState extends State<MyChats> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var uId;
  List id;
  String peerId;
  String userName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
    });
    getUid();
  }

  void getUid() {
    final User user = auth.currentUser;
    uId = user.uid;
    // here you write the codes to input the data into firestore
  }

  int _limit = 20;
  final ScrollController listScrollController = ScrollController();
  bool isLoading = false;
  String messageIndex = "0" ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'myChat'.tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                  "id",
                  arrayContains: uId,
                ).orderBy('time',descending: true).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  print("user Id $uId");

                  if (snapshot.hasError) {
                    print("error ${snapshot.error}");
                    return Center(
                      child: Column(
                        children: [SelectableText("Something Went Wrong . ")],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data.size != 0) {
                    List<Offset> pointList = <Offset>[];

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                         print("user Id $uId");
                        print("yes user has data ");
                        DocumentSnapshot document =  snapshot.data?.docs[index];

                        id = List.from(document.get('id'));
                        if (id[0] == uId) {
                        peerId = id[1];
                        print("user Id  :$uId");
                        print("Peer Id : $peerId");
                        return buildItem(context, snapshot.data?.docs[index]);


                        } else
                        if (id[1] == uId) {
                        peerId = id[0];
                        print("user Id  :$uId");
                        print("Peer Id : $peerId");
                        return buildItem(context, snapshot.data?.docs[index]);


                        }
                        else
                          {
                            return null;
                          }
                      },
                      itemCount: snapshot.data?.docs.length,
                      controller: listScrollController,
                    );
                  } else if (snapshot.data.size == 0) {
                    print("user Id $uId");
                    print("user data not found");
                    return Center(
                      child: Container(
                        child: Text("noPreviousChat".tr()),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading ? const Loading() : Container(),
            )
          ],
        ),
        /*onWillPop: onBackPress,*/
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () =>
        {
          print(document.get('id')),
          print(document.id),
          id = List.from(document.get('id')),
          if (id[0] == uId) {
            peerId = id[1],
            print("user Id  :$uId"),
            print("Peer Id : $peerId"),

          } else
            if (id[1] == uId) {
              peerId = id[0],
              print("user Id  :$uId"),
              print("Peer Id : $peerId"),

            },

        FirebaseDatabase.instance.reference().child("userData").child(peerId).once().then((DataSnapshot peerSnapshot){
        Navigator.push(
        context,
        new MaterialPageRoute(
        builder: (context) =>
        Chat(peerId: peerId, name: peerSnapshot.value['username'])));
        }


        )},
        child: FutureBuilder<List<PeerUser>>(
          future: userData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null && snapshot.data.length > 0) {
                return ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return  Divider(color: Colors.black,thickness: 3,);
                    },
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {

                      return Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                        border: Border.all(color: Colors.grey),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              snapshot.data[index].profilePic),
                                          fit: BoxFit.contain,
                                        )),
                                  ),
                                ),

                                    snapshot.data[index].id == adminId ?

                                     Expanded(
                                       child: Row(
                                         children: [
                                            Text(
                                              snapshot.data[index].username,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                    

                                           Container(
                                               height: 50,
                                               width  :50,
                                               child: Image.asset('assets/images/checkIcon.jpeg')),
                                         ],
                                       ),
                                     ):
                                    Expanded(
                                      child: Text(
                                        snapshot.data[index].username,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),




                                FutureBuilder<bool>(
                                  future : dataExist( snapshot.data[index].id),
                                  builder: (context, snapshots1)
                                  {
                                    print("data snapshot");
                                    print("data  ${snapshots1.data}");
                                    print("Connnection  : ${snapshots1.connectionState}");
                                    if(snapshots1.connectionState == ConnectionState.waiting)
                                      {
                                        return CircularProgressIndicator();
                                      }


                                    if(snapshots1.data && snapshots1.connectionState == ConnectionState.done)
                                    {
                                      print("data exisit ${snapshots1.data}");
                                      if(snapshots1.data == true)
                                        {
                                          return StreamBuilder<DocumentSnapshot>(
                                            stream:  FirebaseFirestore.instance.collection('unseen Message').doc(uId).collection('unseen Message').doc(snapshot.data[index].id).snapshots() ,
                                            builder: ( BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshots){
                                              if(snapshots.data != null )
                                              {
                                                if(snapshots.data['unseen'] == 0)
                                                {
                                                  Container();
                                                }
                                                else
                                                {
                                                  if(snapshots.data['unseen'] >= 100)
                                                  {
                                                    return Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: primaryColor
                                                      ),
                                                      child: Center(child: Text("99+",style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold
                                                      ),),),
                                                    );
                                                  }
                                                  else
                                                  {
                                                    return Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: primaryColor
                                                      ),
                                                      child: Center(child: Text(snapshots.data['unseen'].toString(),style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold
                                                      ),),),
                                                    );

                                                  }
                                                }



                                              }

                                              return Container();
                                            },
                                          );
                                        }
                                      else
                                        {
                                          return Container();
                                        }

                                    }
                                    else if (snapshots1.data == null)
                                      {
                                        return CircularProgressIndicator();
                                      }
                                    else
                                      {
                                        return Container();
                                      }
                                  },
                                ),


/*
                                messageIndex == "0" ? Container() : ,
*/
                              ],
                            ),
                            Divider(
                              height: 1,
                              indent: 70,
                              color: Colors.black54,
                            )
                          ],
                        ),
                      );
                    });
              } else {
                return  Center(
                  child: Container(child: Text("noData").tr()),
                );
              }
            } else if (snapshot.hasError) {
              return Text('Error : ${snapshot.error}');
            } else {
              return new Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future indexMessage (String peer){

    CollectionReference users = FirebaseFirestore.instance.collection('unseen Message');
    users.doc(uId).collection('unseen Message').doc(peer).get().then((DocumentSnapshot documentSnapshot) {
      if(documentSnapshot.exists)
      {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        print("Message index is : ${data['unseen']}");

        if(data['unseen'] == 0)
        {
           messageIndex = "0";

        }
        else
        {
          if(data['unseen']>= 100)
          {
              messageIndex = "99+";
          }
          else
          {
             messageIndex = data['unseen'].toString();
          }
        }
      }
      else
      {
        print("No data");
         messageIndex = "0";
      }

    });
  }

  Future<bool> dataExist(String uid) async  {
    bool exsist  ;
    try {
      print("No Error");
      await FirebaseFirestore.instance.collection('unseen Message').doc(uId).collection('unseen Message').doc(uid).get().then((doc) {
        print(doc.exists);
        exsist = doc.exists;

      });
    } catch (e) {
      print("error fetching");
      exsist =  false;
    }

    return exsist;

  }


  Future<List<PeerUser>> userData() async {
    List<PeerUser> list = [];
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child("userData")
        .orderByChild('id')
        .equalTo(peerId)
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        var KEYS = dataSnapshot.value.keys;
        var DATA = dataSnapshot.value;

        for (var individualKey in KEYS) {
          PeerUser peerUser = new PeerUser(
            DATA[individualKey]["token"],
            DATA[individualKey]["username"],
            DATA[individualKey]["email"],
            DATA[individualKey]["profile"],
            DATA[individualKey]["id"],
          );

          list.add(peerUser);
        }
      }
    });
    return list;
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


