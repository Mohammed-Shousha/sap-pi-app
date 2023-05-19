import 'package:flutter/material.dart';
import 'package:sap_pi/models/ordered_medicine_model.dart';
import 'package:sap_pi/utils/palette.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.medicine,
  });

  final OrderedMedicine medicine;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shadowColor: Palette.primary,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${medicine.quantity} pack(s)',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '${medicine.price} EGP',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
