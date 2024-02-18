import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:smart_car_parking/pages/MapPage.dart';

class VipMembershipPaymentPage extends StatefulWidget {
  const VipMembershipPaymentPage({Key? key}) : super(key: key);

  @override
  _VipMembershipPaymentPageState createState() =>
      _VipMembershipPaymentPageState();
}

class _VipMembershipPaymentPageState extends State<VipMembershipPaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cardHolderNameController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  final String predefinedOtp = '123456';
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

  void _showOtpDialog() {
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
              _validateOtp();
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _validateOtp() {
    if (_otpController.text == predefinedOtp) {
      _processOtp();
    } else {
      Get.snackbar(
        "Error",
        "Invalid OTP. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _processOtp() {
    _showPaymentSuccessDialog();
    _storePaymentDetails();
  }

  void _showPaymentSuccessDialog() {
    Get.defaultDialog(
      title: "Payment Successful",
      content: Text("Your payment was successful!"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.offAll(MapPage());
          },
          child: Text("Continue"),
        ),
      ],
    );
  }

  void _storePaymentDetails() {
    FirebaseFirestore.instance.collection('purchase').add({
      'email': _auth.currentUser?.email,
      'amount': 1500.00, // Hardcoded for now, replace with actual amount
      'date': DateTime.now(),
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
        title: Text("VIP Membership Payment 💎"),
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
                CreditCardWidget(
                  cardNumber: _cardNumberController.text,
                  expiryDate: _expiryDateController.text,
                  cardHolderName: _cardHolderNameController.text,
                  cvvCode: _cvcController.text,
                  showBackView: false,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                ),
                SizedBox(height: 20),
                Text(
                  "VIP Membership Price: \Rs1500.00/month",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid card number';
                    } else if (value.length != 16) {
                      return 'Card number must be 16 digits';
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
                      _showOtpDialog();
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
