import 'package:firebase_database/firebase_database.dart';
import 'package:propertymarket/model/category_model.dart';
import 'package:propertymarket/model/location.dart';

Future<List<LocationModel>> getCountryList() async {
  List<LocationModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("country").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        LocationModel locationModel = new LocationModel(
          individualKey,
          DATA[individualKey]['name'],
          DATA[individualKey]['name_ar'],
          DATA[individualKey]['time'],
        );
        list.add(locationModel);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}
Future<List<LocationModel>> getCityList(selectedCountryId) async {
  List<LocationModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("country").child(selectedCountryId).child("city").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        LocationModel locationModel = new LocationModel(
          individualKey,
          DATA[individualKey]['name'],
          DATA[individualKey]['name_ar'],
          DATA[individualKey]['time'],
        );
        list.add(locationModel);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}
Future<List<LocationModel>> getAreaList(selectedCountryId,selectedCityId) async {
  List<LocationModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("country").child(selectedCountryId).child("city").child(selectedCityId).child("area").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        LocationModel locationModel = new LocationModel(
          individualKey,
          DATA[individualKey]['name'],
          DATA[individualKey]['name_ar'],
          DATA[individualKey]['time'],
        );
        list.add(locationModel);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}
Future<List<CategoryModel>> getCategoryList() async {
  List<CategoryModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("categories").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        CategoryModel model = new CategoryModel(
          individualKey,

          DATA[individualKey]['name_ar'],
          DATA[individualKey]['name'],
          DATA[individualKey]['image'],
          DATA[individualKey]['time'],
        );
        list.add(model);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}
Future<List<LocationModel>> getValueList(attributeId,selectedCategoryId,selectedSubCategoryId) async {
  List<LocationModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("categories").child(selectedCategoryId).child("sub_categories").child(selectedSubCategoryId)
      .child("attribute").child(attributeId).child("values").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        LocationModel model = new LocationModel(
          individualKey,
          DATA[individualKey]['name'],
          DATA[individualKey]['name_ar'],
          DATA[individualKey]['time'],
        );
        list.add(model);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}
Future<List<LocationModel>> getTypeList() async {
  List<LocationModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("type").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        LocationModel locationModel = new LocationModel(
          individualKey,
          DATA[individualKey]['name'],
          DATA[individualKey]['name_ar'],
          DATA[individualKey]['time'],
        );
        list.add(locationModel);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}

Future<List<CategoryModel>> getSubCategoryList(selectedCategoryId) async {
  List<CategoryModel> list=new List();
  final databaseReference = FirebaseDatabase.instance.reference();
  await databaseReference.child("categories").child(selectedCategoryId).child("sub_categories").once().then((DataSnapshot dataSnapshot){
    if(dataSnapshot.value!=null){
      var KEYS= dataSnapshot.value.keys;
      var DATA=dataSnapshot.value;

      for(var individualKey in KEYS) {
        CategoryModel model = new CategoryModel(
          individualKey,

          DATA[individualKey]['name_ar'],
          DATA[individualKey]['name'],
          DATA[individualKey]['image'],
          DATA[individualKey]['time'],
        );
        list.add(model);

      }
    }
  });
  list.sort((a, b) {
    return a.time.compareTo(b.time);
  });
  return list;
}