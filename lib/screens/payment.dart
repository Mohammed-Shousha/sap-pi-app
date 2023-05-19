import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';
import 'package:sap_pi/utils/dialogs/info_dialog.dart';
import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/screens/thank_you.dart';

class PaymentScreen extends StatefulWidget {
  final num amount;
  final List<OrderedMedicine> orderedMedicines;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderedMedicines,
  });
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  CardFieldInputDetails? _card;

  Future<void> _handlePayPress() async {
    if (_card == null) {
      return;
    }

    final clientSecret = await createPaymentIntent(widget.amount);

    await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret['paymentIntent'],
      data: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );

    if (mounted) showInfoDialog(context, 'Payment', 'Payment succeeded!');

    await _submitMedicines();

    if (mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ThankYouScreen(),
            ),
            (route) => false);
      });
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(num amount) async {
    try {
      var response = await http.post(
        Uri.parse('${Constants.paymentUrl}/payment-sheet'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Payment Error');
    }
  }

  Future<void> _submitMedicines() async {
    await http.post(
      Uri.parse('${Constants.baseUrl}/order-medicines'),
      body: json.encode(
        widget.orderedMedicines.map((om) => om.toJson()).toList(),
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Payment Screen"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Card Details',
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  onCardChanged: (card) {
                    setState(() {
                      _card = card;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Total: ${widget.amount} EGP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            CustomButton(
              onPressed: () {
                _card?.complete == true
                    ? _handlePayPress()
                    : showErrorDialog(
                        context, 'Please complete the card details');
              },
              text: 'Pay',
            )
          ],
        ),
      ),
    );
  }
}
