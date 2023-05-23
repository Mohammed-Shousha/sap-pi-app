import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sap_pi/screens/welcome.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';

class SorryScreen extends StatefulWidget {
  const SorryScreen({super.key});

  @override
  State<SorryScreen> createState() => _SorryScreenState();
}

class _SorryScreenState extends State<SorryScreen> {
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
            const Text(
              'Sorry, there was an error getting medicines',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact us at 1234567890',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
