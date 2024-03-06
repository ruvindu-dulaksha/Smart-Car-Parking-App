import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:smart_car_parking/controller/model/car_model.dart';
import 'package:smart_car_parking/pages/homepage/homepage.dart';

class ParkingController extends GetxController {
  // Define a userId property
  RxString userId = ''.obs;
  RxString membershipType = ''.obs;

  RxList<CarModel> parkingSlotList = <CarModel>[].obs;
  TextEditingController name = TextEditingController();
  TextEditingController vehicalNumber = TextEditingController();
  final Map<String, String> slotKeys = {
    "1": "-NRdY57houxuL83j7cok",
    "2": "-NRdYRojJXhw3_aixhnM",
    "3": "--NRdYTO7yp_MbMxjhic3",
    "4": "-NRdYWXOcd8oWymDLroj",
    "5": "-NRdYWXOcd8oWymDLfslw",
    "6": "-NRdYWXOcd8oWymDLbnkf",
    "7": "-NRdYWXOcd8oWymDLase",
    "8": "-NRdYWXOcd8oWymDLrhe"
    // Add other slot keys here...
  };

  RxBool isVipMember = false.obs;
  bool get isVIP => isVipMember.value;

  void paymentDone() {
    print("Payment done successfully!");
  }

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxDouble parkingTimeInMin = 10.0.obs;
  RxInt parkingAmount = 100.obs;
  RxString slotName = "".obs;

  Rx<CarModel> slot1 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot2 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot3 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot4 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot5 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot6 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot7 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );
  Rx<CarModel> slot8 = Rx<CarModel>(
    CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    _listenToFirebaseChanges();
    //_startDefaultTimerForSlots();
  }



  void _startDefaultTimerForSlot(String slotId) {
    int defaultParkingTime = parkingTimeInMin.value.toInt();
    Timer.periodic(Duration(seconds: 1), (timer) async {
      defaultParkingTime--;
      if (defaultParkingTime == 0) {
        await updateFirebaseSlot(slotId, false);
        _updateSlotStatus(slotId, false);
        timer.cancel();
      }
    });
  }

  void _listenToFirebaseChanges() {
    for (var slotId in slotKeys.values) {
      _databaseReference.child(slotId).onValue.listen((event) {
        var snapshot = event.snapshot;
        var isBooked = snapshot.value as bool;
        if (isBooked) {
          _updateSlotStatus(slotId, true);
          _startTimerForSlot(slotId); // Start timer for the booked slot
        } else {
          _updateSlotStatus(slotId, false);
        }
      });
    }
  }
  void _startTimerForSlot(String slotId) {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      int remainingTime = int.tryParse(_getParkingTime(slotId)) ?? 0;
      remainingTime--;
      _updateParkingTime(slotId, remainingTime);

      if (remainingTime == 0) {
        await updateFirebaseSlot(slotId, false);
        _updateSlotStatus(slotId, false);
        timer.cancel();
      }
    });
  }

  void _updateSlotStatus(String slotId, bool isBooked) {
    switch (slotId) {
      case "-NRdY57houxuL83j7cok":
        slot1.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYRojJXhw3_aixhnM":
        slot2.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "--NRdYTO7yp_MbMxjhic3":
        slot3.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYWXOcd8oWymDLroj":
        slot4.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYWXOcd8oWymDLfslw":
        slot5.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYWXOcd8oWymDLbnkf":
        slot6.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYWXOcd8oWymDLase":
        slot7.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      case "-NRdYWXOcd8oWymDLrhe":
        slot8.value = CarModel(
          booked: isBooked,
          isParked: isBooked,
          parkingHours: isBooked ? "${parkingTimeInMin.value}" : "",
          name: isBooked ? "${name.text}" : "",
          paymentDone: isBooked,
        );
        break;
      default:
        break;
    }
  }

  Future<void> updateFirebaseSlot(String slotId, bool isBooked) async {
    var slotKey = slotKeys[slotId];
    if (slotKey != null) {
      await _databaseReference.child(slotKey).set(isBooked);
    }
  }

  void bookParkingSlot(String slotId) async {
    if (slotId == "1") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "2") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "3") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "4") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "5") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "6") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "7") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    } else if (slotId == "8") {
      await updateFirebaseSlot(slotId, true);
      await BookedPopup(slotId);
    }
  }

  void timeCounter(String slotId) async {
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(hours: 1));
      parkingTime--;

      _updateParkingTime(slotId, parkingTime);

      if (!_isSlotBooked(slotId)) {
        break;
      }
    }

    await updateFirebaseSlot(slotId, false);
    _updateSlotStatus(slotId, false);
    print("Parking Time for Slot $slotId ❤️ End ");
  }

  bool _isSlotBooked(String slotId) {
    switch (slotId) {
      case "1":
        return slot1.value?.booked ?? false;
      case "2":
        return slot2.value?.booked ?? false;
      case "3":
        return slot3.value?.booked ?? false;
      case "4":
        return slot4.value?.booked ?? false;
      case "5":
        return slot5.value?.booked ?? false;
      case "6":
        return slot6.value?.booked ?? false;
      case "7":
        return slot7.value?.booked ?? false;
      case "8":
        return slot8.value?.booked ?? false;
      default:
        return false;
    }
  }

  Future<dynamic> BookedPopup(String slotId) async {
    String nameText = name.text;
    String vehicalNumberText = vehicalNumber.text;
    DateTime now = DateTime.now();

    await Future.delayed(Duration(seconds: 1));
    await updateFirebaseSlot(slotId, true);
    timeCounter(slotId);

    await _firestore.collection('Receipt').add({
      'name': nameText,
      'slot_name': 'A-$slotId',
      'vehicle_number': vehicalNumberText,
      'amount_to_pay': parkingAmount.value,
      'date': now,
    });

    return Get.defaultDialog(
      barrierDismissible: false,
      title: "SLOT BOOKED",
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: blueColor,
      ),
      content: Column(
        children: [
          Lottie.asset(
            'assets/animation/done1.json',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Your Slot Booked",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: blueColor,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person),
              SizedBox(width: 5),
              Text(
                "Name : ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              SizedBox(width: 20),
              Text(
                nameText,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.car_rental),
              SizedBox(width: 5),
              Text(
                "Vehicle No  : ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              SizedBox(width: 20),
              Text(
                vehicalNumberText,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.watch_later_outlined),
              SizedBox(width: 5),
              Text(
                "Parking time : ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              SizedBox(width: 20),
              Obx(() => Text(
                    _getParkingTime(slotId),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.solar_power_outlined),
              SizedBox(width: 5),
              Text(
                "Parking Slot : ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              SizedBox(width: 20),
              Text(
                "A-$slotId",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₨',
                style: TextStyle(
                  fontSize: 30,
                  color: blueColor,
                ),
              ),
              Text(
                parkingAmount.value.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: blueColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.offAll(HomePage());
            },
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  void _updateParkingTime(String slotId, int parkingTime) {
    switch (slotId) {
      case "1":
        slot1.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false; // Set isParked to false when parking time is over
          }
        });
        break;
      case "2":
        slot2.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "3":
        slot3.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "4":
        slot4.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "5":
        slot5.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "6":
        slot6.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "7":
        slot7.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      case "8":
        slot8.update((val) {
          val?.parkingHours = parkingTime.toString();
          if (parkingTime == 0) {
            val?.isParked = false;
          }
        });
        break;
      default:
        break;
    }
  }


  String _getParkingTime(String slotId) {
    switch (slotId) {
      case "1":
        return slot1.value?.parkingHours ?? "";
      case "2":
        return slot2.value?.parkingHours ?? "";
      case "3":
        return slot3.value?.parkingHours ?? "";
      case "4":
        return slot4.value?.parkingHours ?? "";
      case "5":
        return slot5.value?.parkingHours ?? "";
      case "6":
        return slot5.value?.parkingHours ?? "";
      case "7":
        return slot5.value?.parkingHours ?? "";
      case "8":
        return slot5.value?.parkingHours ?? "";

      default:
        return "";
    }
  }
}
