import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/util/util.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class SortOptionsWidget extends StatelessWidget {
  AppBarCallBacks appBarCallBacks;

  SortOptionsWidget(this.appBarCallBacks);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context).sortBy,
              style: Theme.of(context).textTheme.headline,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            height: .5,
          ),
          OptionsRadioButtons(),
          Divider(),
          BottomRadioButtons(),
          Padding(
            padding: const EdgeInsets.only(left: 36.0, right: 36, top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                onPressed: () {
                  sortList();
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context).done,
                  style: Theme.of(context).textTheme.button,
                ),
                color: Theme.of(context).buttonColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  void sortList() {
    UP_DOWN_SORT_TYPES upDownSortType = Util.getUpDownSortType();
    upDownSortType == UP_DOWN_SORT_TYPES.ASCENDING
        ? appBarCallBacks.sortAscendingList(Util.getSortType())
        : appBarCallBacks.sortDescendingList(Util.getSortType());
  }
}

class OptionsRadioButtons extends StatefulWidget {
  @override
  _OptionsRadioButtonsState createState() => _OptionsRadioButtonsState();
}

class _OptionsRadioButtonsState extends State<OptionsRadioButtons> {
  String _picked = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value){
      _picked = Util.getSortTypeName(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return RadioButtonGroup(
      orientation: GroupedButtonsOrientation.VERTICAL,
      margin: const EdgeInsets.only(left: 12.0),
      onSelected: (String selected) => setState(() {
        _picked = selected;
      }),
      onChange: (String value, int intValue) {
        Util.setSortTypePrefs(intValue);
      },
      labels: <String>[AppLocalizations.of(context).name, AppLocalizations.of(context).size,
        AppLocalizations.of(context).dateAndTime,
        AppLocalizations.of(context).type],
      picked: _picked,
      itemBuilder: (Radio rb, Text txt, int i) {
        return Row(
          children: <Widget>[
            rb,
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                txt.data,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ],
        );
      },
    );
  }
}

class BottomRadioButtons extends StatefulWidget {
  @override
  _BottomRadioButtonsState createState() => _BottomRadioButtonsState();
}

class _BottomRadioButtonsState extends State<BottomRadioButtons> {
  String _picked;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value){
      _picked = Util.getUpDownPrefsName(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: RadioButtonGroup(
        onSelected: (String selected) => setState(() {
          _picked = selected;
        }),
        picked: _picked,
        onChange: (String value, int intValue) {
          Util.setUpDownPrefs(intValue);
        },
        labels: [AppLocalizations.of(context).ascending, AppLocalizations.of(context).descending],
        itemBuilder: (Radio rb, Text text, int i) {
          return Row(
            children: <Widget>[
              rb,
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  text.data,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
