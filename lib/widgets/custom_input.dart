// Custom Text Input

import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const CustomInput({
    super.key,
    required this.hintText,
    required this.icon,
    required this.isPassword,
    required this.controller, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29.5),
        // ignore: prefer_const_literals_to_create_immutables
        boxShadow: [
          const BoxShadow(
            offset: Offset(0, 15),
            blurRadius: 27,
            color: Colors.black12,
          ),
        ],
      ),
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(
            icon,
            color: Color.fromARGB(255, 5, 77, 8),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility),
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}