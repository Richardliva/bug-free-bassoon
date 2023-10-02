class LiveStatsModel{
  String liveStatId;
  String diesel;
  String petrol;
  String kerosene;
  String pointsPerLitre;

  LiveStatsModel({
    required this.liveStatId,
    required this.diesel,
    required this.petrol,
    required this.kerosene,
    required this.pointsPerLitre,
  });

  // from map

  factory LiveStatsModel.fromMap(Map<String, dynamic> map) {
    return LiveStatsModel(
      liveStatId: map['liveStatId'] ?? '',
      diesel: map['diesel'] ?? '',
      petrol: map['petrol'] ?? '',
      kerosene: map['kerosene'] ?? '',
      pointsPerLitre: map['pointsPerLitre'] ?? '',
    );
  }

  // to map

  Map<String, dynamic> toMap() {
    return {
      "liveStatId": liveStatId,
      "diesel": diesel,
      "petrol": petrol,
      "kerosene": kerosene,
      "pointsPerLitre": pointsPerLitre,
    };
  }
}