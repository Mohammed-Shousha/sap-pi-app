import 'package:flutter/material.dart';
import 'package:sap_pi/utils/dialogs/generic_dialog.dart';

Future<bool> showConfirmDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Confirm',
    content: content,
    optionsBuilder: () => {
      'Confirm': true,
      'Cancel': false,
    },
  ).then(
    (value) => value ?? false,
  );
}
