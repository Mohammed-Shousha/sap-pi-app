class Constants {
  static const String baseUrl = "http://192.168.1.8:8000";
  static const String paymentUrl =
      "https://sap-backend-production.up.railway.app/payment-sheet";

  static const medicinesUrl = "$baseUrl/otc-medicines";
  static const orderMedicinesUrl = "$baseUrl/order-medicines";

  static String verifyPrescriptionUrl(String prescriptionId) =>
      "$baseUrl/verify-prescription-medicines-availability/$prescriptionId";

  static String processPrescription(String prescriptionId) =>
      "$baseUrl/process-prescription/$prescriptionId";

  static const String logo = 'assets/images/logo.svg';
  static const String prescription = 'assets/images/prescription.png';
  static const String medicine = 'assets/images/medicine.png';
  static const double imageHeight = 200.0;

  static const double extraLargeFontSize = 40.0;
  static const double largeFontSize = 32.0;
  static const double mediumFontSize = 26.0;
  static const double smallFontSize = 20.0;
}
