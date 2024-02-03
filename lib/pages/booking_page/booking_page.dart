import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_parking/controller/PakingController.dart';

import '../../config/colors.dart';

class BookingPage extends StatelessWidget {
  final String slotName;
  final String slotId;

  const BookingPage({Key? key, required this.slotId, required this.slotName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ParkingController parkingController = Get.put(ParkingController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: const Text(
          "BOOK SLOT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animation/running_car.json',
                      width: 300,
                      height: 200,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                const Row(
                  children: [
                    Text(
                      "Book Now 😊",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: blueColor,
                ),
                SizedBox(height: 30),
                const Row(
                  children: [
                    Text(
                      "Enter your name ",
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parkingController.name,
                        decoration: const InputDecoration(
                          fillColor: lightBg,
                          filled: true,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.person,
                            color: blueColor,
                          ),
                          hintText: "ZYX Kumar",
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                const Row(
                  children: [
                    Text(
                      "Enter Vehicle Number ",
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parkingController.vehicalNumber,
                        decoration: const InputDecoration(
                          fillColor: lightBg,
                          filled: true,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.car_rental,
                            color: blueColor,
                          ),
                          hintText: "WB 04 ED 0987",
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                const Row(
                  children: [
                    Text(
                      "Choose Slot Time (in Hour)",
                    )
                  ],
                ),
                SizedBox(height: 10),
                Obx(
                  () => Slider(
                    mouseCursor: MouseCursor.defer,
                    thumbColor: blueColor,
                    activeColor: blueColor,
                    inactiveColor: lightBg,
                    label: "${parkingController.parkingTimeInMin.value} min",
                    value: parkingController.parkingTimeInMin.value,
                    onChanged: (v) {
                      parkingController.parkingTimeInMin.value = v;
                      if (v <= 30) {
                        parkingController.parkingAmount.value = 30;
                      } else {
                        parkingController.parkingAmount.value = 60;
                      }
                      parkingController.parkingAmount.value =
                          (parkingController.parkingTimeInMin.value * 10)
                              .round();
                    },
                    divisions: 5,
                    min: 10,
                    max: 60,
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1"),
                      Text("2"),
                      Text("3"),
                      Text("4"),
                      Text("5"),
                      Text("6"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Slot Name",
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          slotName,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                Obx(() {
                  if (parkingController.isVIP) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text("Membership Type: VIP"),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            // Handle VIP booking logic here
                            parkingController.bookParkingSlot(slotId);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "BOOK HERE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Your Slot Name",
                        ),
                      ],
                    );
                  }
                }),
                SizedBox(height: 10),
                Obx(() {
                  if (parkingController.isVIP) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              slotName,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              slotName,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle regular booking logic here
                            parkingController.bookParkingSlot(slotId);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "PAY NOW",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
