import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:smart_car_parking/controller/PakingController.dart';

class PaymentPage extends StatefulWidget {
  final String slotId;
  final String slotName;
  final double amountToPay;

  const PaymentPage({
    Key? key,
    required this.slotId,
    required this.slotName,
    required this.amountToPay,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cardHolderNameController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  // Predefined OTP
  final String predefinedOtp = '123456';

  // Define your ParkingController
  final ParkingController parkingController = Get.find<ParkingController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showOtpDialog(
    String cardNumber,
    String expiryDate,
    String cardHolderName,
    String cvcCode,
  ) {
    Get.defaultDialog(
      title: "Enter OTP",
      content: Column(
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            onChanged: (value) {},
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              inactiveColor: Colors.grey,
              selectedFillColor: Colors.blue,
              selectedColor: Colors.black,
              activeFillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Validate entered OTP
              _validateOtp(
                cardNumber,
                expiryDate,
                cardHolderName,
                cvcCode,
              );
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _validateOtp(
    String cardNumber,
    String expiryDate,
    String cardHolderName,
    String cvcCode,
  ) {
    // Check if the entered OTP is correct
    if (_otpController.text == predefinedOtp) {
      _processOtp(
        cardNumber,
        expiryDate,
        cardHolderName,
        cvcCode,
      );
    } else {
      Get.snackbar(
        "Error",
        "Invalid OTP. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _processOtp(
    String cardNumber,
    String expiryDate,
    String cardHolderName,
    String cvcCode,
  ) async {
    // Simulate payment success and book parking slot

    Get.defaultDialog(
      title: "Payment Successful",
      content: Text("Your payment was successful!"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            // Store payment details in Firestore
            await _storePaymentDetails(
              cardNumber,
              expiryDate,
              cardHolderName,
              cvcCode,
            );
            // Simulate payment success and book parking slot
            parkingController.bookParkingSlot(widget.slotId);
            // Show OTP dialog
            _showOtpDialog(
              cardNumber,
              expiryDate,
              cardHolderName,
              cvcCode,
            );
          },
          child: Text("OK"),
        ),
      ],
    );
  }

  Future<void> _storePaymentDetails(
    String cardNumber,
    String expiryDate,
    String cardHolderName,
    String cvcCode,
  ) async {
    // Get current timestamp
    Timestamp timestamp = Timestamp.now();
    // Format the timestamp as a string
    String formattedTimestamp = timestamp.toDate().toString();

    // Store payment details in Firestore
    await _firestore.collection('payments').add({
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvcCode': cvcCode,
      'slotId': widget.slotId,
      'slotName': widget.slotName,
      'amountPaid': widget.amountToPay,
      'timestamp': formattedTimestamp,
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();
    _cvcController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 176, 157, 219),
        title: Text("Payment"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Amount to Pay: Rs ${widget.amountToPay}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                CreditCardWidget(
                  cardNumber: _cardNumberController.text,
                  expiryDate: _expiryDateController.text,
                  cardHolderName: _cardHolderNameController.text,
                  cvvCode: _cvcController.text,
                  showBackView: false,
                  cardBgColor: Colors.blue,
                  height: 200,
                  animationDuration: Duration(milliseconds: 1000),
                  onCreditCardWidgetChange: (CreditCardBrand) {},
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid card number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(labelText: 'Expiry Date'),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid expiry date';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cvcController,
                        decoration: InputDecoration(labelText: 'CVC'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid CVC';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _showOtpDialog(
                        _cardNumberController.text,
                        _expiryDateController.text,
                        _cardHolderNameController.text,
                        _cvcController.text,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Continue",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
