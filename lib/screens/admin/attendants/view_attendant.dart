// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/admin/attendants/edit_attendant.dart';
import 'package:petrol_app_mtaani_tech/widgets/home_button.dart';
import 'package:provider/provider.dart';

class ViewAttendant extends StatefulWidget {
  const ViewAttendant({super.key});

  @override
  State<ViewAttendant> createState() => _ViewAttendantState();
}

class _ViewAttendantState extends State<ViewAttendant> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final UserModel attendant = dataProvider.attendantModel;
    Future<List<int>> listStats = dataProvider.getAttendantStats(attendant.uid);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details ${attendant.name}'),
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    height: 200,
                    child: Image.network(attendant.profilePic),
                  ),
                ),
                Text(attendant.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(attendant.email),
                Text(attendant.phoneNumber),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Text(
                                'Total Vehicles Enrolled: ${snapshot.data![0]}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(height: 5),
                            Text('Vehicles Fueled Today: ${snapshot.data![1]}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal)),
                            const SizedBox(height: 5),
                            Text(
                                'Vehicles Fueled in ${getMonth(getCurrentMonth())} : ${snapshot.data![2]}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal)),
                          ],
                        );
                      } else {
                        return const Text('Loading...');
                      }
                    }),
                    future: listStats),
                const SizedBox(height: 50),
                const Text('Admin Actions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 40,
                  child: HomeButton(
                    text: "Edit User",
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Are you sure you want to Edit?',
                        desc: 'This will edit the vehicle details',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => EditAttendant(
                                        attendant: attendant,
                                      ))));
                        },
                      ).show();
                    },
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 100, 200, 30)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 40,
                  child: HomeButton(
                    text: "Delete User",
                    onPressed: () {
                      if (ap.uid == attendant.uid) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'You cannot delete yourself',
                          desc: 'Wondering why?',
                          btnCancelOnPress: () {},
                        ).show();
                        return;
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          title:
                              'Are you sure you want to Delete ${attendant.name}?',
                          desc: 'This will delete the user\'s details',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            if (await dataProvider.deleteUser(attendant.uid)) {
                              AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.success,
                                  animType: AnimType.bottomSlide,
                                  title: 'User Deleted',
                                  desc: 'User has been deleted successfully',
                                  btnOkOnPress: () {
                                    Navigator.pop(context);
                                  }).show();
                            } else {
                              AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.bottomSlide,
                                  title: 'Error',
                                  desc: 'User has not been deleted',
                                  btnOkOnPress: () {
                                    Navigator.pop(context);
                                  }).show();
                            }
                          },
                        ).show();
                      }
                    },
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 200, 50, 100)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ap.uid != attendant.uid
                    ? FutureBuilder<bool>(
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            if (!snapshot.data!) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: HomeButton(
                                  text: "Promote to Admin",
                                  onPressed: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.rightSlide,
                                      title:
                                          'Are you sure you want to promote ${attendant.name} to SuperAdmin?',
                                      desc:
                                          'This will promote this attendant to SuperAdmin',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () {
                                        dataProvider
                                            .promoteToSuperAdmin(attendant)
                                            .then((value) {
                                          if (value) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.success,
                                              animType: AnimType.bottomSlide,
                                              title: 'Success',
                                              desc:
                                                  'User has been promoted to SuperAdmin',
                                              btnOkOnPress: () {
                                                Navigator.pop(context);
                                              },
                                            ).show();
                                          } else {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.error,
                                              animType: AnimType.bottomSlide,
                                              title: 'Error',
                                              desc:
                                                  'User has not been promoted to SuperAdmin',
                                              btnOkOnPress: () {
                                                Navigator.pop(context);
                                              },
                                            ).show();
                                          }
                                        });
                                      },
                                    ).show();
                                  },
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 255, 128, 0)),
                                ),
                              );
                            } else {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: HomeButton(
                                  text: "Remove Admin",
                                  onPressed: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.rightSlide,
                                      title:
                                          'Are you sure you want to remove Admin from ${attendant.name} ?',
                                      desc:
                                          'This will demote this user to attendant',
                                      btnCancelOnPress: () {},
                                      btnOkOnPress: () {
                                        dataProvider
                                            .demoteToUser(attendant)
                                            .then((value) {
                                          if (value) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.success,
                                              animType: AnimType.bottomSlide,
                                              title: 'Success',
                                              desc:
                                                  'User has been demoted to attendant',
                                              btnOkOnPress: () {
                                                Navigator.pop(context);
                                              },
                                            ).show();
                                          } else {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.error,
                                              animType: AnimType.bottomSlide,
                                              title: 'Error',
                                              desc:
                                                  'User has not been demoted to attendant',
                                              btnOkOnPress: () {
                                                Navigator.pop(context);
                                              },
                                            ).show();
                                          }
                                        });
                                      },
                                    ).show();
                                  },
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 255, 128, 0)),
                                ),
                              );
                            }
                          } else {
                            return const Text('Loading...');
                          }
                        }),
                        future: dataProvider.checkIfAdmin(attendant))
                    : const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get current month  in words
  String getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'Febuary';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'Septemper';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'January';
    }
  }

  // Get current month
  int getCurrentMonth() {
    DateTime now = DateTime.now();
    return now.month;
  }
}
