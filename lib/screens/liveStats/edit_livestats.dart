import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_button.dart';
import 'package:petrol_app_mtaani_tech/widgets/custom_input.dart';
import 'package:provider/provider.dart';

class EditLiveStats extends StatefulWidget {
  final LiveStatsModel liveStatsModel;
  const EditLiveStats({super.key, required this.liveStatsModel});

  @override
  State<EditLiveStats> createState() => _EditLiveStatsState();
}

class _EditLiveStatsState extends State<EditLiveStats> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final TextEditingController kerosenePriceController = TextEditingController();
  final TextEditingController petrolPriceController = TextEditingController();
  final TextEditingController dieselPriceController = TextEditingController();
  final TextEditingController pointsPerLitreController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    kerosenePriceController.text = widget.liveStatsModel.kerosene.toString();
    petrolPriceController.text = widget.liveStatsModel.petrol.toString();
    dieselPriceController.text = widget.liveStatsModel.diesel.toString();
    pointsPerLitreController.text =
        widget.liveStatsModel.pointsPerLitre.toString();
  }

  @override
  void dispose() {
    kerosenePriceController.dispose();
    petrolPriceController.dispose();
    dieselPriceController.dispose();
    pointsPerLitreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 90, 5),
        title: const Text("Edit LiveStats"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: !isLoading
            ? Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.all(1.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text("Live Server Stats",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(174, 0, 126, 21))),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                  "These details will be used to calculate prices and points for customers",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(144, 0, 35, 131))),
                              const SizedBox(
                                height: 8.0,
                              ),
                              const Text('Kerosene Price'),
                              CustomInput(
                                  hintText: "Kerosene Price",
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Kerosene Price field cannot be empty";
                                    }
                                    return null;
                                  },
                                  icon: Icons.gas_meter_outlined,
                                  isPassword: false,
                                  controller: kerosenePriceController),
                              const Text('Petrol Price'),
                              CustomInput(
                                  hintText: "Super Petrol Price",
                                  icon: Icons.email,
                                  isPassword: false,
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Super Petrol Price field cannot be empty";
                                    }
                                    return null;
                                  },
                                  controller: petrolPriceController),
                              const Text('Diesel Price'),
                              CustomInput(
                                  hintText: "Diesel Price",
                                  icon: Icons.price_check_sharp,
                                  isPassword: false,
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Diesel Price field cannot be empty";
                                    }
                                    return null;
                                  },
                                  controller: dieselPriceController),
                              const Text('Points Per Litre'),
                              CustomInput(
                                  hintText: "Points Per Litre",
                                  icon: Icons.score_sharp,
                                  isPassword: false,
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Points Per Litre cannot be empty";
                                    }
                                    return null;
                                  },
                                  controller: pointsPerLitreController),
                              const SizedBox(height: 25),
                              // enroll Button

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 40,
                                child: CustomButton(
                                  text: "Edit Stats",
                                  onPressed: () async {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.

                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (await editLiveStatsAndReturn()) {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.success,
                                            animType: AnimType.rightSlide,
                                            title: "Success",
                                            desc:
                                                "LiveStats edited successfully",
                                            btnOkOnPress: () {
                                              Navigator.pop(context);
                                            }).show();
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.error,
                                                animType: AnimType.rightSlide,
                                                title: "Error",
                                                desc: "Failed to edit Stats",
                                                btnOkOnPress: () {})
                                            .show();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )),
    );
  }

  Future<bool> editLiveStatsAndReturn() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    LiveStatsModel lstating = LiveStatsModel(
        liveStatId: widget.liveStatsModel.liveStatId,
        diesel: dieselPriceController.text.trim(),
        petrol: petrolPriceController.text.trim(),
        kerosene: kerosenePriceController.text.trim(),
        pointsPerLitre: pointsPerLitreController.text.trim());

    return await dataProvider.editLiveStats(lstating);
  }
}
