import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sap_pi/screens/welcome.dart';

import 'package:sap_pi/widgets/gradient_scaffold.dart';

import 'package:sap_pi/utils/constants.dart';

class ClosingScreen extends StatefulWidget {
  final bool isSuccessful;

  const ClosingScreen({
    super.key,
    required this.isSuccessful,
  });

  @override
  State<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends State<ClosingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 10),
      () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Constants.logo,
              height: Constants.imageHeight,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSuccessful
                  ? 'Thank You for choosing SAP'
                  : 'Sorry, An error occurred!',
              style: const TextStyle(
                fontSize: Constants.extraLargeFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSuccessful
                  ? 'We hope to see you again!'
                  : 'Contact us at 1234567890',
              style: const TextStyle(
                fontSize: Constants.largeFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
