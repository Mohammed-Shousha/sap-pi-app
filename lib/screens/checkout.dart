import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sap_pi/providers/medicines_provider.dart';

import 'package:sap_pi/screens/payment.dart';
import 'package:sap_pi/utils/constants.dart';

import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_card.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context);

    final orderedMedicines = medicinesProvider.orderedMedicines;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: orderedMedicines.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: orderedMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = orderedMedicines[index];
                      return CustomCard(medicine: medicine);
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total: ${medicinesProvider.orderTotal}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Constants.largeFontSize,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: "Proceed to Payment",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            )
          : const Center(
              child: Center(
                child: Text("No medicines ordered"),
              ),
            ),
    );
  }
}
