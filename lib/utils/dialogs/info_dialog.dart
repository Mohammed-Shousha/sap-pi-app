import 'package:flutter/material.dart';
import 'package:sap_pi/utils/dialogs/generic_dialog.dart';

Future<void> showInfoDialog(
  BuildContext context,
  String title,
  String message,
) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: message,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
