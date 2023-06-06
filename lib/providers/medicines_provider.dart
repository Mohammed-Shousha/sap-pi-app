import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sap_pi/models/medicine_model.dart';

import 'package:sap_pi/models/ordered_medicine_model.dart';

import 'package:sap_pi/utils/constants.dart';

class MedicinesProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  final List<OrderedMedicine> _orderedMedicines = [];
  List<OrderedMedicine> get orderedMedicines => _orderedMedicines;

  num? get orderTotal => _orderedMedicines
      .map((om) => om.price * om.quantity)
      .reduce((total, subtotal) => total + subtotal);

  Future<void> fetchMedicines() async {
    _isLoading = true;
    _errorMessage = '';

    final response = await http.get(Uri.parse(Constants.medicinesUrl));

    if (response.statusCode != 200) {
      _errorMessage = 'Failed to fetch medicines';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final jsonList = json.decode(response.body) as List;

    _medicines = jsonList.map((json) => Medicine.fromJson(json)).toList();

    _isLoading = false;
    notifyListeners();
  }

  void addMedicineToOrder(Medicine medicine) {
    _errorMessage = '';

    final orderedMedicine = _orderedMedicines.firstWhere(
      (om) => om.id == medicine.id,
      orElse: () => OrderedMedicine.fromMedicine(medicine),
    );

    if (!_orderedMedicines.contains(orderedMedicine)) {
      _orderedMedicines.add(orderedMedicine);
    }

    if (orderedMedicine.quantity < medicine.availableQuantity) {
      orderedMedicine.quantity++;
    } else {
      _errorMessage = 'Not enough quantity available';
    }

    notifyListeners();
  }

  void removeMedicineFromOrder(OrderedMedicine medicine) {
    _errorMessage = '';

    final orderedMedicine = _orderedMedicines.firstWhere(
      (om) => om.id == medicine.id,
    );

    orderedMedicine.quantity--;

    if (orderedMedicine.quantity == 0) {
      _orderedMedicines.remove(orderedMedicine);
    }

    notifyListeners();
  }

  Future<bool> orderMedicines() async {
    _isLoading = true;
    _errorMessage = '';

    notifyListeners();

    final response = await http.post(
      Uri.parse(Constants.orderMedicinesUrl),
      body: json.encode(
        _orderedMedicines.map((om) => om.toJson()).toList(),
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final result = json.decode(response.body);

      _errorMessage = result['detail'];
      _isLoading = false;
      _orderedMedicines.clear();
      notifyListeners();

      return false;
    }

    _orderedMedicines.clear();
    _isLoading = false;
    notifyListeners();

    return true;
  }
}
