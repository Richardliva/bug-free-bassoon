import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_input.dart';
import 'package:provider/provider.dart';

class EditAttendant extends StatefulWidget {
  final UserModel attendant;
  const EditAttendant({super.key, required this.attendant});

  @override
  State<EditAttendant> createState() => _EditAttendantState();
}

class _EditAttendantState extends State<EditAttendant> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController namesController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
    namesController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      namesController.text = widget.attendant.name;
      emailController.text = widget.attendant.email;
      phoneController.text = widget.attendant.phoneNumber.substring(3);
    });
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: Text("Edit User Details: ${widget.attendant.name}"),
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
                              const Text("User Details",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(174, 0, 126, 21))),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Fill in the details below or cancel",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(144, 0, 35, 131))),
                              const SizedBox(
                                height: 8.0,
                              ),
                              CustomInput(
                                  hintText: "Full Names",
                                  validator: (p0) {
                                    if (p0!.isEmpty ||
                                        !isVehicleMakeValid(p0)) {
                                      return "Name field cannot be empty";
                                    }
                                    return null;
                                  },
                                  icon: Icons.person_4,
                                  isPassword: false,
                                  controller: namesController),
                              CustomInput(
                                  hintText: "Email Address",
                                  icon: Icons.email,
                                  isPassword: false,
                                  validator: (p0) {
                                    if (p0!.isEmpty ||
                                        !isVehicleMakeValid(p0)) {
                                      return "Email cannot be empty";
                                    }
                                    return null;
                                  },
                                  controller: emailController),
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
                              const SizedBox(height: 25),
                              // enroll Button

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: CustomButton(
                                  text: "Edit",
                                  onPressed: () async {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.

                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (await editAttendantDetailsAndReturn()) {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.success,
                                            animType: AnimType.rightSlide,
                                            title: "Success",
                                            desc: "User edited successfully",
                                            btnOkOnPress: () {
                                              Navigator.pop(context);
                                            }).show();
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.error,
                                                animType: AnimType.rightSlide,
                                                title: "Error",
                                                desc: "Failed to edit User",
                                                btnOkOnPress: () {})
                                            .show();
                                      }
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

  Future<bool> editAttendantDetailsAndReturn() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    UserModel attending = UserModel(
      uid: widget.attendant.uid,
      email: emailController.text.trim(),
      name: namesController.text.trim(),
      phoneNumber: selectedCountry.phoneCode + phoneController.text.trim(),
      status: widget.attendant.status,
      createdAt: widget.attendant.createdAt,
      profilePic: widget.attendant.profilePic,
    );

    return dataProvider.editAttendantDetails(attending);
  }
}
