import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/qr_code_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ViewQRCode extends StatelessWidget {
  const ViewQRCode({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final OwnerModel ownerModel = dataProvider.ownerModel;
    final VehicleModel vehicleModel = dataProvider.vehicleModel;
    final QRCodeModel qrCodeModel = dataProvider.qrCodeModel;
    return  Scaffold(
      appBar: AppBar(
        title: const Text('QR Code View'),
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
                  child: Column(children: [
                     Text('Vehicle QR Code ${vehicleModel.registrationPlate}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.all(1.0),
                      child: SizedBox(
                        height: 200,
                        child: Image.network(qrCodeModel.qrCode),
                      ),
                    ),
                    Text('Owner Name: ${ownerModel.ownerNames}'),
                    Text('Owner Phone: ${ownerModel.ownerPhone}'),
                    Text('Make: ${vehicleModel.vehicleMake}'),
                    // CustomButton(text: 'SAS', onPressed: (){
                      
                    // })
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}