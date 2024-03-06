import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_car_parking/Data.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'package:smart_car_parking/pages/LoginPage.dart';
import 'package:smart_car_parking/pages/vip_membership_payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  AboutUs({Key? key}) : super(key: key);

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _imageFile; // Initialize with null
  final picker = ImagePicker();

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    // Dialog implementation remains the same
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
    // Upgrade to VIP logic remains the same
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    User? user = _auth.currentUser; // Move user definition here
    if (_imageFile != null) {
      // 1. Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference reference = storage.ref().child('profile_pictures/$fileName');
      UploadTask uploadTask = reference.putFile(_imageFile!);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // 2. Store URL in Firestore
      if (imageUrl.isNotEmpty) {
        await _firestore.collection('users').doc(user?.uid).update({
          'profilePictureUrl': imageUrl,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser; // Define user here

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
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.orange.shade600,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider<Object>?
                            : AssetImage(profilePath),
                      ),
                    ),
                    IconButton(
                      onPressed: _pickImage,
                      icon: Icon(Icons.edit),
                      color: Colors.white,
                    ),
                    SizedBox(width: 30), // Add some space between the icons
                    IconButton(
                      onPressed: () {
                        _uploadImage(); // Call the method to upload the profile picture
                      },
                      icon: Icon(Icons.camera_alt),
                      color: const Color.fromARGB(255, 3, 0, 0),
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
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile page
                        // Replace `EditProfilePage` with your actual edit profile page
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfilePage()));
                      },
                      child: Text("Edit Profile"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to purchase history page
                        // Replace `PurchaseHistoryPage` with your actual purchase history page
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PurchaseHistoryPage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PurchaseHistoryPage(
                                  userEmail: userData['email'], isVIP: isVIP)),
                        );
                      },
                      child: Text("Purchase History"),
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

class PurchaseHistoryPage extends StatelessWidget {
  final String userEmail;
  final bool isVIP;

  const PurchaseHistoryPage({
    Key? key,
    required this.userEmail,
    required this.isVIP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(isVIP ? 'purchase' : 'Receipt')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No purchase history found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              Timestamp timestamp =
                  data['date']; // Assuming 'date' is the Timestamp field

              // Convert Timestamp to DateTime
              DateTime dateTime = timestamp.toDate();

              // Format the DateTime
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

              return ListTile(
                title:
                    Text('Date: $formattedDate, Amount: Rs${data['amount']}'),
              );
            },
          );
        },
      ),
    );
  }
}
