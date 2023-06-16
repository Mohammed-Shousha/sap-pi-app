import 'package:flutter/material.dart';

import 'package:sap_pi/screens/receive_prescription.dart';
import 'package:sap_pi/screens/order_medicines.dart';

import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_button.dart';

import 'package:sap_pi/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          HomeOption(
            text: 'Receive Prescription',
            route: ReceivePrescriptionScreen(),
            image: Constants.prescription,
          ),
          Divider(),
          HomeOption(
            text: 'Order Medicines',
            route: OrderMedicinesScreen(),
            image: Constants.medicine,
          ),
        ],
      ),
    );
  }
}

class HomeOption extends StatelessWidget {
  final String text;
  final Widget route;
  final String image;

  const HomeOption({
    super.key,
    required this.text,
    required this.route,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: Constants.imageHeight,
            ),
            const SizedBox(height: 50),
            CustomButton(
              text: text,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => route,
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
