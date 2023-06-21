import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sap_pi/screens/home.dart';

import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_button.dart';

import 'package:sap_pi/utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            const Text(
              'Welcome to SAP',
              style: TextStyle(
                fontSize: Constants.largeFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Start',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
