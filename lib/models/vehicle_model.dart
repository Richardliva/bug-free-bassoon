import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  String enrollerId;
  Timestamp registrationDate;
  String registrationPlate;
  String vehicleImage;
  String vehicleMake;
  String vehicleOwnerId;
  String vehicleId;
  List<dynamic> caseSearch;

  VehicleModel({
    required this.enrollerId,
    required this.registrationDate,
    required this.registrationPlate,
    required this.vehicleImage,
    required this.vehicleMake,
    required this.vehicleOwnerId,
    required this.vehicleId,
    required this.caseSearch,
  });

  // from map

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      enrollerId: map['enrollerId'] ?? '',
      registrationDate: map['registrationDate'] ?? '',
      registrationPlate: map['registrationPlate'] ?? '',
      vehicleImage: map['vehicleImage'] ?? '',
      vehicleMake: map['vehicleMake'] ?? '',
      vehicleOwnerId: map['vehicleOwnerId'] ?? '',
      vehicleId: map['vehicleId'] ?? '', 
      caseSearch: map['caseSearch'] ?? [],
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "enrollerId": enrollerId,
      "registrationDate": registrationDate,
      "registrationPlate": registrationPlate,
      "vehicleImage": vehicleImage,
      "vehicleMake": vehicleMake,
      "vehicleOwnerId": vehicleOwnerId,
      "vehicleId": vehicleId,
      "caseSearch": caseSearch,
    };
  }
}
