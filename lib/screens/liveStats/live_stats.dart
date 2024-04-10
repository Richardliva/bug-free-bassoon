import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:provider/provider.dart';

class LiveStats extends StatefulWidget {
  const LiveStats({super.key});

  @override
  _LiveStatsState createState() => _LiveStatsState();
}

class _LiveStatsState extends State<LiveStats> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    dataProvider.getLiveStatsFromFirestore();
    
    final LiveStatsModel lstats = dataProvider.liveStatsModel;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Live Stats From the Server',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 90, 5)),
          ),
          const SizedBox(height: 20),
          Text(
            "Kerosene Price: ${lstats.kerosene} KES",
            style: ts,
          ),
          const SizedBox(height: 10),
          Text("Diesel Price: ${lstats.diesel} KES", style: ts),
          const SizedBox(height: 10),
          Text("Petrol Price: ${lstats.petrol} KES", style: ts),
          const SizedBox(height: 10),
          Text("Loyalty Points Per Litre: ${lstats.pointsPerLitre} Points", style: ts),
        ],
      ),
    );
  }

  TextStyle ts = const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black);
}
