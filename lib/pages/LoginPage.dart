import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences package
import 'package:smart_car_parking/components/MyButton.dart';
import 'package:smart_car_parking/components/MyTextField.dart';
import 'package:smart_car_parking/pages/AdminPage.dart';
import 'package:smart_car_parking/pages/MapPage.dart';
import 'package:smart_car_parking/pages/SignUpPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = _auth.currentUser != null;
    bool shouldRememberMe = prefs.getBool('rememberMe') ?? false;

    if (isAuthenticated && shouldRememberMe) {
      Get.offAll(MapPage());
    } else {
      _getRememberMe();
    }
  }
  void _getRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _setRememberMe(bool? value) async { // Handle nullable boolean type
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value ?? false;
    });
    prefs.setBool('rememberMe', value ?? false);
    if (!(value ?? false)) {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 176, 157, 219),
        title: Text("SMART CAR PARKING"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings_rounded),
            onPressed: () {
              Get.to(AdminPage());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    icons: Icons.lock,
                    lable: "Password",
                    Onchange: passwordController,
                    obscureText: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                            _setRememberMe(value);
                          });
                        },
                      ),
                      Text('Remember Me'),
                    ],
                  ),
                  SizedBox(height: 90),
                  MyButton(
                    icon: Icons.admin_panel_settings_rounded,
                    Btname: "LOGIN",
                    ontap: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if (!GetUtils.isEmail(email) || password.length < 6) {
                        Get.snackbar(
                          "Validation Error",
                          "Please fill in the email and password fields",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 3),
                        );
                        return;
                      }

                      try {
                        if (rememberMe) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String storedEmail = prefs.getString('email') ?? '';
                          String storedPassword = prefs.getString('password') ?? '';

                          if (email == storedEmail && password == storedPassword) {
                            // Use stored credentials for authentication
                            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                              email: storedEmail,
                              password: storedPassword,
                            );

                            Get.offAll(MapPage());
                            return;
                          }
                        }

                        // If "Remember Me" is not checked or stored credentials don't match, use entered credentials
                        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        if (rememberMe) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString('email', email);
                          prefs.setString('password', password);
                        }

                        Get.offAll(MapPage());
                      } on FirebaseAuthException catch (e) {
                        String errorMessage = "An error occurred. Please try again.";

                        if (e.code == 'invalid-email') {
                          errorMessage = "Invalid email address.";
                        } else if (e.code == 'user-not-found') {
                          errorMessage = "User not found. Please check your email.";
                        } else if (e.code == 'wrong-password') {
                          errorMessage = "Wrong password. Please check your password.";
                        }

                        Get.snackbar(
                          "Login Failed",
                          errorMessage,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 3),
                        );
                      } catch (e) {
                        print("Login Error: $e");

                        Get.snackbar(
                          "Login Failed",
                          "An error occurred. Please try again.",
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
      ),
    );
  }
}
