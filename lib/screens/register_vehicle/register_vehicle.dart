import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/qr_code_vehicle.dart';
import 'package:petrol_app_mtaani_tech/utils/utils.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_input.dart';
import 'package:provider/provider.dart';

class RegisterVehicle extends StatefulWidget {
  const RegisterVehicle({super.key});

  @override
  State<RegisterVehicle> createState() => _RegisterVehicleState();
}

class _RegisterVehicleState extends State<RegisterVehicle> {
  final _formKey = GlobalKey<FormState>();
  File? image;
  bool isLoading = false;
  final TextEditingController vehiclePlatesController = TextEditingController();
  final TextEditingController vehicleMakeController = TextEditingController();
  final TextEditingController vehicleOwnerController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
      phoneCode: "254",
      countryCode: "KE",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Kenya",
      example: "Kenya",
      displayName: "Kenya",
      displayNameNoCountryCode: "KE",
      e164Key: "");

  @override
  void dispose() {
    super.dispose();
    vehiclePlatesController.dispose();
    vehicleMakeController.dispose();
    vehicleOwnerController.dispose();
    phoneController.dispose();
  }

  void selectImageFromCamera() async {
    image = await pickImageFromCamera(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingV =
        Provider.of<DataProvider>(context, listen: true).isLoading;
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: const Text("Register Vehicle"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: !isLoading
            ? Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.all(1.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text("Vehicle Enrollment",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(174, 0, 126, 21))),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Fill in the details below",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(144, 0, 35, 131))),
                              const SizedBox(
                                height: 8.0,
                              ),
                              CustomInput(
                                  hintText: "Vehicle Plates",
                                  validator: (p0) {
                                    if (p0!.isEmpty ||
                                        !isVehicleMakeValid(p0)) {
                                      return "Vehicle Plates cannot be empty";
                                    }
                                    return null;
                                  },
                                  icon: Icons.car_rental,
                                  isPassword: false,
                                  controller: vehiclePlatesController),
                              CustomInput(
                                  hintText: "Vehicle Make",
                                  icon: Icons.car_repair,
                                  isPassword: false,
                                  validator: (p0) {
                                    if (p0!.isEmpty ||
                                        !isVehicleMakeValid(p0)) {
                                      return "Vehicle Make cannot be empty";
                                    }
                                    return null;
                                  },
                                  controller: vehicleMakeController),
                              CustomInput(
                                hintText: "Owner Names",
                                icon: Icons.supervised_user_circle,
                                isPassword: false,
                                validator: (p0) {
                                  if (p0!.isEmpty || !isVehicleOwnerValid(p0)) {
                                    return "Owner Names cannot be empty";
                                  }
                                  return null;
                                },
                                controller: vehicleOwnerController,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(29.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 15),
                                      blurRadius: 27,
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty ||
                                        !isPhoneNumberValid(value)) {
                                      return "Phone number cannot be empty";
                                    }
                                    return null;
                                  },
                                  cursorColor: Colors.purple,
                                  controller: phoneController,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      phoneController.text = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter phone number",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: InkWell(
                                        onTap: () {
                                          showCountryPicker(
                                              context: context,
                                              countryListTheme:
                                                  const CountryListThemeData(
                                                bottomSheetHeight: 550,
                                              ),
                                              onSelect: (value) {
                                                setState(() {
                                                  selectedCountry = value;
                                                });
                                              });
                                        },
                                        child: Text(
                                          "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    suffixIcon: phoneController.text.length > 8
                                        ? Container(
                                            height: 30,
                                            width: 30,
                                            margin: const EdgeInsets.all(10.0),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                            child: const Icon(
                                              Icons.done,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 150.0, top: 10.0),
                                child: Column(
                                  children: [
                                    const Text("Upload Vehicle Image",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 1),
                                        child: InkWell(
                                          onTap: () => selectImageFromCamera(),
                                          child: image == null
                                              ? const CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  radius: 50,
                                                  child: Icon(Icons.camera_alt,
                                                      size: 50,
                                                      color: Colors.white),
                                                )
                                              : CircleAvatar(
                                                  backgroundImage:
                                                      FileImage(image!),
                                                  radius: 50,
                                                ),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                              // enroll Button

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: CustomButton(
                                  text: "Enroll",
                                  onPressed: () {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Processing Data')),
                                      );

                                      setState(() {
                                        isLoading = true;
                                      });

                                      storeVehicleData();
                                    }
                                    if (image == null) {
                                      AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.error,
                                              animType: AnimType.bottomSlide,
                                              title: "Error",
                                              desc:
                                                  "Please select a vehicle image",
                                              btnOkOnPress: () {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },
                                              btnOkColor: Colors.red)
                                          .show();
                                      return;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )),
    );
  }

  bool isPhoneNumberValid(String phoneNumber) {
    if (phoneNumber.length < 9) {
      return false;
    }
    return true;
  }

  bool isVehiclePlatesValid(String vplates) {
    if (vplates.length < 7) {
      return false;
    }
    return true;
  }

  bool isVehicleMakeValid(String vmake) {
    if (vmake.length < 3) {
      return false;
    }
    return true;
  }

  bool isVehicleOwnerValid(String vowner) {
    if (vowner.length < 3) {
      return false;
    }
    return true;
  }

  // Store vehicle data to firebase get vehicleUid and move to QR generate screen

  void storeVehicleData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = ap.uid;
    VehicleModel vehicleModelx = VehicleModel(
      registrationPlate: vehiclePlatesController.text.trim(),
      vehicleMake: vehicleMakeController.text.trim(),
      vehicleOwnerId: vehicleOwnerController.text.trim(),
      vehicleImage: "",
      registrationDate: Timestamp.fromDate(DateTime.now()),
      vehicleId: "",
      enrollerId: userId,
      caseSearch: setSearchParam(vehiclePlatesController.text.trim()),
    );

    OwnerModel ownerModelx = OwnerModel(
      ownerId: "",
      ownerNames: vehicleOwnerController.text.trim(),
      ownerPhone: selectedCountry.phoneCode + phoneController.text.trim(),
    );

    if (image != null) {
      try {
        dataProvider.enrollVehicleToFirebase(
            vehicleModel: vehicleModelx,
            vehicleImage: image!,
            ownerModel: ownerModelx,
            context: context,
            onSuccess: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const QRCodeGenerator())));
            });
      } catch (e) {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.bottomSlide,
                title: "Error",
                desc: e.toString(),
                btnOkOnPress: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                btnOkColor: Colors.red)
            .show();
      }
    }
  }

  setSearchParam(String vehiclePlates) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < vehiclePlates.length; i++) {
      temp = temp + vehiclePlates[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}
