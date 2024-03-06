import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String lable;
  final IconData icons;
  final TextEditingController Onchange;
  final bool obscureText; // Add the obscureText parameter
  final String? Function(String? value)? validator; // Add validator function
  const MyTextField({
    Key? key,
    required this.lable,
    required this.icons,
    required this.Onchange,
    this.obscureText = false, // Default value is set to false
    this.validator, // Validator function
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: Onchange,
            obscureText: obscureText, // Use the obscureText parameter here
            validator: validator, // Use the validator function
            decoration: InputDecoration(
              prefixIcon: Icon(icons),
              fillColor: Colors.deepPurple.shade200,
              filled: true,
              hintText: lable,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
