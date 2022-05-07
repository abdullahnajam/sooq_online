import 'package:flutter/material.dart';
import 'package:propertymarket/model/item_model.dart';
import 'package:propertymarket/model/property.dart';
import 'package:propertymarket/screens/property_detail.dart';
import 'package:propertymarket/widget/property_tile.dart';

class NameSearch extends SearchDelegate<String> {
  final List<Item> names;
  String result;

  NameSearch(this.names);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = names.where((name) {
      return name.name.contains(query);
    });

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(suggestions.elementAt(index), false)));
          },
          child: PropertyTile(suggestions.elementAt(index), false),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = names.where((name) {return name.name.contains(query);});

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => PropertyDetail(suggestions.elementAt(index), false)));
          },
          child: PropertyTile(suggestions.elementAt(index), false),
        );
      },
    );
  }
}