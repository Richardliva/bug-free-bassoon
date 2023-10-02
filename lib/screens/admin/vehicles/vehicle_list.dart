import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/qr_code_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/view_vehicle_details.dart';
import 'package:provider/provider.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({super.key});

  @override
  State<VehicleList> createState() => _VehicleListState();

  static void dispose() {}
}

class _VehicleListState extends State<VehicleList> {
  String? vehicleCount;
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final Future<List<VehicleModel>> vehicleList =
        dataProvider.getVehiclesFromFirestore();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: const Text("Vehicles List"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.8,
                    margin: const EdgeInsets.all(1.0),
                    child: FutureBuilder<dynamic>(
                      future: vehicleList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    selectVehicle(
                                            snapshot.data![index].vehicleId,
                                            snapshot
                                                .data![index].vehicleOwnerId)
                                        .then((value) => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ViewVehicleDetails()))
                                            });
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.purple,
                                        backgroundImage: NetworkImage(snapshot
                                            .data![index].vehicleImage
                                            .toString()),
                                        radius: 50,
                                      ),
                                      title:
                                          // ignore: prefer_interpolation_to_compose_strings
                                          Text(("${index + 1} " +
                                              snapshot
                                                  .data![index].vehicleMake)),
                                      subtitle: Text(snapshot
                                          .data![index].registrationPlate),
                                    ),
                                  ),
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                          color: Colors.green,
                          ),
                        );
                      },
                    ))
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future selectVehicle(String vehicleId, String ownerId) async {
    final dataProv = Provider.of<DataProvider>(context, listen: false);
    VehicleModel? vv = await dataProv.getVehicleDataFromFirestore(vehicleId);
    OwnerModel? oo = await dataProv.getOwnerDataFromFirestore(ownerId);
    QRCodeModel? qr = await dataProv.getQRCodeDataFromFirestore(vehicleId);
    return [vv, oo, qr];
  }
}
