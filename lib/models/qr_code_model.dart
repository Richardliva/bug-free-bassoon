class QRCodeModel {
  String qrCode;
  String vehicleId;
  String qrCodeId;

  QRCodeModel({
    required this.qrCode,
    required this.vehicleId,
    required this.qrCodeId,
  });

  // from map

  factory QRCodeModel.fromMap(Map<String, dynamic> map) {
    return QRCodeModel(
      qrCode: map['qrCode'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      qrCodeId: map['qrCodeId'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "qrCode": qrCode,
      "vehicleId": vehicleId,
      "qrCodeId": qrCodeId,
    };
  }
}
