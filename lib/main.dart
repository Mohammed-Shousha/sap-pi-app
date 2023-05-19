import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sap_pi/screens/welcome.dart';
import 'package:sap_pi/utils/palette.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MaterialApp(
    title: 'SAP PI',
    theme: ThemeData(
      primarySwatch: Palette.primary,
      fontFamily: 'Montserrat',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    debugShowCheckedModeBanner: false,
    home: const WelcomeScreen(),
  ));
}
