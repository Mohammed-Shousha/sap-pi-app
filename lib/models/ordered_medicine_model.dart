import 'package:sap_pi/models/medicine_model.dart';

class OrderedMedicine {
  final String id;
  final String name;
  final num price;
  int quantity;
  final Map<String, dynamic>? position;
  String? doctorInstructions;

  OrderedMedicine({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.doctorInstructions,
    this.position,
  });

  factory OrderedMedicine.fromMedicine(Medicine medicine) {
    return OrderedMedicine(
      id: medicine.id,
      name: medicine.name,
      quantity: 0,
      price: medicine.price,
      position: medicine.position,
    );
  }

  factory OrderedMedicine.fromJson(Map<String, dynamic> json) {
    return OrderedMedicine(
      id: json['medicineId'],
      name: json['medicineName'],
      price: json['price'],
      quantity: json['quantity'],
      doctorInstructions: json['doctorInstructions'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': id,
      'medicineName': name,
      'price': price,
      'quantity': quantity,
      'doctorInstructions': doctorInstructions,
      'position': position,
    };
  }
}
