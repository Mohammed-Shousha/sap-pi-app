import 'package:flutter/material.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_card.dart';
import 'package:sap_pi/screens/payment.dart';

class CheckoutScreen extends StatelessWidget {
  final List<OrderedMedicine> orderedMedicines;

  const CheckoutScreen({
    super.key,
    required this.orderedMedicines,
  });

  @override
  Widget build(BuildContext context) {
    final num orderTotal = orderedMedicines
        .map((medicine) => medicine.price * medicine.quantity)
        .reduce(
          (total, subtotal) => total + subtotal,
        );

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
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
                'Total: $orderTotal ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Proceed to Payment",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        amount: orderTotal,
                        orderedMedicines: orderedMedicines,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
