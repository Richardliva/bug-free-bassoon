import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/fueling_model.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/models/loyaltyPoints_model.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_input.dart';
import 'package:provider/provider.dart';

class ContinueFuel extends StatefulWidget {
  final LiveStatsModel livestats;
  final VehicleModel vehicle;
  final OwnerModel owner;
  final UserModel user;
  final FuelingModel fueling;
  final String currentPoints;
  const ContinueFuel(
      {super.key,
      required this.livestats,
      required this.vehicle,
      required this.owner,
      required this.user,
      required this.currentPoints,
      required this.fueling});

  @override
  State<ContinueFuel> createState() => _ContinueFuelState();
}

class _ContinueFuelState extends State<ContinueFuel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController redeemablePoints = TextEditingController();
  final TextEditingController totalPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    redeemablePoints.addListener(_setReedemablePrice);
  }

  @override
  void dispose() {
    redeemablePoints.dispose();
    totalPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final isLoading = dataProvider.isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: Text("Fuel Vehicle ${widget.vehicle.registrationPlate}"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 90, 5),
                ),
              )
            : Center(
                child: Column(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "Owner ${widget.owner.ownerNames}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 90, 5)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "+${widget.owner.ownerPhone}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(
                              "Loyalty Points: ${widget.currentPoints} Points"),
                        ],
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.all(1.0),
                    child: Form(
                        key: _formKey,
                        child: Column(children: [
                          CustomInput(
                            controller: redeemablePoints,
                            hintText: "Enter Points To Redeem",
                            icon: Icons.scoreboard_outlined,
                            isPassword: false,
                            validator: (value) {
                              if (double.parse(value!) >
                                      double.parse(widget.currentPoints) ||
                                  double.parse(value) < 0) {
                                return "Please enter points less than ${widget.currentPoints}";
                              }
                              return null;
                            },
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
                              text: "Continue ->",
                              onPressed: () {
                                if (redeemablePoints.text.isEmpty) {
                                  redeemablePoints.text = "0";
                                  totalPrice.text = widget.fueling.totalPrice;
                                }
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.

                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.info,
                                    animType: AnimType.rightSlide,
                                    title: 'Fuel Vehicle',
                                    desc:
                                        'Using ${redeemablePoints.text} Points  and Paying ${totalPrice.text}',
                                    btnCancelOnPress: () {
                                      Navigator.pop(context);
                                    },
                                    btnOkOnPress: () {
                                      fuelVehicleAndStoreLoyaltyTransactions(
                                          widget.vehicle,
                                          widget.owner,
                                          widget.fueling,
                                          widget.user);

                                      AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.topSlide,
                                          title: 'Fueling Successful',
                                          desc:
                                              'Points have been awarded to your account',
                                          btnOkOnPress: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }).show();
                                    },
                                  ).show();
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

  void _setReedemablePrice() {
    if (redeemablePoints.text.isNotEmpty &&
        int.parse(redeemablePoints.text) > 0) {
      setState(() {
        totalPrice.text = (double.parse(widget.fueling.totalPrice) -
                double.parse(redeemablePoints.text))
            .toString();
      });
    }
  }

  void fuelVehicleAndStoreLoyaltyTransactions(VehicleModel vehicleModel,
      OwnerModel ownerModel, FuelingModel fuelingModel, UserModel userModel) {
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

    // Deduct Loyalty Points if redeemed by customer
    // Store Loyalty Points after Fueling

    if (double.parse(redeemablePoints.text) > 0) {
      LoyaltyPointsModel llx = LoyaltyPointsModel(
        loyaltyPointsId: "",
        vehicleId: vehicleModel.vehicleId,
        loyaltyPoints: redeemablePoints.text,
        transactionType: "WITHDRAW",
        transactionDate: Timestamp.fromDate(DateTime.now()),
        fuelingId: newFuel.fuelingId,
      );
      dataProvider.rewardCustomerWithLoyaltyPoints(
          user: userModel,
          fuel: dataProvider.fuelingModel,
          vehicle: vehicleModel,
          loyalty: llx);
    } else {
      dataProvider.rewardCustomerWithLoyaltyPoints(
          user: userModel,
          fuel: dataProvider.fuelingModel,
          vehicle: vehicleModel,
          loyalty: ll);
    }
  }

  Future<double> getCurrentLoyaltyPoints(String vh) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return dataProvider.getCurrentLoyaltyPoints(vh);
  }
}
