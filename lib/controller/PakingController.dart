import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:smart_car_parking/controller/model/car_model.dart';

class ParkingController extends GetxController {
  RxList<CarModel> parkingSlotList = <CarModel>[].obs;
  TextEditingController name = TextEditingController();
  TextEditingController vehicalNumber = TextEditingController();
  final Map<String, String> slotKeys = {
    "1": "-NRdY57houxuL83j7cok",
    "2": "-NRdYRojJXhw3_aixhnM",
    "3": "--NRdYTO7yp_MbMxjhic3",
    "4": "-NRdYWXOcd8oWymDLroj",
    // Add other slot keys here...
  };
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  RxDouble parkingTimeInMin = 10.0.obs;
  RxInt parkingAmount = 100.obs;
  RxString slotName = "".obs;
  // int time = 19;
  Rx<CarModel> slot1 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot2 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot3 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot4 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot5 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot6 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot7 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  Rx<CarModel> slot8 = CarModel(
    booked: false,
    isParked: false,
    parkingHours: "",
    name: "",
    paymentDone: false,
  ).obs;
  @override
  void onInit() {
    super.onInit();
    _listenToFirebaseChanges();
    // Start the default timer for each slot
    _startDefaultTimerForSlots();
  }

  void _startDefaultTimerForSlots() {
    for (var slotId in slotKeys.values) {
      if (slotId != null) {
        _startDefaultTimerForSlot(slotId);
      }
    }
  }

  void _startDefaultTimerForSlot(String slotId) {
    int defaultParkingTime = 60; // Default time in minutes
// Start timer for the slot
    Timer.periodic(Duration(seconds: 1), (timer) async {
      defaultParkingTime--;
      if (defaultParkingTime == 0) {
        // Reset Firebase value and local slot value after default parking duration ends
        await updateFirebaseSlot(
            slotId, false); // Reset Firebase value to false
        _updateSlotStatus(slotId, false); // Reset local slot status

        // Cancel the timer when the parking duration ends
        timer.cancel();
      }
    });
  }

  void _listenToFirebaseChanges() {
    for (var slotId in slotKeys.values) {
      _databaseReference.child(slotId).onValue.listen((event) {
        var snapshot = event.snapshot;
        var isBooked = snapshot.value as bool;

        // Update the local slot status based on Firebase value changes
        if (isBooked) {
          _updateSlotStatus(slotId, true);
        } else {
          _updateSlotStatus(slotId, false);
        }
      });
    }
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
      // Add cases for other slot IDs...
      default:
        break;
    }
  }

  Future<void> updateFirebaseSlot(String slotId, bool isBooked) async {
    var slotKey = slotKeys[slotId]; // Retrieve the Firebase key based on slotId

    if (slotKey != null) {
      await _databaseReference.child(slotKey).set(isBooked);
    }
  }

  void bookParkingSlot(String slotId) async {
    // ... existing code remains unchanged ...

    if (slotId == "1") {
      await updateFirebaseSlot(slotId, true);
      slot1Controller();
    } else if (slotId == "2") {
      await updateFirebaseSlot(slotId, true);
      slot2Controller();
    } else if (slotId == "3") {
      await updateFirebaseSlot(slotId, true);
      slot3Controller();
    } else if (slotId == "4") {
      await updateFirebaseSlot(slotId, true);
      slot4Controller();
    }
    // Add similar update calls for other slots...
    BookedPopup();
  }

  void slot1Controller() async {
    slot1.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );

    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(
          Duration(minutes: 1)); // Change the delay to 1 minute
      parkingTime--;
      slot1.value.parkingHours = parkingTime.toString();
      print(parkingTime);
    }

    // Reset Firebase value and local slot value after parking duration ends
    await updateFirebaseSlot("1", false); // Reset Firebase value to false
    slot1.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot2Controller() async {
    slot2.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      print(parkingTime);
      slot2.value.parkingHours = parkingTime.toString();
    }

    await updateFirebaseSlot("2", false);
    slot2.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot3Controller() async {
    slot3.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );

    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      slot3.value.parkingHours = parkingTime.toString();
      print(parkingTime);
    }

    // Reset Firebase value and local slot value after parking duration ends
    await updateFirebaseSlot("3", false); // Reset Firebase value to false
    slot3.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot4Controller() async {
    slot4.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );

    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      slot4.value.parkingHours = parkingTime.toString();
      print(parkingTime);
    }

    // Reset Firebase value and local slot value after parking duration ends
    await updateFirebaseSlot("4", false); // Reset Firebase value to false
    slot4.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot5Controller() async {
    slot5.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      print(parkingTime);
      slot5.value.parkingHours = parkingTime.toString();
    }

    slot5.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot6Controller() async {
    slot6.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      print(parkingTime);
      slot6.value.parkingHours = parkingTime.toString();
    }

    slot6.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot7Controller() async {
    slot7.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      print(parkingTime);
      slot7.value.parkingHours = parkingTime.toString();
    }

    slot7.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void slot8Controller() async {
    slot8.value = CarModel(
      booked: true,
      isParked: true,
      parkingHours: "${parkingTimeInMin.value}",
      name: "${name.text}",
      paymentDone: true,
    );
    int parkingTime = parkingTimeInMin.value.toInt();

    while (parkingTime != 0) {
      await Future.delayed(Duration(minutes: 1));
      parkingTime--;
      slot8.value.parkingHours = parkingTime.toString();
      print(parkingTime);
    }

    slot8.value = CarModel(
      booked: false,
      isParked: false,
      parkingHours: "",
      name: "",
      paymentDone: false,
    );
    print("Parking Time  ❤️ End ");
  }

  void timeCounter() {}
  Future<dynamic> BookedPopup() {
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
                  name.text,
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
                  "Vehical No  : ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(width: 20),
                Text(
                  vehicalNumber.text,
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
                Text(
                  parkingTimeInMin.value.toString(),
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
                  "A-${slotName.value.toString()}",
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
                  '₨', // Sri Lanka Rupee symbol
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
                Get.back();
              },
              child: Text("Close"),
            )
          ],
        ));
  }
}
