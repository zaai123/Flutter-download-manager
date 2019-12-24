import 'package:download_manager/abstracts/app_bar_callbacks.dart';
import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/util/widget_utils.dart';
import 'package:flutter/material.dart';

class CreateFolderDialog extends StatelessWidget {

  TextEditingController textEditingController = TextEditingController();

  AppBarCallBacks appBarCallBacks;

  CreateFolderDialog(this.appBarCallBacks);

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
              AppLocalizations.of(context).createFolderTitle,
              style: Theme.of(context).textTheme.display2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8),
            child: inputField(AppLocalizations.of(context).folderNameHint, textEditingController),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8, right: 16),
                child: SizedBox(
                  height: 40,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: Theme.of(context).textTheme.display1,
                    ),
                    shape: WidgetUtils.bigButtonShape,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8, right: 16),
                child: SizedBox(
                  height: 40,
                  child: FlatButton(
                    onPressed: () {
                      appBarCallBacks.createFolder(textEditingController.text);
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).create,
                      style: Theme.of(context).textTheme.display1,
                    ),
                    shape: WidgetUtils.bigButtonShape,
                    color: Theme.of(context).buttonColor,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget inputField(String hintText, TextEditingController controller) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: TextField(
              controller: controller,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
