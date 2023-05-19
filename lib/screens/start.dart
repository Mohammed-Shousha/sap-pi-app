import 'package:flutter/material.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/screens/receive_prescription.dart';
import 'package:sap_pi/screens/order_medicines.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Constants.prescription,
                    height: Constants.imageHeight,
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'Receive Prescription',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceivePrescription(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Constants.medicine,
                    height: Constants.imageHeight,
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'Order Medicines',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderMedicinesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
