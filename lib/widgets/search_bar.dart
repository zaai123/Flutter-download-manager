import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchBar extends StatefulWidget {

  AppBarCallBacks appBarCallBacks;

  SearchBar(this.appBarCallBacks);

  @override
  _SearchBarState createState() => _SearchBarState(this.appBarCallBacks);
}

class _SearchBarState extends State<SearchBar> {


  TextEditingController searchController = TextEditingController();

  AppBarCallBacks appBarCallBacks;

  _SearchBarState(this.appBarCallBacks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).secondaryHeaderColor),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: attemptSearch,
                  style: Theme.of(context).textTheme.title,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(0)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SizedBox(
                height: 45,
                child: FlatButton.icon(
                  onPressed: () => appBarCallBacks.closeSearch(),
                  icon: Icon(MaterialCommunityIcons.close, size: 20, color: Colors.white,),
                  label: Text('Close', style: Theme.of(context).textTheme.display1,),
                  color: Theme.of(context).buttonColor,
                )),
          )
        ],
      ),
    );
  }

  void attemptSearch(String value) {
    appBarCallBacks.search(searchController.text);
  }
}
