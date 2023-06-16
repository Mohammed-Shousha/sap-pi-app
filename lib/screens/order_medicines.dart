import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sap_pi/models/medicine_model.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';

import 'package:sap_pi/providers/medicines_provider.dart';

import 'package:sap_pi/screens/checkout.dart';
import 'package:sap_pi/utils/constants.dart';

import 'package:sap_pi/widgets/custom_button.dart';
import 'package:sap_pi/widgets/custom_list_tile.dart';
import 'package:sap_pi/widgets/gradient_scaffold.dart';
import 'package:sap_pi/widgets/error_text.dart';

import 'package:sap_pi/utils/dialogs/error_dialog.dart';

class OrderMedicinesScreen extends StatefulWidget {
  const OrderMedicinesScreen({super.key});

  @override
  State<OrderMedicinesScreen> createState() => _OrderMedicinesScreenState();
}

class _OrderMedicinesScreenState extends State<OrderMedicinesScreen> {
  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  void _fetchMedicines() async {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);

    await medicinesProvider.fetchMedicines();

    if (medicinesProvider.errorMessage.isNotEmpty && mounted) {
      showErrorDialog(context, medicinesProvider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicinesProvider = Provider.of<MedicinesProvider>(context);

    final medicines = medicinesProvider.medicines;

    final orderedMedicines = medicinesProvider.orderedMedicines;

    final isLoading = medicinesProvider.isLoading;

    final errorMessage = medicinesProvider.errorMessage;

    if (errorMessage.isNotEmpty && orderedMedicines.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showErrorDialog(context, errorMessage),
      );
    }

    addMedicineToOrder(Medicine medicine) {
      medicinesProvider.addMedicineToOrder(medicine);
    }

    removeMedicineFromOrder(OrderedMedicine medicine) {
      medicinesProvider.removeMedicineFromOrder(medicine);
    }

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Order Medicines'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : medicines.isEmpty
              ? const ErrorText(text: 'No medicines found')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Medicines',
                      style: TextStyle(
                        fontSize: Constants.largeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = medicines[index];
                          return CustomListTile(
                            titleText: medicine.name,
                            subtitleText:
                                'Available Quantity: ${medicine.availableQuantity} \nPrice: ${medicine.price}',
                            onIconPressed: () => addMedicineToOrder(medicine),
                          );
                        },
                      ),
                    ),
                    orderedMedicines.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Divider(),
                              SizedBox(height: 10),
                              Text(
                                'Ordered Medicines',
                                style: TextStyle(
                                  fontSize: Constants.largeFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                        : const SizedBox(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: orderedMedicines.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final orderedMedicine = orderedMedicines[index];
                          return CustomListTile(
                            titleText: orderedMedicine.name,
                            subtitleText:
                                'Quantity: ${orderedMedicine.quantity}',
                            trailingIcon: const Icon(Icons.remove),
                            onIconPressed: () =>
                                removeMedicineFromOrder(orderedMedicine),
                          );
                        },
                      ),
                    ),
                    orderedMedicines.isNotEmpty
                        ? CustomButton(
                            text: 'Checkout',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                  ],
                ),
    );
  }
}
