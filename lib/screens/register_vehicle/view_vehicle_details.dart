// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/vehicles/edit_vehicle.dart';
import 'package:petrol_app_mtaani_tech/screens/fueling/admin_fuel.dart';
import 'package:petrol_app_mtaani_tech/screens/fueling/fueling_vehicle.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/home_button.dart';
import 'package:provider/provider.dart';

class ViewVehicleDetails extends StatelessWidget {
  const ViewVehicleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final ap = Provider.of<AuthProvider>(context, listen: true);
    final OwnerModel ownerModel = dataProvider.ownerModel;
    final VehicleModel vehicleModel = dataProvider.vehicleModel;
    final LiveStatsModel ll = dataProvider.liveStatsModel;
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details ${vehicleModel.registrationPlate}'),
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    height: 200,
                    child: Image.network(vehicleModel.vehicleImage),
                  ),
                ),
                Text(vehicleModel.vehicleMake,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(vehicleModel.registrationDate.toDate().toString()),
                Text('Owner Name: ${ownerModel.ownerNames}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                // CustomButton(text: 'QR Code', onPressed: (){
                //   Navigator.pushNamed(context, '/qr_code_vehicle');
                // }),
                CustomButton(
                    text: 'View QR',
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_qr');
                    }),
                CustomButton(
                    text: 'Fuel Vehicle',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FuelingVehicle(
                                    liveStats: ll,
                                  )));
                    }),
                const SizedBox(height: 50),
                const Text('Admin Actions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 40,
                  child: HomeButton(
                    text: "Edit Vehicle",
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.rightSlide,
                        title: 'Are you sure you want to Edit?',
                        desc:
                            'This will edit the ${vehicleModel.registrationPlate} vehicle details',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditVehicle(
                                        vehicle: vehicleModel,
                                        owner: ownerModel,
                                      )));
                        },
                      ).show();
                    },
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 200, 50, 100)),
                  ),
                ),
                FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == true) {
                          return Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text('Super Admin Actions'),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: HomeButton(
                                  text: "Delete Vehicle",
                                  onPressed: () {
                                    deleteOwnerAndVehicle(
                                        vehicleModel, context);
                                  },
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 2, 148, 2)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: HomeButton(
                                  text: "Fuel & Redeem",
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminFuel(
                                                  liveStats: ll,
                                                )));
                                  },
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 2, 29, 148)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                      return const SizedBox.shrink();
                    },
                    future: ap.checkAdmin())
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deleteOwnerAndVehicle(VehicleModel vehicle, BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Are you sure you want to Delete ${vehicle.registrationPlate}?',
      desc: 'This will delete the user\'s details',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        if (await dataProvider.deleteVehicle(vehicle.vehicleId) &&
            await dataProvider.deleteOwner(vehicle.vehicleOwnerId)) {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Vehicle Deleted',
              desc: 'Vehicle has been deleted successfully',
              btnOkOnPress: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }).show();
        } else {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error',
              desc: 'Vehicle has not been deleted',
              btnOkOnPress: () {
                Navigator.pop(context);
              }).show();
        }
      },
    ).show();
  }
}
