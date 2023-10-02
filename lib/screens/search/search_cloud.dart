import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/qr_code_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/register_vehicle/view_vehicle_details.dart';
import 'package:provider/provider.dart';

class SearchCloud extends StatefulWidget {
  const SearchCloud({super.key});

  @override
  State<SearchCloud> createState() => _SearchCloudState();
}

class _SearchCloudState extends State<SearchCloud> {
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? FirebaseFirestore.instance
                .collection('Vehicles')
                .where("caseSearch", arrayContains: name)
                .snapshots()
            : FirebaseFirestore.instance.collection("items").snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data!.docs[index];
                    return GestureDetector(
                        onTap: () {
                          selectVehicle(
                                  data['vehicleId'], data['vehicleOwnerId'])
                              .then((value) => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewVehicleDetails()))
                                  });
                        },
                        child: Card(
                          child: Row(
                            children: <Widget>[
                              Image.network(
                                data['vehicleImage'],
                                width: 100,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              Text(
                                data['registrationPlate'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
        },
      ),
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
