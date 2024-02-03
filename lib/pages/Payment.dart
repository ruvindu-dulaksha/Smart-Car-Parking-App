import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_car_parking/controller/PakingController.dart';

import '../../config/colors.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ParkingController parkingController =
        Get.find(); // Get the existing instance

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        title: const Text(
          "PAYMENT",
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Amount to Pay:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₨',
                  style: TextStyle(fontSize: 30, color: blueColor),
                ),
                Obx(
                  () => Text(
                    "${parkingController.parkingAmount.value}",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: blueColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to handle the payment (e.g., integrate a payment gateway)
                // For now, let's simulate a successful payment
                parkingController.paymentDone();
                Get.back(); // Go back to the previous page (BookingPage)
              },
              child: Text("CONFIRM PAYMENT"),
            ),
          ],
        ),
      ),
    );
  }
}
