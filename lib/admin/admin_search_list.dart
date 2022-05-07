import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:propertymarket/admin/edit_property.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/navigator/admin_drawer.dart';
import 'package:propertymarket/screens/add_item.dart';
import 'package:propertymarket/screens/property_detail.dart';
import 'package:propertymarket/values/shared_prefs.dart';
import 'package:propertymarket/widget/property_tile.dart';
import 'package:easy_localization/easy_localization.dart';

import 'add_property.dart';

class AdminSearchList extends StatefulWidget {

  @override
  _AdminSearchListState createState() => new _AdminSearchListState();
}


class _AdminSearchListState extends State<AdminSearchList> with WidgetsBindingObserver {

  final TextEditingController _filter = new TextEditingController();
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  SharedPref sharedPref=new SharedPref();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setStatus(bool isOnline) async {
    await _firestore.collection('user status').doc(_auth.currentUser.uid).set({
      "isOnline": isOnline,
      "lastSeen" : DateTime.now().millisecondsSinceEpoch,
    });
  }

  String _searchText = "";
  List<Item> names = new List();
  List<Item> filteredNames = new List();


  _AdminSearchListState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _openDrawer () {
    _drawerKey.currentState.openDrawer();
  }


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);

    this._getNames();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus(true);
    } else {
      // offline
      setStatus(false);
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      key: _drawerKey,
      backgroundColor: Colors.grey[200],
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) => AddItem()));
        },
      ),
      //resizeToAvoidBottomPadding: false,
    );
  }
  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: TextField(
        controller: _filter,
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'search'.tr(),
          hintStyle: TextStyle(color: Colors.white)
        ),
      ),
      leading: new IconButton(
        onPressed: _openDrawer,
          icon:Icon(Icons.menu),
          color: Colors.white,

      ),
    );
  }


  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List<Item> tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i].serial.toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }

    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          onTap: () => Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: EditProperty(filteredNames[index]))),
          child: Container(
            margin: EdgeInsets.only(left: 5,right: 5),
            child: PropertyTile(filteredNames[index],false),
          ),
        );
      },
    );
  }

  void _getNames() async {
    List<Item> tempList = new List();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child("item").once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        var KEYS= dataSnapshot.value.keys;
        var DATA=dataSnapshot.value;

        for(var individualKey in KEYS) {
          Item property = new Item(
            individualKey,
            DATA[individualKey]['addPublisherId'],
            DATA[individualKey]['status'],
            DATA[individualKey]['name'].toString(),
            DATA[individualKey]['location'],
            DATA[individualKey]['country'],
            DATA[individualKey]['city'],
            DATA[individualKey]['area'],
            DATA[individualKey]['category'],
            DATA[individualKey]['subcategory'],
            DATA[individualKey]['whatsapp'].toString(),
            DATA[individualKey]['call'].toString(),
            DATA[individualKey]['email'],
            DATA[individualKey]['datePosted'],
            DATA[individualKey]['description'],
            DATA[individualKey]['payment'],
            DATA[individualKey]['agentName'],
            DATA[individualKey]['serial'],
            DATA[individualKey]['description_ar'],
            DATA[individualKey]['agentName_ar'],
            DATA[individualKey]['city_ar'],
            DATA[individualKey]['country_ar'],
            DATA[individualKey]['area_ar'],
            DATA[individualKey]['categoryAr'],
            DATA[individualKey]['subcategoryAr'],
            DATA[individualKey]['coverImage'],
            DATA[individualKey]['price_en'],
            DATA[individualKey]['price_ar'],
            DATA[individualKey]['numericalPrice'],
            DATA[individualKey]['image'],
            DATA[individualKey]['sponsered'],
            DATA[individualKey]['best'],
          );
          setState(() {
            tempList.add(property);
          });


        }
        setState(() {
          names = tempList;
          names.sort((a, b) => DateTime.parse(a.datePosted).millisecondsSinceEpoch.compareTo(DateTime.parse(b.datePosted).millisecondsSinceEpoch));
          names=names.reversed.toList();
          filteredNames = names;
        });
      }
    });



  }


}
