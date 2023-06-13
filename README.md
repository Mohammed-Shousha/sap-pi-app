# SAP (Smart Automatic Pharmacy) PI App 💊

A tablet application developed using Flutter that allows users to interact with a machine controlled by a Raspberry Pi for receiving prescriptions and ordering over-the-counter (OTC) medicines. The app provides a seamless experience for users to easily manage their medication needs.

## Features

### Receive Prescription

Users can simply press a button to scan a prescription QR code. The app utilizes the device's camera to scan the QR code and initiate the process of retrieving the prescribed medicines from the machine.

Upon successful retrieval of the medicines, the app will display a "Thank You" screen to confirm that the process has been completed. In case of any errors or issues during the retrieval process, the app will display a "Contact Us" screen, allowing the user to reach out to the support team for assistance.

### Order Medicines

Users can browse through a list of available over-the-counter medicines and select the items they wish to purchase. The app provides a convenient checkout process where users can review their selected medicines and proceed to payment.

For payment, the app supports credit card transactions. Users can securely enter their credit card details and complete the payment process. Upon successful payment, the app will initiate the retrieval of the ordered medicines from the machine.

Similar to the prescription retrieval feature, if the medicine retrieval is successful, the app will display a "Thank You" screen. If any errors occur during the retrieval process, the user will be directed to a "Contact Us" screen for further assistance.

## Used Packages

- **flutter_barcode_scanner**: This package is used to integrate barcode scanning functionality into the app. It enables the app to scan prescription QR codes for initiating the medicine retrieval process.

- **flutter_stripe**: The flutter_stripe package is utilized for integrating Stripe payment functionality into the app. It allows users to securely enter their credit card details and complete the payment process when ordering medicines.

- **provider**: The provider package is used for state management in the app. It enables efficient management of app state and data flow, ensuring a smooth and reactive user experience.

- **http**: The http package is used for making HTTP requests from the app. It facilitates communication between the app and any necessary backend services running on the raspberry pi for retrieving prescription and medicine data.
