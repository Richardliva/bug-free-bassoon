import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/register_screen.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/signup.png",
            height: 300,
          ),
          const SizedBox(height: 20),
          const Text(
            "Let's Get Started",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enroll to the platform now",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 20,
          ),
          //CustomButton
          SizedBox(
            width: double.infinity,
            height: 40,
            child: CustomButton(
                text: "Get Started",
                onPressed: () {
                  if (ap.isSignedIn) {
                    ap.getDataFromSP();
                  }
                  ap.isSignedIn ==
                          false // When True -> Fetch Shared Preference Data
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()))
                      : Navigator.pushNamedAndRemoveUntil(context, '/home_screen', (route) => false);
                }),
          )
        ]),
      ),
    )));
  }
}
