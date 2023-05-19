import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/dialogs/confirm_dialog.dart';
import 'package:sap_pi/utils/dialogs/info_dialog.dart';
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

  Future<void> _scanQrCode() async {
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

      if (shouldProcess) {
        await _processPrescription(barcodeScanRes);
      }
    }
  }

  Future<bool> _verifyPrescription(String prescriptionId) async {
    final response = await http.post(
      Uri.parse(
          '${Constants.baseUrl}/verify-prescription-medicines-availability/$prescriptionId'),
    );

    final result = json.decode(response.body);

    if (response.statusCode != 200 && mounted) {
      showErrorDialog(context, result['detail']);
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

  Future<void> _processPrescription(String prescriptionId) async {
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

    if (mounted) {
      if (response.statusCode == 200) {
        showInfoDialog(context, 'Success', 'Medicines received successfully');
      } else {
        showErrorDialog(context, 'Failed to receive medicines');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Receive Prescription'),
      ),
      body: Center(
        child: CustomButton(
          text: 'Scan Prescription QR Code',
          onPressed: _scanQrCode,
        ),
      ),
    );
  }
}
