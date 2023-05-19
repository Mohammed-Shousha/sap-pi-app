import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sap_pi/models/medicine_model.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/utils/constants.dart';
import 'package:sap_pi/utils/dialogs/error_dialog.dart';
import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/custom_list_tile.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/screens/checkout.dart';

class OrderMedicinesScreen extends StatefulWidget {
  const OrderMedicinesScreen({super.key});

  @override
  State<OrderMedicinesScreen> createState() => _OrderMedicinesScreenState();
}

class _OrderMedicinesScreenState extends State<OrderMedicinesScreen> {
  List<Medicine> _medicines = [];
  final List<OrderedMedicine> _orderedMedicines = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    final response =
        await http.get(Uri.parse('${Constants.baseUrl}/medicines'));

    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List;

      setState(() {
        _medicines = jsonList
            .map((json) => Medicine.fromJson(json))
            .where((medicine) => medicine.availableQuantity > 0)
            .toList();
      });
    } else {
      if (mounted) showErrorDialog(context, 'Failed to fetch medicines');
    }
  }

  void _addMedicineToOrder(Medicine medicine) {
    final orderedMedicine = _orderedMedicines.firstWhere(
      (om) => om.id == medicine.id,
      orElse: () => OrderedMedicine.fromMedicine(medicine),
    );

    setState(() {
      if (orderedMedicine.quantity < medicine.availableQuantity) {
        orderedMedicine.quantity += 1;
        if (!_orderedMedicines.contains(orderedMedicine)) {
          _orderedMedicines.add(orderedMedicine);
        }
      } else {
        if (mounted) showErrorDialog(context, 'Not enough quantity available');
      }
    });
  }

  void _removeMedicineFromOrder(OrderedMedicine medicine) {
    final orderedMedicine = _orderedMedicines.firstWhere(
      (om) => om.id == medicine.id,
    );

    setState(() {
      orderedMedicine.quantity -= 1;
      if (orderedMedicine.quantity == 0) {
        _orderedMedicines.remove(orderedMedicine);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Order Medicines'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Medicines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];
                return CustomListTile(
                  titleText: medicine.name,
                  subtitleText:
                      'Available Quantity: ${medicine.availableQuantity} \nPrice: ${medicine.price}',
                  onIconPressed: () => _addMedicineToOrder(medicine),
                );
              },
            ),
          ),
          _orderedMedicines.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      'Ordered Medicines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                )
              : const SizedBox(),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _orderedMedicines.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final medicine = _orderedMedicines[index];
                return CustomListTile(
                  titleText: medicine.name,
                  subtitleText: 'Quantity: ${medicine.quantity.toString()}',
                  trailingIcon: const Icon(Icons.remove),
                  onIconPressed: () => _removeMedicineFromOrder(medicine),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _orderedMedicines.isNotEmpty
              ? CustomButton(
                  text: 'Checkout',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          orderedMedicines: _orderedMedicines,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
