class OwnerModel {
   String ownerId;
   String ownerNames;
   String ownerPhone;

  OwnerModel({
    required this.ownerId,
    required this.ownerNames,
    required this.ownerPhone,
  });

  // from map

  factory OwnerModel.fromMap(Map<String, dynamic> map) {
    return OwnerModel(
      ownerId: map['ownerId'] ?? '',
      ownerNames: map['ownerNames'] ?? '',
      ownerPhone: map['ownerPhone'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "ownerId": ownerId,
      "ownerNames": ownerNames,
      "ownerPhone": ownerPhone,
    };
  }
}