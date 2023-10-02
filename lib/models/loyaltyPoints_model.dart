// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyPointsModel{
  String loyaltyPointsId;
  String vehicleId;
  String loyaltyPoints;
  String transactionType;
  Timestamp transactionDate;
  String fuelingId;

  LoyaltyPointsModel({
    required this.loyaltyPointsId,
    required this.vehicleId,
    required this.loyaltyPoints,
    required this.transactionType,
    required this.transactionDate,
    required this.fuelingId,
  });

  // from map

  factory LoyaltyPointsModel.fromMap(Map<String, dynamic> map) {
    return LoyaltyPointsModel(
      loyaltyPointsId: map['loyaltyPointsId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      loyaltyPoints: map['loyaltyPoints'] ?? '',
      transactionType: map['transactionType'] ?? '',
      transactionDate: map['transactionDate'] ?? '',
      fuelingId: map['fuelingId'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "loyaltyPointsId": loyaltyPointsId,
      "vehicleId": vehicleId,
      "loyaltyPoints": loyaltyPoints,
      "transactionType": transactionType,
      "transactionDate": transactionDate,
      "fuelingId": fuelingId,
    };
  }
}