import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/screens/sorry.dart';
import 'package:sap_pi/screens/thank_you.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/dialogs/confirm_dialog.dart';
import 'package:sap_pi/utils/dialogs/success_dialog.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';

class ReceivePrescription extends StatefulWidget {
  const ReceivePrescription({super.key});

  @override
  State<ReceivePrescription> createState() => _ReceivePrescriptionState();
}

class _ReceivePrescriptionState extends State<ReceivePrescription> {
  List<OrderedMedicine> _availableMedicines = [];
  List<OrderedMedicine> _unavailableMedicines = [];
  bool _isProcessing = false;
  bool _isButtonDisabled = false;

  Future<void> _scanQrCode() async {
    setState(() {
      _isButtonDisabled = true;
    });

    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#3BBDB1',
      'Cancel',
      true,
      ScanMode.QR,
    );

    bool prescriptionVerified = await _verifyPrescription(barcodeScanRes);

    if (!prescriptionVerified) return;

    String availableMedicinesNames =
        _availableMedicines.map((e) => e.name).join(', ');

    String unavailableMedicinesNames =
        _unavailableMedicines.map((e) => e.name).join(', ');

    if (mounted) {
      final shouldProcess = await showConfirmDialog(
        context,
        '${_unavailableMedicines.isNotEmpty ? 'The following medicines are not available: $unavailableMedicinesNames.\n' : ''}'
        'Do you want to receive ${_availableMedicines.isNotEmpty ? 'the following medicines: $availableMedicinesNames' : 'no medicines'}'
        '${_unavailableMedicines.isNotEmpty ? ', and create a new prescription for the following medicines: $unavailableMedicinesNames?' : '?'}',
      );

      setState(() {
        _isProcessing = true;
      });

      if (shouldProcess) {
        final completed = await _processPrescription(barcodeScanRes);
        if (mounted && completed) {
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

      setState(() {
        _isProcessing = false;
        _isButtonDisabled = false;
      });
    }
  }

  Future<bool> _verifyPrescription(String prescriptionId) async {
    final response = await http.post(
      Uri.parse(
          '${Constants.baseUrl}/verify-prescription-medicines-availability/$prescriptionId'),
    );

    final result = json.decode(response.body);

    if (response.statusCode != 200 && mounted) {
      await showErrorDialog(context, result['detail']);
      return false;
    }

    setState(() {
      _availableMedicines = result['available_medicines']
          .map<OrderedMedicine>(
            (medicine) => OrderedMedicine.fromJson(medicine),
          )
          .toList();

      _unavailableMedicines = result['unavailable_medicines']
          .map<OrderedMedicine>(
            (medicine) => OrderedMedicine.fromJson(medicine),
          )
          .toList();
    });

    return true;
  }

  Future<bool> _processPrescription(String prescriptionId) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/process-prescription/$prescriptionId'),
      body: json.encode({
        "available_medicines":
            _availableMedicines.map((e) => e.toJson()).toList(),
        "unavailable_medicines":
            _unavailableMedicines.map((e) => e.toJson()).toList(),
      }),
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
        title: const Text('Receive Prescription'),
      ),
      body: Center(
        child: !_isProcessing
            ? CustomButton(
                text: 'Scan Prescription QR Code',
                onPressed: () {
                  _isButtonDisabled ? null : _scanQrCode();
                },
              )
            : Column(
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
      ),
    );
  }
}
