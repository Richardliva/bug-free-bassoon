import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final MaterialStateProperty<Color> backgroundColor;

  const HomeButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: backgroundColor,
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
