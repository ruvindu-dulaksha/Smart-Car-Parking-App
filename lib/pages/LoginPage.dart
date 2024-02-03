import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_car_parking/components/MyButton.dart';
import 'package:smart_car_parking/components/MyTextField.dart';
import 'package:smart_car_parking/pages/MapPage.dart';
import 'package:smart_car_parking/pages/SignUpPage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 176, 157, 219),
        title: Text("SMART CAR PARKING"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Welcome back ❤️",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      'assets/images/Login.png',
                      width: 250,
                      height: 250,
                    ),
                  ],
                ),
                SizedBox(height: 30),
                MyTextField(
                  icons: Icons.email,
                  lable: "Email id",
                  Onchange: emailController,
                ),
                SizedBox(height: 10),
                MyTextField(
                  icons: Icons.lock,
                  lable: "Password",
                  Onchange: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 90),
                MyButton(
                  icon: Icons.admin_panel_settings_rounded,
                  Btname: "LOGIN",
                  ontap: () async {
                    try {
                      // Sign in user with email and password
                      UserCredential userCredential =
                          await _auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // Navigate to MapPage on successful login
                      Get.offAll(MapPage());
                    } catch (e) {
                      // Handle login errors
                      print("Login Error: $e");

                      // Show a snackbar with the error message
                      Get.snackbar(
                        "Login Failed",
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                        duration: Duration(seconds: 3),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                MyButton(
                  icon: Icons.person_add,
                  Btname: "SIGN UP",
                  ontap: () {
                    Get.offAll(SignUpPage());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
