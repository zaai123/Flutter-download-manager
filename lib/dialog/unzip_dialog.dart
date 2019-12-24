import 'package:download_manager/locale/locales.dart';
import 'package:download_manager/util/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class UnZipDialog extends StatelessWidget {
  String name;

  UnZipDialog(this.name);

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
              AppLocalizations.of(context).extractHere,
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 8),
            child: Text(
              'You want to extract $name here.',
              style: Theme.of(context).textTheme.display3,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      icon: Icon(
                        MaterialCommunityIcons.close,
                        color: Colors.white,
                      ),
                      label: Text(
                        AppLocalizations.of(context).cancel,
                        style: Theme.of(context).textTheme.display4,
                      ),
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: FlatButton.icon(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      icon: Icon(
                        MaterialCommunityIcons.zip_box,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Extract',
                        style: Theme.of(context).textTheme.display4,
                      ),
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
