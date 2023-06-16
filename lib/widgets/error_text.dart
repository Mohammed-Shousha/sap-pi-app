import 'package:flutter/material.dart';
import 'package:sap_pi/utils/constants.dart';

class ErrorText extends StatelessWidget {
  final String text;

  const ErrorText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: Constants.mediumFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
