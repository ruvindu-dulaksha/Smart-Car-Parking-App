import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_car_parking/components/MyButton.dart';
import 'package:smart_car_parking/components/MyTextField.dart';
import 'package:smart_car_parking/pages/LoginPage.dart';
import 'package:smart_car_parking/pages/MapPage.dart';
import 'package:smart_car_parking/pages/Vip_Membership_Payment_Page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Add form key

  TextEditingController firstNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nibmIdController = TextEditingController();

  String userType = "Staff";
  String membershipType = "Regular";

  List<String> userTypes = ["Staff", "Lecturer"];
  List<String> membershipTypes = ["Regular", "VIP"];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }


  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
    }
    return null;
  }
  String? _validateNIBMID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your NIBM ID';
    } else if (!value.contains('.nibm')) {
      return 'NIBM ID must contain ".nibm"';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 176, 157, 219),
        title: Text("SMART CAR PARKING"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the previous page (Login page)
            Get.offAll(LoginPage());
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Add the image here
                  Image.asset(
                    'assets/images/sign.png', // Replace with your image path
                    height: 250,
                    width: 250,
                  ),
                  SizedBox(height: 20),
                  MyTextField(
                    icons: Icons.person,
                    lable: "User Name",
                    Onchange: firstNameController, validator: (String? value) {  },
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    icons: Icons.email,
                    lable: "Email Address",
                    Onchange: emailController,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    icons: Icons.lock,
                    lable: "Password",
                    Onchange: passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    icons: Icons.credit_card,
                    lable: "NIBM ID",
                    Onchange: nibmIdController, validator: (String? value) {  },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Select User Type:"),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: userType,
                        onChanged: (String? value) {
                          setState(() {
                            userType = value ?? "";
                          });
                        },
                        items: userTypes.map((String userType) {
                          return DropdownMenuItem<String>(
                            value: userType,
                            child: Text(userType),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Select Membership Type:"),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: membershipType,
                        onChanged: (String? value) {
                          setState(() {
                            membershipType = value ?? "";
                          });
                        },
                        items: membershipTypes.map((String membershipType) {
                          return DropdownMenuItem<String>(
                            value: membershipType,
                            child: Text(membershipType),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MyButton(
                    icon: Icons.person_add,
                    Btname: "SIGN UP",
                    ontap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Validation passed
                        if (membershipType == "VIP") {
                          // Navigate to VIP Membership Payment Page
                          Get.to(VipMembershipPaymentPage());
                        } else {
                          try {
                            // Create user in Firebase Authentication
                            UserCredential userCredential =
                            await _auth.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            // Add user details to Firestore
                            try {
                              print(
                                  "Attempting to add user details to Firestore");
                              await _firestore
                                  .collection('users')
                                  .doc(userCredential.user?.uid)
                                  .set({
                                'firstName': firstNameController.text,
                                'email': emailController.text,
                                'nibmId': nibmIdController.text,
                                'userType': userType,
                                'membershipType': membershipType,
                              });
                              print(
                                  "User details added to Firestore successfully");
                            } catch (e) {
                              print(
                                  "Error adding user details to Firestore: $e");
                            }

                            // Navigate to the MapPage on successful sign-up
                            Get.offAll(MapPage());
                          } catch (e) {
                            print("Error during sign up: $e");
                            // Handle the error (e.g., show a snackbar)
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
