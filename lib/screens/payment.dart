import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/screens/sorry.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';
import 'package:sap_pi/utils/dialogs/success_dialog.dart';
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
  bool _isProcessing = false;
  bool _isButtonDisabled = false;

  Future<void> _handlePayPress() async {
    if (_card == null) {
      return;
    }

    setState(() {
      _isButtonDisabled = true;
    });

    final clientSecret = await createPaymentIntent(widget.amount);

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret['paymentIntent'],
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
    } on StripeException {
      if (mounted) showErrorDialog(context, 'Payment failed');
      return;
    }

    if (mounted) await showSuccessDialog(context, 'Payment succeeded!');

    setState(() {
      _isProcessing = true;
    });

    final completed = await _submitMedicines();

    setState(() {
      _isProcessing = false;
      _isButtonDisabled = false;
    });

    if (completed && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ThankYouScreen(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SorryScreen(),
        ),
        (route) => false,
      );
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

  Future<bool> _submitMedicines() async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/order-medicines'),
      body: json.encode(
        widget.orderedMedicines.map((om) => om.toJson()).toList(),
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final result = json.decode(response.body);

    if (response.statusCode == 200 && mounted) {
      await showSuccessDialog(context, 'Medicines received successfully');
      return true;
    } else {
      await showErrorDialog(context, result['detail']);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: _isProcessing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Processing Order...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    CircularProgressIndicator(),
                  ],
                ),
              )
            : Column(
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
                      const SizedBox(height: 16),
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
                      _isButtonDisabled
                          ? null
                          : _card?.complete == true
                              ? _handlePayPress()
                              : showErrorDialog(
                                  context,
                                  'Please complete the card details',
                                );
                    },
                    text: 'Pay',
                  )
                ],
              ),
      ),
    );
  }
}
