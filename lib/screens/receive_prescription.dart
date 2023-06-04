import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:sap_pi/models/ordered_medicine_model.dart';

import 'package:sap_pi/screens/closing.dart';

import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/custom_button.dart';

import 'package:sap_pi/utils/dialogs/confirm_dialog.dart';
import 'package:sap_pi/utils/dialogs/success_dialog.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';
import 'package:sap_pi/utils/constants.dart';

class ReceivePrescriptionScreen extends StatefulWidget {
  const ReceivePrescriptionScreen({super.key});

  @override
  State<ReceivePrescriptionScreen> createState() =>
      _ReceivePrescriptionScreenState();
}

class _ReceivePrescriptionScreenState extends State<ReceivePrescriptionScreen> {
  List<OrderedMedicine> _availableMedicines = [];
  List<OrderedMedicine> _unavailableMedicines = [];
  bool _isProcessing = false;
  bool _isButtonDisabled = false;

  Future<void> _scanPrescriptionQrCode() async {
    setState(() {
      _isButtonDisabled = true;
    });

    String prescriptionId = await FlutterBarcodeScanner.scanBarcode(
      '#3BBDB1',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (prescriptionId == '-1') {
      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

    bool prescriptionVerified = await _verifyPrescription(prescriptionId);

    if (!prescriptionVerified) {
      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

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
        final completed = await _processPrescription(prescriptionId);
        if (mounted && completed) {
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

      setState(() {
        _isProcessing = false;
        _isButtonDisabled = false;
      });
    }
  }

  Future<bool> _verifyPrescription(String prescriptionId) async {
    final response = await http
        .post(Uri.parse(Constants.verifyPrescriptionUrl(prescriptionId)));

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
      Uri.parse(Constants.processPrescription(prescriptionId)),
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

    if (response.statusCode != 200 && mounted) {
      final result = json.decode(response.body);
      await showErrorDialog(context, result['detail']);
      return false;
    } else {
      await showSuccessDialog(context, 'Medicines received successfully');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Receive Prescription'),
      ),
      body: Center(
          child: _isProcessing
              ? Column(
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
                )
              : CustomButton(
                  text: 'Scan Prescription QR Code',
                  onPressed: _scanPrescriptionQrCode,
                  isLoading: _isButtonDisabled,
                )),
    );
  }
}
