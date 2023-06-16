import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'package:sap_pi/providers/medicines_provider.dart';

import 'package:sap_pi/screens/closing.dart';

import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';

import 'package:sap_pi/utils/dialogs/success_dialog.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';
import 'package:sap_pi/utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
  });
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  CardFieldInputDetails? _card;
  bool _isButtonDisabled = false;

  Future<void> _handlePayPress() async {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);

    if (_card == null) {
      return;
    }

    setState(() {
      _isButtonDisabled = true;
    });

    final clientSecret =
        await createPaymentIntent(medicinesProvider.orderTotal!);

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

    final completed = await _submitMedicines();

    setState(() {
      _isButtonDisabled = false;
    });

    if (completed && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ClosingScreen(
            isSuccessful: true,
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ClosingScreen(
            isSuccessful: false,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(num amount) async {
    try {
      var response = await http.post(
        Uri.parse(Constants.paymentUrl),
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
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);

    bool result = await medicinesProvider.orderMedicines();

    final errorMessage = medicinesProvider.errorMessage;

    if (result && mounted) {
      await showSuccessDialog(context, 'Medicines received successfully');
    } else {
      await showErrorDialog(context, errorMessage);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context);

    final isLoading = medicinesProvider.isLoading;

    final orderedMedicines = medicinesProvider.orderedMedicines;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Processing Order...',
                    style: TextStyle(
                      fontSize: Constants.extraLargeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : orderedMedicines.isNotEmpty
              ? Padding(
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
                              contentPadding: EdgeInsets.all(26),
                            ),
                            style: const TextStyle(
                              fontSize: Constants.mediumFontSize,
                            ),
                            onCardChanged: (card) {
                              setState(() {
                                _card = card;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Total: ${medicinesProvider.orderTotal} EGP',
                            style: const TextStyle(
                              fontSize: Constants.largeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CustomButton(
                        text: 'Pay',
                        onPressed: () {
                          _card?.complete == true
                              ? _handlePayPress()
                              : showErrorDialog(
                                  context,
                                  'Please complete the card details',
                                );
                        },
                        isLoading: _isButtonDisabled,
                      )
                    ],
                  ),
                )
              : const SizedBox(),
    );
  }
}
