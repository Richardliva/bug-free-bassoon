import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/attendants/attendants_list.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/vehicles/vehicle_list.dart';
import 'package:petrol_app_mtaani_tech/screens/liveStats/edit_livestats.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/register_vehicle.dart';
import 'package:petrol_app_mtaani_tech/utils/utils.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/home_button.dart';
import 'package:provider/provider.dart';

class NormalHome extends StatelessWidget {
  final AuthProvider ap;
  final int selectedIndex;
  final List<BottomNavigationBarItem> navBarItems;
  const NormalHome(
      {super.key,
      required this.ap,
      required this.selectedIndex,
      required this.navBarItems});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    Future<List<int>> ls = dataProvider.getAttendantStats(ap.uid);
    Future<bool> ifAdmin = ap.checkAdmin();
    return FutureBuilder<List<int>>(
        future: ls,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40,
                  child: HomeButton(
                    text: "Register Vehicle",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterVehicle()));
                    },
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 247, 102, 6)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40,
                  child: HomeButton(
                    text: "Vehicle List",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VehicleList()));
                    },
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 31, 120, 253)),
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
                                  text: "Attendants List",
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AttendantsList()));
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
                                  text: "Edit Live Prices",
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return EditLiveStats(
                                        liveStatsModel:
                                            dataProvider.liveStatsModel,
                                      );
                                    }));
                                  },
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 131, 2, 148)),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                      return const SizedBox.shrink();
                    },
                    future: ifAdmin),
                const SizedBox(height: 10),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  backgroundImage: NetworkImage(ap.userModel.profilePic),
                  radius: 50,
                ),
                const SizedBox(height: 10),
                Text(ap.userModel.name),
                Text(ap.userModel.phoneNumber),
                Text(ap.userModel.email),
                // Text("Selected Page: ${navBarItems[selectedIndex].label}"),
                const SizedBox(height: 30),
                Text(
                  'Total Vehicles Enrolled : ${snapshot.data![0]}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 10),
                Text('Vehicles Fueled Today : ${snapshot.data![1]}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                const SizedBox(height: 10),
                Text(
                  'Vehicles Fueled in ${getMonth(getCurrentMonth())} : ${snapshot.data![2]}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ],
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  // Get current month  in words
  String getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'Febuary';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'Septemper';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'January';
    }
  }

  // Get current month
  int getCurrentMonth() {
    DateTime now = DateTime.now();
    return now.month;
  }
}
