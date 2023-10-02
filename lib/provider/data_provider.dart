import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petrol_app_mtaani_tech/models/enroller_model.dart';
import 'package:petrol_app_mtaani_tech/models/fueling_model.dart';
import 'package:petrol_app_mtaani_tech/models/livestats_model.dart';
import 'package:petrol_app_mtaani_tech/models/loyaltyPoints_model.dart';
import 'package:petrol_app_mtaani_tech/models/owner_model.dart';
import 'package:petrol_app_mtaani_tech/models/qr_code_model.dart';
import 'package:petrol_app_mtaani_tech/models/user_model.dart';
import 'package:petrol_app_mtaani_tech/models/vehicle_model.dart';
import 'package:petrol_app_mtaani_tech/utils/utils.dart';

class DataProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _vehicleId;
  String? _ownerId;
  String? _fuelingId;
  String? _enrollerId;
  String? _userId;
  String? _qrCodeId;
  String? _loyaltyPointsId;
  String? _currentLoyaltyPointsx;
  VehicleModel? _vehicleModel;
  OwnerModel? _ownerModel;
  EnrollerModel? _enrollerModel;
  FuelingModel? _fuelingModel;
  UserModel? _userModel;
  UserModel? _attendantModel;
  QRCodeModel? _qrCodeModel;
  LiveStatsModel? _liveStatsModel;
  LoyaltyPointsModel? _loyaltyPointsModel;
  bool get isLoading => _isLoading;
  String get vehicleId => _vehicleId!;
  String get ownerId => _ownerId!;
  String get fuelingId => _fuelingId!;
  String get enrollerId => _enrollerId!;
  String get userId => _userId!;
  String get qrCodeId => _qrCodeId!;
  String get loyaltyPointsId => _loyaltyPointsId!;
  String get currentLoyaltyPointsx => _currentLoyaltyPointsx!;
  VehicleModel get vehicleModel => _vehicleModel!;
  OwnerModel get ownerModel => _ownerModel!;
  EnrollerModel get enrollerModel => _enrollerModel!;
  FuelingModel get fuelingModel => _fuelingModel!;
  UserModel get userModel => _userModel!;
  QRCodeModel get qrCodeModel => _qrCodeModel!;
  UserModel get attendantModel => _attendantModel!;
  LiveStatsModel get liveStatsModel => _liveStatsModel!;
  LoyaltyPointsModel get loyaltyPointsModel => _loyaltyPointsModel!;
  String ServerAdminCollection = 'ServerAdmin';
  String LiveStatsDocumentId = 'L2Rtklx44EV8BT4P4q8I';

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Enroll Vehicle by storing vehicle to collection and
  //using the vehicleId to store the owner and update vehicle document with owner id
  void enrollVehicleToFirebase({
    required VehicleModel vehicleModel,
    required File vehicleImage,
    required BuildContext context,
    required OwnerModel ownerModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    String registrationPlate = vehicleModel.registrationPlate;
    // store vehicle image to storage
    try {
      // check if vehicle with same registration plate exists

      await _firebaseFirestore.collection("Vehicles").get().then((value) => {
            value.docs.forEach((element) {
              if (element.data()["registrationPlate"] ==
                  vehicleModel.registrationPlate) {
                throw Exception(
                    "Vehicle with registration plate ${vehicleModel.registrationPlate} already exists");
              }
            })
          });
      await storeFileToStorage(
              "vehicle_images/$registrationPlate", vehicleImage)
          .then((vehicleImageUrl) => {
                vehicleModel.vehicleImage = vehicleImageUrl,
                vehicleModel.vehicleMake = vehicleModel.vehicleMake,
                vehicleModel.registrationPlate = registrationPlate,
                vehicleModel.enrollerId = vehicleModel.enrollerId,
                vehicleModel.registrationDate =
                    Timestamp.fromDate(DateTime.now()),
                vehicleModel.caseSearch = vehicleModel.caseSearch,
              });
      _vehicleModel = vehicleModel;
      _ownerModel = ownerModel;

      // store vehicle to collection
      await _firebaseFirestore
          .collection("Vehicles")
          .add(vehicleModel.toMap())
          .then((vehicleDoc) => {
                vehicleModel.vehicleId = vehicleDoc.id,
              });
      _vehicleId = vehicleModel.vehicleId;
      _vehicleModel = vehicleModel;
      // store owner to collection
      await _firebaseFirestore
          .collection("Owners")
          .add(ownerModel.toMap())
          .then((ownerDoc) => {
                ownerModel.ownerId = ownerDoc.id,
                _ownerId = ownerDoc.id,
              });
      // update vehicle document with owner id
      await _firebaseFirestore.collection("Vehicles").doc(_vehicleId).update({
        "vehicleOwnerId": _ownerId,
        "vehicleId": _vehicleId,
      }).then((value) => {
            vehicleModel.vehicleOwnerId = _ownerId!,
            _ownerModel = ownerModel,
            _vehicleModel = vehicleModel,
          });

      // update owners collection
      await _firebaseFirestore
          .collection("Owners")
          .doc(_ownerId)
          .update({"ownerId": _ownerId}).then((value) => {
                _isLoading = false,
                notifyListeners(),
                onSuccess(),
              });
    } on Exception catch (e) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: "Error",
              desc: e.toString(),
              btnOkOnPress: () {
                Navigator.pop(context);
              },
              btnOkColor: Colors.red)
          .show();
      showSnackbar(context, e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Store Fuel Details to Firestore
  void fuelVehicle(
      {required VehicleModel vh,
      required UserModel user,
      required FuelingModel fuel,
      required OwnerModel owner}) async {
    _isLoading = true;
    notifyListeners();
    _vehicleModel = vh;
    _userModel = user;
    _ownerModel = owner;
    _vehicleId = vh.vehicleId;
    _ownerId = owner.ownerId;
    _fuelingModel = FuelingModel(
      fuelingId: "",
      vehicleId: vh.vehicleId,
      attendantId: user.uid,
      fuelLitres: fuel.fuelLitres,
      fuelingDate: fuel.fuelingDate,
      totalPrice: fuel.totalPrice,
      fuelType: fuel.fuelType,
      odometerInKms: fuel.odometerInKms,
    );

    await _firebaseFirestore
        .collection("Fuelings")
        .add(_fuelingModel!.toMap())
        .then((fuelingDoc) => {
              _fuelingId = fuelingDoc.id,
              _fuelingModel!.fuelingId = fuelingDoc.id,
            });
    await _firebaseFirestore
        .collection("Fuelings")
        .doc(_fuelingId)
        .update({"fuelingId": _fuelingId}).then((value) => {
              _isLoading = false,
              notifyListeners(),
            });
  }

  // Reward Customer with Loyalty Points after fueling

  void rewardCustomerWithLoyaltyPoints(
      {required UserModel user,
      required FuelingModel fuel,
      required VehicleModel vehicle,
      required LoyaltyPointsModel loyalty}) async {
    _isLoading = true;
    notifyListeners();
    _userModel = user;
    _fuelingModel = fuel;
    _vehicleModel = vehicle;
    _loyaltyPointsModel = LoyaltyPointsModel(
      loyaltyPointsId: "",
      fuelingId: fuel.fuelingId,
      vehicleId: vehicle.vehicleId,
      loyaltyPoints: loyalty.loyaltyPoints,
      transactionType: loyalty.transactionType,
      transactionDate: loyalty.transactionDate,
    );

    // upload to firestore
    await _firebaseFirestore
        .collection("LoyaltyPoints")
        .add(_loyaltyPointsModel!.toMap())
        .then((loyaltyDoc) => {
              _loyaltyPointsId = loyaltyDoc.id,
              _loyaltyPointsModel!.loyaltyPointsId = loyaltyDoc.id,
            });
    // update document with loyalty points id
    await _firebaseFirestore
        .collection("LoyaltyPoints")
        .doc(_loyaltyPointsId)
        .update({
      "loyaltyPointsId": _loyaltyPointsId,
      "fuelingId": _fuelingId
    }).then((value) => {
              _isLoading = false,
              notifyListeners(),
            });
  }

  // Deduct Loyalty Points from Customer after redeeming

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<VehicleModel?> getVehicleDataFromFirestore(String vehicleId) async {
    await _firebaseFirestore
        .collection("Vehicles")
        .doc(vehicleId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _vehicleModel = VehicleModel(
        vehicleId: snapshot.id,
        enrollerId: snapshot['enrollerId'],
        registrationDate: snapshot['registrationDate'],
        vehicleMake: snapshot['vehicleMake'],
        registrationPlate: snapshot["registrationPlate"],
        vehicleImage: snapshot["vehicleImage"],
        vehicleOwnerId: snapshot["vehicleOwnerId"],
        caseSearch: snapshot["caseSearch"],
      );
      _vehicleId = snapshot.id;
      return _vehicleModel!;
    });
  }

  Future getFuelingDataFromFirestore(String fuelingId) async {
    await _firebaseFirestore
        .collection("Fuelings")
        .doc(fuelingId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _fuelingModel = FuelingModel(
          fuelingId: snapshot.id,
          fuelLitres: snapshot['fuelLitres'],
          fuelType: snapshot['fuelType'],
          fuelingDate: snapshot['fuelingDate'],
          odometerInKms: snapshot['odometerInKms'],
          totalPrice: snapshot['totalPrice'],
          vehicleId: snapshot['vehicleId'],
          attendantId: snapshot['attendantId']);
      _fuelingId = snapshot.id;
    });
  }

  Future<OwnerModel?> getOwnerDataFromFirestore(String ownerId) async {
    await _firebaseFirestore
        .collection("Owners")
        .doc(ownerId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _ownerModel = OwnerModel(
        ownerId: snapshot.id,
        ownerNames: snapshot['ownerNames'],
        ownerPhone: snapshot['ownerPhone'],
      );
      _ownerId = snapshot.id;
      return _ownerModel!;
    });
  }

  Future<QRCodeModel?> getQRCodeDataFromFirestore(String vehicleId) async {
    await _firebaseFirestore
        .collection("QrCodes")
        .where('vehicleId', isEqualTo: vehicleId)
        .get()
        .then((QuerySnapshot snapshot) {
      _qrCodeModel = QRCodeModel(
        qrCodeId: snapshot.docs[0].id,
        qrCode: snapshot.docs[0]['qrCode'],
        vehicleId: snapshot.docs[0]['vehicleId'],
      );
      _qrCodeId = snapshot.docs[0].id;
      return _qrCodeModel!;
    });
  }

  Future getEnrollerDataFromFirestore(String enrollerId) async {
    await _firebaseFirestore
        .collection("Enrollers")
        .doc(enrollerId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _enrollerModel = EnrollerModel(
        enrollerId: snapshot.id,
        enrollerEmail: snapshot['enrollerEmail'],
        enrollerPhone: snapshot['enrollerPhone'],
        enrollerNames: snapshot['enrollerNames'],
        enrollerJoinDate: snapshot['enrollerJoinDate'],
      );
      _enrollerId = snapshot.id;
    });
  }

  Future getUserDataFromFirestore(String userId) async {
    await _firebaseFirestore
        .collection("Users")
        .doc(userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        status: snapshot['status'],
        uid: snapshot['uid'],
        profilePic: snapshot['profilePic'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _userId = userModel.uid;
    });
  }

  Future<List<VehicleModel>> getVehiclesFromFirestore() async {
    List<VehicleModel> vehicles = [];
    try {
      await _firebaseFirestore
          .collection("Vehicles")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          vehicles.add(VehicleModel(
            vehicleId: result.id,
            enrollerId: result['enrollerId'],
            registrationDate: result['registrationDate'],
            vehicleMake: result['vehicleMake'],
            registrationPlate: result["registrationPlate"],
            vehicleImage: result["vehicleImage"],
            vehicleOwnerId: result["vehicleOwnerId"],
            caseSearch: result["caseSearch"],
          ));
        });
      });
      return vehicles;
    } on Exception catch (e) {
      print(e.toString());
      return vehicles;
    }
  }

  // Get users list from firestore
  Future<List<UserModel>> getAttendantsFromFirestore() async {
    List<UserModel> users = [];
    try {
      await _firebaseFirestore.collection("users").get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          users.add(UserModel(
            name: result['name'],
            email: result['email'],
            createdAt: result['createdAt'],
            status: result['status'],
            uid: result['uid'],
            profilePic: result['profilePic'],
            phoneNumber: result['phoneNumber'],
          ));
        });
      });
      return users;
    } on Exception catch (e) {
      print(e.toString());
      return users;
    }
  }

  Future<QRCodeModel> saveQrCodeToFirestore(
      Uint8List img, String vehicle) async {
    final tempDir = await getTemporaryDirectory();
    QRCodeModel qrCodeModel = QRCodeModel(
      qrCode: "",
      vehicleId: "",
      qrCodeId: "",
    );
    var file = await File('${tempDir.path}/QRCode_$vehicle.png').create();
    file.writeAsBytesSync(img);
    try {
      await storeFileToStorage("qr_codes/$vehicle", file).then((value) => {
            qrCodeModel.qrCode = value,
            qrCodeModel.vehicleId = vehicle,
            qrCodeModel.qrCodeId = "",
            _qrCodeModel = qrCodeModel,
          });
      await _firebaseFirestore
          .collection("QrCodes")
          .add(qrCodeModel.toMap())
          .then((value) => {
                qrCodeModel.qrCodeId = value.id,
                _qrCodeId = value.id,
                _qrCodeModel = qrCodeModel,
              });
      //update qr code id
      await _firebaseFirestore.collection("QrCodes").doc(_qrCodeId).update({
        "qrCodeId": qrCodeModel.qrCodeId,
      }).then((value) => {
            _qrCodeModel = qrCodeModel,
          });
      return qrCodeModel;
    } on Exception catch (e) {
      // TODO
      print(e.toString());
    }
    return qrCodeModel;
  }

  Future getMobileScan(String vehicleId) async {
    try {
      // Get vehicle, owner and qrcode model data from firestore
      await _firebaseFirestore
          .collection('Vehicles')
          .doc(vehicleId)
          .get()
          .then((value) => {
                _vehicleModel = VehicleModel(
                  vehicleId: value.id,
                  enrollerId: value['enrollerId'],
                  registrationDate: value['registrationDate'],
                  vehicleMake: value['vehicleMake'],
                  registrationPlate: value["registrationPlate"],
                  vehicleImage: value["vehicleImage"],
                  vehicleOwnerId: value["vehicleOwnerId"],
                  caseSearch: value["caseSearch"],
                ),
                _vehicleId = value.id,
              });

      // Get Owner Model
      await _firebaseFirestore
          .collection('Owners')
          .doc(_vehicleModel!.vehicleOwnerId)
          .get()
          .then((value) => {
                _ownerModel = OwnerModel(
                  ownerId: value.id,
                  ownerNames: value['ownerNames'],
                  ownerPhone: value['ownerPhone'],
                ),
                _ownerId = value.id,
              });

      // Get QR Code Model

      await _firebaseFirestore
          .collection('QrCodes')
          .where('vehicleId', isEqualTo: _vehicleModel!.vehicleId)
          .get()
          .then((value) => {
                _qrCodeModel = QRCodeModel(
                  qrCodeId: value.docs[0].id,
                  qrCode: value.docs[0]['qrCode'],
                  vehicleId: value.docs[0]['vehicleId'],
                ),
                _qrCodeId = value.docs[0].id,
              });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  // Get LiveStats from Firestore Collection and Return Object
  void getLiveStatsFromFirestore() async {
    _isLoading = true;
    await _firebaseFirestore
        .collection(ServerAdminCollection)
        .doc(LiveStatsDocumentId)
        .get()
        .then((DocumentSnapshot snapshot) {
      _liveStatsModel = LiveStatsModel(
        liveStatId: snapshot.id,
        diesel: snapshot['Diesel'],
        kerosene: snapshot['Kerosene'],
        petrol: snapshot['SuperPetrol'],
        pointsPerLitre: snapshot['pointsPerLitre'],
      );
      _isLoading = false;
    });
  }

  // Get List of Fueling Collections by Vehicle Id

  Future<List<FuelingModel>> getFuelingFromFirestore(String vehicleId) async {
    List<FuelingModel> fuelingList = [];
    try {
      await _firebaseFirestore
          .collection("Fuelings")
          .where('vehicleId', isEqualTo: vehicleId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          fuelingList.add(FuelingModel(
            fuelingId: result.id,
            fuelLitres: result['fuelLitres'],
            fuelType: result['fuelType'],
            fuelingDate: result['fuelingDate'],
            odometerInKms: result['odometerInKms'],
            totalPrice: result['totalPrice'],
            vehicleId: result['vehicleId'],
            attendantId: result['attendantId'],
          ));
        });
      });
      return fuelingList;
    } on Exception catch (e) {
      debugPrint("THIS YOU?!");
      return fuelingList;
    }
  }

// Check if user is admin
  Future<bool> checkIfAdmin(UserModel user) async {
    DocumentSnapshot snapshot = await _firebaseFirestore
        .collection(ServerAdminCollection)
        .doc(LiveStatsDocumentId)
        .get();
    if (snapshot['admins'].contains(user.uid)) {
      print("USER IS ADMIN");
      return true;
    } else {
      print("USER IS NOT ADMIN");
      return false;
    }
  }

  // Promote User to Admin
  Future<bool> promoteToSuperAdmin(UserModel user) async {
    try {
      await _firebaseFirestore
          .collection(ServerAdminCollection)
          .doc(LiveStatsDocumentId)
          .update({
        "admins": FieldValue.arrayUnion(['${user.uid}'])
      });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  //Demote Admin to User

  Future<bool> demoteToUser(UserModel user) async {
    try {
      await _firebaseFirestore
          .collection(ServerAdminCollection)
          .doc(LiveStatsDocumentId)
          .update({
        "admins": FieldValue.arrayRemove([user.uid])
      });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get list of Loyalty Points Collections by vehicleId
  Future<List<LoyaltyPointsModel>> getLoyaltyPointsFromFirestore(
      String vehicleId) async {
    List<LoyaltyPointsModel> loyaltyPointsList = [];
    try {
      await _firebaseFirestore
          .collection("LoyaltyPoints")
          .where('vehicleId', isEqualTo: vehicleId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          loyaltyPointsList.add(LoyaltyPointsModel(
            loyaltyPointsId: result.id,
            vehicleId: result['vehicleId'],
            loyaltyPoints: result['loyaltyPoints'],
            transactionType: result['transactionType'],
            transactionDate: result['transactionDate'],
            fuelingId: result['fuelingId'],
          ));
        });
      });
      return loyaltyPointsList;
    } on Exception catch (e) {
      print(e.toString());
      return loyaltyPointsList;
    }
  }

  // Get list of Loyalty Points Collections by vehicleId and calculate current points

  Future<double> getCurrentLoyaltyPoints(String vehicleId) async {
    double currentLoyaltyPoints = 0.0;
    try {
      await _firebaseFirestore
          .collection("LoyaltyPoints")
          .where('vehicleId', isEqualTo: vehicleId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          // Check Transaction Type and Add or Subtract
          if (result['transactionType'] == "DEPOSIT") {
            currentLoyaltyPoints += double.parse(result['loyaltyPoints']);
          } else {
            currentLoyaltyPoints -= double.parse(result['loyaltyPoints']);
          }
        });
      });
      return currentLoyaltyPoints;
    } on Exception catch (e) {
      print(e.toString());
      return currentLoyaltyPoints;
    }
  }

  // Edit Vehicle and Owner Details
  Future<bool> editVehicleAndOwnerDetails(
      VehicleModel vehicleModel, OwnerModel ownerModel) async {
    try {
      await _firebaseFirestore
          .collection("Vehicles")
          .doc(vehicleModel.vehicleId)
          .update({
        "vehicleMake": vehicleModel.vehicleMake,
        "registrationPlate": vehicleModel.registrationPlate,
        "caseSearch": vehicleModel.caseSearch,
      }).then((value) => {
                _vehicleModel = vehicleModel,
              });
      await _firebaseFirestore
          .collection("Owners")
          .doc(ownerModel.ownerId)
          .update({
        "ownerNames": ownerModel.ownerNames,
        "ownerPhone": ownerModel.ownerPhone,
      }).then((value) => {
                _ownerModel = ownerModel,
              });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Edit User Details as Attendant
  Future<bool> editAttendantDetails(UserModel user) async {
    try {
      await _firebaseFirestore.collection("users").doc(user.uid).update({
        "name": user.name,
        "email": user.email,
        "phoneNumber": user.phoneNumber,
      }).then((value) => {
            _userModel = user,
          });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Edit Live Stats
  Future<bool> editLiveStats(LiveStatsModel liveStatsModel) async {
    try {
      await _firebaseFirestore
          .collection(ServerAdminCollection)
          .doc(LiveStatsDocumentId)
          .update({
        "Diesel": liveStatsModel.diesel,
        "SuperPetrol": liveStatsModel.petrol,
        "Kerosene": liveStatsModel.kerosene,
        "pointsPerLitre": liveStatsModel.pointsPerLitre,
      }).then((value) => {
                _liveStatsModel = liveStatsModel,
              });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Delete User from Firestore Collection
  Future<bool> deleteUser(String uid) async {
    try {
      await _firebaseFirestore.collection("users").doc(uid).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Delete Vehicle from Firestore Collection
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _firebaseFirestore.collection("Vehicles").doc(vehicleId).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Delete Owner from Firestore Collection
  Future<bool> deleteOwner(String ownerId) async {
    try {
      await _firebaseFirestore.collection("Owners").doc(ownerId).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Get vehicle count of all vehicles in the system enrolled by user
  Future<int> getVehicleCount(String uid) async {
    int vehicleCount = 0;
    try {
      await _firebaseFirestore
          .collection("Vehicles")
          .where('enrollerId', isEqualTo: uid)
          .get()
          .then((querySnapshot) {
        vehicleCount = querySnapshot.docs.length;
      });
      return vehicleCount;
    } on Exception catch (e) {
      print(e.toString());
      return vehicleCount;
    }
  }

  // Get vehicle count of vehicles fueled by user today
  Future<int> getVehicleCountFueledToday(String uid) async {
    int vehicleCount = 0;
    try {
      await _firebaseFirestore
          .collection("Fuelings")
          .where('attendantId', isEqualTo: uid)
          .where('fuelingDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.parse(DateTime.now().toString().split(" ")[0])))
          .get()
          .then((querySnapshot) {
        vehicleCount = querySnapshot.docs.length;
      });
      return vehicleCount;
    } on Exception catch (e) {
      print(e.toString());
      return vehicleCount;
    }
  }

  // Get vehicle count of vehicles fueled by user this month
  Future<int> getVehicleCountFueledThisMonth(String uid) async {
    int vehicleCount = 0;
    try {
      await _firebaseFirestore
          .collection("Fuelings")
          .where('attendantId', isEqualTo: uid)
          .where('fuelingDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.parse(
                  "${DateTime.now().toString().split(" ")[0].split("-")[0]}-${DateTime.now().toString().split(" ")[0].split("-")[1]}-01")))
          .get()
          .then((querySnapshot) {
        vehicleCount = querySnapshot.docs.length;
      });
      return vehicleCount;
    } on Exception catch (e) {
      print(e.toString());
      return vehicleCount;
    }
  }

  // Combined Future List of Attendant Stats
  Future<List<int>> getAttendantStats(String uid) async {
    List<int> attendantStats = [];
    try {
      await getVehicleCount(uid).then((value) => {
            attendantStats.add(value),
          });
      await getVehicleCountFueledToday(uid).then((value) => {
            attendantStats.add(value),
          });
      await getVehicleCountFueledThisMonth(uid).then((value) => {
            attendantStats.add(value),
          });
      return attendantStats;
    } on Exception catch (e) {
      print(e.toString());
      return attendantStats;
    }
  }

  //Select Atttendant from Attendants List

  Future<bool> getAttendantFromFirestore(String attendantId) async {
    UserModel attendantModel;
    try {
      await _firebaseFirestore
          .collection("users")
          .doc(attendantId)
          .get()
          .then((value) => {
                _attendantModel = UserModel(
                  name: value['name'],
                  email: value['email'],
                  phoneNumber: value['phoneNumber'],
                  uid: value['uid'],
                  profilePic: value['profilePic'],
                  createdAt: value['createdAt'],
                  status: value['status'],
                ),
                attendantModel = _attendantModel!
              });
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Delete User from Firestore
  Future<bool> deleteUserFromFirestore(String uid) async {
    try {
      await _firebaseFirestore.collection("users").doc(uid).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
