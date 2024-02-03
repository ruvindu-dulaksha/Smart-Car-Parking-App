import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_parking/Data.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:smart_car_parking/pages/LoginPage.dart';
import 'package:smart_car_parking/pages/vip_membership_payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  AboutUs({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                // Delete account logic
                await _auth.currentUser?.delete();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _upgradeToVIP(BuildContext context) async {
    // Navigate to VIP Membership Payment page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VipMembershipPaymentPage()),
    );

    // After successful upgrade, update user data in Firestore
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'membershipType': 'VIP',
      'vipMembershipExpirationDate': Timestamp.fromDate(
        DateTime.now().add(Duration(days: 30)),
      ),
    });

    // Pop until reaching the root route (Map page)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

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
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator(); // Loading indicator
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;

            bool isVIP = userData['membershipType'] == 'VIP';
            DateTime? expirationDate =
                userData['vipMembershipExpirationDate']?.toDate();
            int daysLeft = expirationDate != null
                ? expirationDate.difference(DateTime.now()).inDays
                : 0;

            return Column(
              children: [
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
                        image: DecorationImage(
                          image: AssetImage(profilePath),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData['firstName'] ?? '',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Email: ${userData['email']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Type: ${userData['userType']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Membership: ${userData['membershipType']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isVIP)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Days Left: $daysLeft',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (!isVIP)
                  ElevatedButton(
                    onPressed: () async {
                      // Handle the upgrade to VIP logic
                      await _upgradeToVIP(context);
                    },
                    child: Text("Upgrade to VIP"),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Log out logic
                        await _auth.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text("Log Out"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Show delete account dialog
                        _showDeleteAccountDialog(context);
                      },
                      child: Text("Delete Account"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        var url =
                            Uri.parse("https://github.com/ruvindu-dulaksha");
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
