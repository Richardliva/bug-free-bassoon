import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollerModel{
  String enrollerEmail;
  Timestamp enrollerJoinDate;
  String enrollerNames;
  String enrollerPhone;
  String enrollerId;

  EnrollerModel({
    required this.enrollerEmail,
    required this.enrollerJoinDate,
    required this.enrollerNames,
    required this.enrollerPhone,
    required this.enrollerId,
  });

  // from map

  factory EnrollerModel.fromMap(Map<String, dynamic> map) {
    return EnrollerModel(
      enrollerEmail: map['enrollerEmail'] ?? '',
      enrollerJoinDate: map['enrollerJoinDate'] ?? '',
      enrollerNames: map['enrollerNames'] ?? '',
      enrollerPhone: map['enrollerPhone'] ?? '',
      enrollerId: map['enrollerId'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "enrollerEmail": enrollerEmail,
      "enrollerJoinDate": enrollerJoinDate,
      "enrollerNames": enrollerNames,
      "enrollerPhone": enrollerPhone,
      "enrollerId": enrollerId,
    };
  }
} 