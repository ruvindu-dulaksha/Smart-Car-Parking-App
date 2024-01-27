import 'package:flutter/material.dart';
import 'package:smart_car_parking/Data.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: blueColor,
        title: const Text(
          "SMART CAR PARKING",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  border: Border.all(
                    width: 5,
                    color: Colors.orange.shade600,
                  ),
                  image: const DecorationImage(
                    image: AssetImage(profilePath),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                LeaderName,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Flexible(
                child: Text(
                  bio,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  var url = Uri.parse("https://github.com/ruvindu-dulaksha");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    print("Could not launch $url");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/icons/youtube.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () async {},
                child: Container(
                  padding: const EdgeInsets.all(2),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/icons/linkeding.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () async {},
                child: Container(
                  padding: const EdgeInsets.all(2),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    "assets/icons/github.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}
