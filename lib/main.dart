import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/vehicles/vehicle_list.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/vehicles/view_qrCode.dart';
import 'package:petrol_app_mtaani_tech/screens/home_screen.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/qr_code_vehicle.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/register_vehicle.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/view_vehicle_details.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petrol_app_mtaani_tech/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is initialized on app Launch
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const WelcomeScreen(),
        title: "Petrol App",
        initialRoute: '/welcome_screen',
        routes: {
          '/welcome_screen': (context) => const WelcomeScreen(),
          '/register_vehicle': (context) => const RegisterVehicle(),
          '/qr_code_vehicle': (context) => const QRCodeGenerator(),
          '/vehicle_list': (context) => const VehicleList(),
          '/home_screen': (context) => const HomeScreen(),
          '/view_qr':(context) => const ViewQRCode(),
          '/vehicle_details':(context)=>const ViewVehicleDetails(),
        },
      ),
    );
  }
}
