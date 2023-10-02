import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/fueling_model.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/models/loyaltyPoints_model.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_input.dart';
import 'package:provider/provider.dart';

const List<String> list = <String>['Diesel', 'Kerosene', 'Super Petrol'];

class FuelingVehicle extends StatefulWidget {
  final LiveStatsModel liveStats;
  const FuelingVehicle({super.key, required this.liveStats});

  @override
  State<FuelingVehicle> createState() => _FuelingVehicleState();
}

class _FuelingVehicleState extends State<FuelingVehicle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController odometerInKms = TextEditingController();
  final TextEditingController fuelInLitres = TextEditingController();
  final TextEditingController fuelType = TextEditingController();
  final TextEditingController totalPrice = TextEditingController();
  String dropdownValue = list.first;

  @override
  void initState() {
    super.initState();
    fuelInLitres.addListener(_setTotalPrice);
  }

  @override
  void dispose() {
    odometerInKms.dispose();
    fuelInLitres.dispose();
    fuelType.dispose();
    totalPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final isLoading = dataProvider.isLoading;
    VehicleModel vv = dataProvider.vehicleModel;
    OwnerModel oo = dataProvider.ownerModel;
    UserModel uu = ap.userModel;
    LiveStatsModel ll = widget.liveStats;
    FuelingModel ff;
    FuelingModel fuelRecent;
    String lastOdometer = 'N/A';
    String lastFuelDateinDays = 'N/A';
    String currentLoyaltyPoints = "0";
    final Future<List<FuelingModel>> fuelingList =
        dataProvider.getFuelingFromFirestore(vv.vehicleId);
    final Future<List<LoyaltyPointsModel>> loyaltyPointsList =
        dataProvider.getLoyaltyPointsFromFirestore(vv.vehicleId);

    return FutureBuilder<List<FuelingModel>>(
        future: fuelingList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            debugPrint("List Count ${snapshot.data!.length}");
            fuelRecent = snapshot.data![0];
            for (var i = 0; i < snapshot.data!.length; i++) {
              FuelingModel fuelRN = snapshot.data![i];
              if (fuelRN.fuelingDate
                  .toDate()
                  .isAfter(fuelRecent.fuelingDate.toDate())) {
                fuelRecent = fuelRN;
              }
            }

            lastOdometer = fuelRecent.odometerInKms;
            lastFuelDateinDays = fuelRecent.fuelingDate
                .toDate()
                .difference(DateTime.now())
                .inDays
                .toString();

            return FutureBuilder<dynamic>(
                future: getCurrentLoyaltyPoints(vv.vehicleId),
                builder: (context, snapshot2) {
                  if (snapshot2.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  // if (snapshot2.connectionState == ConnectionState.waiting) {
                  //   return const Center(
                  //     child: CircularProgressIndicator(),
                  //   );
                  // }

                  if (snapshot2.hasData) {
                    currentLoyaltyPoints = snapshot2.data.toString();
                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
                        title: Text("Fuel Vehicle ${vv.registrationPlate}"),
                      ),
                      body: SafeArea(
                          child: SingleChildScrollView(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 0, 90, 5),
                              ))
                            : Center(
                                child: Column(children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      margin: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Owner ${oo.ownerNames}",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 0, 90, 5)),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "+${oo.ownerPhone}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                              "Last Odometer Reading: $lastOdometer Kms"),
                                          const SizedBox(height: 3),
                                          Text(
                                              "Days since last fueling: $lastFuelDateinDays Days"),
                                          const SizedBox(height: 3),
                                          Text(
                                              "Loyalty Points: $currentLoyaltyPoints Points"),
                                        ],
                                      )),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    margin: const EdgeInsets.all(1.0),
                                    child: Form(
                                        key: _formKey,
                                        child: Column(children: [
                                          CustomInput(
                                            controller: odometerInKms,
                                            hintText: "Enter Odometer in Kms",
                                            icon: Icons.commute_sharp,
                                            isPassword: false,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please enter Odometer in Kms";
                                              }
                                              return null;
                                            },
                                          ),
                                          CustomInput(
                                            controller: fuelInLitres,
                                            isPassword: false,
                                            icon:
                                                Icons.local_gas_station_rounded,
                                            hintText: "Enter Fuel in Litres",
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please enter Fuel in Litres";
                                              }
                                              return null;
                                            },
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                            child: DropdownButton<String>(
                                              value: dropdownValue,
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              iconSize: 30,
                                              isExpanded: true,
                                              elevation: 30,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 0, 90, 5)),
                                              underline: Container(
                                                  height: 3,
                                                  color: const Color.fromARGB(
                                                      255, 0, 90, 5)),
                                              onChanged: (String? value) {
                                                debugPrint(
                                                    "User selected $value");
                                                // This is called when the user selects an item.
                                                setState(() {
                                                  dropdownValue = value!;
                                                });
                                                _setTotalPrice();
                                              },
                                              items: list.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          CustomInput(
                                            controller: totalPrice,
                                            isPassword: false,
                                            icon: Icons.money,
                                            hintText: "Enter Total Price",
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please enter Total Price";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 25),
                                          // enroll Button
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 40,
                                            child: CustomButton(
                                              text: "Fuel Vehicle",
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  ff = FuelingModel(
                                                    odometerInKms:
                                                        odometerInKms.text,
                                                    fuelType: dropdownValue,
                                                    attendantId: uu.uid,
                                                    fuelLitres:
                                                        fuelInLitres.text,
                                                    totalPrice: totalPrice.text,
                                                    vehicleId: vv.vehicleId,
                                                    fuelingId: "",
                                                    fuelingDate:
                                                        Timestamp.fromDate(
                                                            DateTime.now()),
                                                  );

                                                  fuelVehicle(vv, oo, ff, uu,
                                                      currentLoyaltyPoints);
                                                }
                                                return;
                                              },
                                            ),
                                          ),
                                        ])),
                                  )
                                ]),
                              ),
                      )),
                    );
                  }
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: const Color.fromARGB(255, 0, 90, 5),
                      title: Text("Fuel Vehicle ${vv.registrationPlate}"),
                    ),
                    body: SafeArea(
                        child: SingleChildScrollView(
                      child: Center(
                        child: Column(children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    "Owner ${oo.ownerNames}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 90, 5)),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "+${oo.ownerPhone}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      "Last Odometer Reading: $lastOdometer Kms"),
                                  const SizedBox(height: 3),
                                  Text(
                                      "Days since last fueling: $lastFuelDateinDays Days"),
                                  const SizedBox(height: 3),
                                  Text(
                                      "Loyalty Points: $currentLoyaltyPoints Points"),
                                ],
                              )),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(1.0),
                            child: Form(
                                key: _formKey,
                                child: Column(children: [
                                  CustomInput(
                                    controller: odometerInKms,
                                    hintText: "Enter Odometer in Kms",
                                    icon: Icons.commute_sharp,
                                    isPassword: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter Odometer in Kms";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInput(
                                    controller: fuelInLitres,
                                    isPassword: false,
                                    icon: Icons.local_gas_station_rounded,
                                    hintText: "Enter Fuel in Litres",
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter Fuel in Litres";
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: DropdownButton<String>(
                                      value: dropdownValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      iconSize: 30,
                                      isExpanded: true,
                                      elevation: 30,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Color.fromARGB(255, 0, 90, 5)),
                                      underline: Container(
                                          height: 3,
                                          color: const Color.fromARGB(
                                              255, 0, 90, 5)),
                                      onChanged: (String? value) {
                                        debugPrint("User selected $value");
                                        // This is called when the user selects an item.
                                        setState(() {
                                          dropdownValue = value!;
                                        });
                                        _setTotalPrice();
                                      },
                                      items: list.map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  CustomInput(
                                    controller: totalPrice,
                                    isPassword: false,
                                    icon: Icons.money,
                                    hintText: "Enter Total Price",
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter Total Price";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                  // enroll Button
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 40,
                                    child: CustomButton(
                                      text: "Fuel Vehicle",
                                      onPressed: () {
                                        // Validate returns true if the form is valid, or false otherwise.
                                        if (_formKey.currentState!.validate()) {
                                          ff = FuelingModel(
                                            odometerInKms: odometerInKms.text,
                                            fuelType: dropdownValue,
                                            attendantId: uu.uid,
                                            fuelLitres: fuelInLitres.text,
                                            totalPrice: totalPrice.text,
                                            vehicleId: vv.vehicleId,
                                            fuelingId: "",
                                            fuelingDate: Timestamp.fromDate(
                                                DateTime.now()),
                                          );

                                          fuelVehicle(vv, oo, ff, uu,
                                              currentLoyaltyPoints);
                                        }
                                        return;
                                      },
                                    ),
                                  ),
                                ])),
                          )
                        ]),
                      ),
                    )),
                  );
                });
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 0, 90, 5),
              title: Text("Fuel Vehicle ${vv.registrationPlate}"),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "Owner ${oo.ownerNames}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 90, 5)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "+${oo.ownerPhone}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 10),
                          Text("Last Odometer Reading: $lastOdometer Kms"),
                          const SizedBox(height: 3),
                          Text(
                              "Days since last fueling: $lastFuelDateinDays Days"),
                          const SizedBox(height: 3),
                          Text("Loyalty Points: $currentLoyaltyPoints Points"),
                        ],
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.all(1.0),
                    child: Form(
                        key: _formKey,
                        child: Column(children: [
                          CustomInput(
                            controller: odometerInKms,
                            hintText: "Enter Odometer in Kms",
                            icon: Icons.commute_sharp,
                            isPassword: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter Odometer in Kms";
                              }
                              return null;
                            },
                          ),
                          CustomInput(
                            controller: fuelInLitres,
                            isPassword: false,
                            icon: Icons.local_gas_station_rounded,
                            hintText: "Enter Fuel in Litres",
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter Fuel in Litres";
                              }
                              return null;
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 30,
                              isExpanded: true,
                              elevation: 30,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 0, 90, 5)),
                              underline: Container(
                                  height: 3,
                                  color: const Color.fromARGB(255, 0, 90, 5)),
                              onChanged: (String? value) {
                                debugPrint("User selected $value");
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownValue = value!;
                                });
                                _setTotalPrice();
                              },
                              items: list.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          CustomInput(
                            controller: totalPrice,
                            isPassword: false,
                            icon: Icons.money,
                            hintText: "Enter Total Price",
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter Total Price";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          // enroll Button
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 40,
                            child: CustomButton(
                              text: "Fuel Vehicle",
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  ff = FuelingModel(
                                    odometerInKms: odometerInKms.text,
                                    fuelType: dropdownValue,
                                    attendantId: uu.uid,
                                    fuelLitres: fuelInLitres.text,
                                    totalPrice: totalPrice.text,
                                    vehicleId: vv.vehicleId,
                                    fuelingId: "",
                                    fuelingDate:
                                        Timestamp.fromDate(DateTime.now()),
                                  );

                                  fuelVehicle(
                                      vv, oo, ff, uu, currentLoyaltyPoints);
                                }
                                return;
                              },
                            ),
                          ),
                        ])),
                  )
                ]),
              ),
            )),
          );
        });
  }

  void fuelVehicle(
      VehicleModel vehicleModel,
      OwnerModel ownerModel,
      FuelingModel fuelingModel,
      UserModel userModel,
      String currentLoyaltyPoints) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.fuelVehicle(
        vh: vehicleModel,
        fuel: fuelingModel,
        user: userModel,
        owner: ownerModel);
    LiveStatsModel lxd = dataProvider.liveStatsModel;
    double lp = double.parse(fuelingModel.fuelLitres) *
        double.parse(lxd.pointsPerLitre);

    FuelingModel newFuel = dataProvider.fuelingModel;
    // Store Loyalty Points after Fueling
    LoyaltyPointsModel ll = LoyaltyPointsModel(
        loyaltyPointsId: "",
        vehicleId: vehicleModel.vehicleId,
        loyaltyPoints: "$lp",
        transactionType: "DEPOSIT",
        transactionDate: Timestamp.fromDate(DateTime.now()),
        fuelingId: newFuel.fuelingId);
    dataProvider.rewardCustomerWithLoyaltyPoints(
        user: userModel,
        fuel: dataProvider.fuelingModel,
        vehicle: vehicleModel,
        loyalty: ll);

    AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Successfully Fueled",
        desc: "Details saved to database",
        btnOkOnPress: () {
          Navigator.pop(context);
        }).show();
  }

  void _setTotalPrice() {
    LiveStatsModel lxd = widget.liveStats;
    String selectedFuel = "";
    if (fuelInLitres.text.isEmpty) {
      return;
    } else {
      debugPrint("Fuel Type ${fuelType.text}");
      if (dropdownValue == "Kerosene") {
        selectedFuel = lxd.kerosene;
      }
      if (dropdownValue == "Diesel") {
        selectedFuel = lxd.diesel;
        debugPrint("Diesel $selectedFuel");
      }
      if (dropdownValue == "Super Petrol") {
        selectedFuel = lxd.petrol;
      }
      setState(() {
        totalPrice.text =
            (double.parse(fuelInLitres.text) * double.parse(selectedFuel))
                .toString();
      });
    }
  }

  Future<double> getCurrentLoyaltyPoints(String vh) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return dataProvider.getCurrentLoyaltyPoints(vh);
  }
}
