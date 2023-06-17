import 'package:flutter/material.dart';
import 'package:sap_pi/utils/constants.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(24.0),
        contentPadding: const EdgeInsets.all(20.0),
        actionsPadding: const EdgeInsets.all(20.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: Constants.mediumFontSize,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: Constants.smallFontSize,
          ),
        ),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(
            child: Text(
              optionTitle,
              style: const TextStyle(
                fontSize: Constants.mediumFontSize,
              ),
            ),
            onPressed: () {
              if (value != null) {
                Navigator.pop(context, value);
              } else {
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      );
    },
  );
}
