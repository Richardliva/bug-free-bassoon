import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/attendants/view_attendant.dart';
import 'package:provider/provider.dart';

class AttendantsList extends StatefulWidget {
  const AttendantsList({super.key});

  @override
  State<AttendantsList> createState() => _AttendantsListState();
}

class _AttendantsListState extends State<AttendantsList> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final Future<List<UserModel>> attendantsList =
        dataProvider.getAttendantsFromFirestore();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: const Text("Attendants List"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.8,
                    margin: const EdgeInsets.all(1.0),
                    child: FutureBuilder<dynamic>(
                      future: attendantsList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    selectAttendant(
                                            snapshot.data![index].uid)
                                        .then((value) => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ViewAttendant()))
                                            });
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.purple,
                                        backgroundImage: NetworkImage(snapshot
                                            .data![index].profilePic
                                            .toString()),
                                        radius: 50,
                                      ),
                                      title:
                                          // ignore: prefer_interpolation_to_compose_strings
                                          Text(("${index + 1} " +
                                              snapshot.data![index].name)),
                                      subtitle: Text(
                                          snapshot.data![index].phoneNumber),
                                    ),
                                  ),
                                );
                              });
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        );
                      },
                    ))
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future<bool> selectAttendant(String attendantId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return dataProvider.getAttendantFromFirestore(attendantId);
  }
}
