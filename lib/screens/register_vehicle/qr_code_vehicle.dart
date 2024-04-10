import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr/qr.dart';
import 'package:screenshot/screenshot.dart';

class QRCodeGenerator extends StatelessWidget {
  const QRCodeGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final OwnerModel ownerModel = dataProvider.ownerModel;
    final VehicleModel vehicleModel = dataProvider.vehicleModel;
    var isLoading = false;
    ScreenshotController screenshotController = ScreenshotController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: !isLoading
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(1.0),
                            child: Column(children: [
                              Text(
                                  "QR For ${vehicleModel.registrationPlate} ${vehicleModel.vehicleMake}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(174, 0, 126, 21))),
                              Text(vehicleModel.registrationDate
                                  .toDate()
                                  .toString()),
                              Screenshot(
                                controller: screenshotController,
                                child: QrImageView(
                                  data: vehicleModel.vehicleId,
                                  version: QrVersions.auto,
                                  size: 320,
                                  gapless: false,
                                  embeddedImage:
                                      const AssetImage('assets/logo.png'),
                                  embeddedImageStyle: QrEmbeddedImageStyle(
                                    size: const Size(50, 50),
                                  ),
                                ),
                                // child: PrettyQr(
                                //   image: const AssetImage('assets/logo.png'),
                                //   typeNumber: 3,
                                //   size: 200,
                                //   data: vehicleModel.vehicleId,
                                //   errorCorrectLevel: QrErrorCorrectLevel.H,
                                //   roundEdges: false,
                                // )
                              ),
                              Text(vehicleModel.vehicleOwnerId),
                              Text(ownerModel.ownerId),
                              Text(ownerModel.ownerNames),
                              CustomButton(
                                  text: 'SAVE QR CODE',
                                  onPressed: () {
                                    isLoading = true;
                                    screenshotController
                                        .capture()
                                        .then((Uint8List? image) async {
                                      // do something with the image
                                      await dataProvider
                                          .saveQrCodeToFirestore(
                                              image!, vehicleModel.vehicleId)
                                          .then((value) => {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'QR Code Saved ${value.qrCode}'),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 91, 76, 175),
                                                )),
                                                AwesomeDialog(
                                                    context: context,
                                                    dialogType:
                                                        DialogType.success,
                                                    animType: AnimType.topSlide,
                                                    title: 'Vehicle Registered Successfully',
                                                    desc:
                                                        'The QR Code has been saved to the database',
                                                    btnOkOnPress: () {
                                                      Navigator.pop(context);
                                                    }).show(),
                                              });
                                    }).catchError((onError) {
                                      print(onError);
                                    });
                                  }),
                            ]),
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ))),
    );
  }
}
