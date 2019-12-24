import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/model/file_model.dart';
import 'package:download_manager/util/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';


class DeleteDialog extends StatelessWidget {

  List<SelectedFileModel> selectedList;
  AppBarCallBacks appBarCallBacks;

  DeleteDialog(this.selectedList, this.appBarCallBacks);


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: WidgetUtils.bigButtonShape,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context).areYouSure,
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8, right: 16),
            child: Text(
              AppLocalizations.of(context).areYouSureDesc,
              style: Theme.of(context).textTheme.display3,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      icon: Icon(MaterialCommunityIcons.close, color: Colors.white,),
                      label: Text(
                        AppLocalizations.of(context).cancel,
                        style: Theme.of(context).textTheme.display4,
                      ), color: Colors.redAccent,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: FlatButton.icon(
                      onPressed: () {
                        //Navigator.pop(context, true);
                        deleteFiles(context);
                      },
                      icon: Icon(MaterialCommunityIcons.delete, color: Colors.white,),
                      label: Text(
                        AppLocalizations.of(context).delete,
                        style: Theme.of(context).textTheme.display4,
                      ), color: Theme.of(context).buttonColor,),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  deleteFiles(BuildContext context){
   Navigator.pop(context, true);
  }
}
