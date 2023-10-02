import 'package:cloud_firestore/cloud_firestore.dart';

class FuelingModel {
  String odometerInKms;
  String fuelType;
  String attendantId;
  String fuelLitres;
  String totalPrice;
  String vehicleId;
  String fuelingId;
  Timestamp fuelingDate;

  FuelingModel({
    required this.odometerInKms,
    required this.fuelType,
    required this.attendantId,
    required this.fuelLitres,
    required this.totalPrice,
    required this.vehicleId,
    required this.fuelingId,
    required this.fuelingDate,
  });

  // from map

  factory FuelingModel.fromMap(Map<String, dynamic> map) {
    return FuelingModel(
      odometerInKms: map['odometerInKms'] ?? '',
      fuelType: map['fuelType'] ?? '',
      attendantId: map['attendantId'] ?? '',
      fuelLitres: map['fuelLitres'] ?? '',
      totalPrice: map['totalPrice'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      fuelingId: map['fuelingId'] ?? '',
      fuelingDate: map['fuelingDate'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "odometerInKms": odometerInKms,
      "fuelType": fuelType,
      "attendantId": attendantId,
      "fuelLitres": fuelLitres,
      "totalPrice": totalPrice,
      "vehicleId": vehicleId,
      "fuelingId": fuelingId,
      "fuelingDate": fuelingDate,
    };
  }
}
