import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_car_parking/pages/MapPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String _userCount = "0";
  bool _isAdminLoggedIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserCount();
  }

  Future<void> _fetchUserCount() async {
    try {
      QuerySnapshot users = await _firestore.collection('users').get();
      setState(() {
        _userCount = users.docs.length.toString();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user count: $e';
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      List<DocumentSnapshot> users = usersSnapshot.docs;

      String? selectedUserId = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select User to Delete'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(users[index]['firstName']),
                    onTap: () {
                      Navigator.of(context).pop(users[index].id);
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (selectedUserId != null) {
        await _firestore.collection('users').doc(selectedUserId).delete();
        _fetchUserCount();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting user: $e';
      });
    }
  }

  Future<void> _addNewLocation() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPage()),
    );
  }

  Future<void> _addNewAdmin() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  // Store additional admin details in Firestore
                  await _firestore.collection('AdminUsers').add({
                    'email': emailController.text,
                    // Add other admin details as needed
                  });
                  setState(() {
                    _errorMessage = null;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New admin added successfully')),
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMessage = e.message;
                  });
                } catch (e) {
                  print(e);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _controlSlotAddition() async {
    // Implement slot addition control functionality here
  }

  Future<void> _loginAsAdmin() async {
    final defaultEmail = 'admin';
    final defaultPassword = 'admin';

    try {
      if (emailController.text == defaultEmail &&
          passwordController.text == defaultPassword) {
        setState(() {
          _isAdminLoggedIn = true;
        });
      } else {
        // If the entered credentials don't match the default admin credentials
        throw 'Invalid email or password';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login Error: $e';
      });
    }
  }

  Future<void> _chooseReportType() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Report Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop('VIP');
                },
                child: Text('VIP Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop('Regular');
                },
                child: Text('Regular Report'),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // Handle the selected report type here
        if (value == 'VIP') {
          _showVIPReport();
        } else if (value == 'Regular') {
          _showRegularReport(); // Call the method to show the regular report
        }
      }
    });
  }

  Future<void> _showRegularReport() async {
    try {
      // Navigate to a new screen to display the regular report
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegularReportScreen(),
        ),
      );
    } catch (e) {
      print('Error generating regular report: $e');
      // Handle error
    }
  }


  Future<void> _showVIPReport() async {
    try {
      // Navigate to a new screen to display VIP report
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VIPReportScreen(),
        ),
      );
    } catch (e) {
      print('Error generating VIP report: $e');
      // Handle error
    }
  }

  Widget _buildAdminDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Total Users: $_userCount',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _deleteUser('userId'), // Replace 'userId' with actual user ID
          icon: Icon(Icons.delete),
          label: Text('Delete User'),
        ),
        ElevatedButton.icon(
          onPressed: _addNewLocation,
          icon: Icon(Icons.add_location),
          label: Text('Add New Location'),
        ),
        ElevatedButton.icon(
          onPressed: _addNewAdmin,
          icon: Icon(Icons.add),
          label: Text('Add New Admin'),
        ),
        ElevatedButton.icon(
          onPressed: _controlSlotAddition,
          icon: Icon(Icons.settings),
          label: Text('Control Slot Addition'),
        ),
        ElevatedButton.icon(
          onPressed: _chooseReportType, // Call the method to choose report type
          icon: Icon(Icons.description),
          label: Text('Generate Report'),
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Admin Login',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            // You may add more validation rules here if needed
            return null;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            // You may add more validation rules here if needed
            return null;
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loginAsAdmin,
          child: Text('Login'),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: _isAdminLoggedIn
            ? _buildAdminDashboard()
            : Center(
          child: SizedBox(
            width: 300, // Adjust the width as needed
            child: _buildAdminLoginForm(),
          ),
        ),
      ),
    );
  }
}

class VIPReportScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annual VIP Report'), // Change title
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              // Generate the PDF document
              final pdf = pdfLib.Document();
              pdf.addPage(
                pdfLib.Page(
                  build: (context) {
                    return pdfLib.Center(
                      child: pdfLib.Text('Hello World!'),
                    );
                  },
                ),
              );

              // Convert the PDF document to bytes
              final bytes = await pdf.save();

              // Print the PDF document
              Printing.sharePdf(bytes: bytes);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('purchase').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<Map<String, dynamic>> payments = snapshot.data!.docs.map<
                Map<String, dynamic>>((doc) =>
            doc.data() as Map<String,
                dynamic>).toList();
            return _buildDataTable(payments);
          } else {
            return Center(child: Text('No payments found'));
          }
        },
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> payments) {
    double totalAmount = 0;

    // Calculate the total amount
    for (var payment in payments) {
      totalAmount += payment['amount'] ?? 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Report ID: ${_generateReportId()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Date')),
            ],
            rows: [
              // Rows for individual payments
              ...payments.map(
                    (payment) => DataRow(
                  cells: [
                    DataCell(Text(payment['email'])),
                    DataCell(Text(payment['amount'].toString())),
                    DataCell(Text(_formatTimestamp(payment['date']))),
                  ],
                ),
              ),
              // Row for the total amount
              DataRow(
                cells: [
                  DataCell(Text('Total')),
                  DataCell(Text(totalAmount.toString())),
                  DataCell(Text('')), // Empty cell for date
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Format the timestamp into a human-readable date and time string
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
  }

  String _generateReportId() {
    // Generate a random report ID or use some other logic to generate it
    return 'VIP_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class RegularReportScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regular User Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              // Generate the PDF document for regular report
              final pdf = pdfLib.Document();
              pdf.addPage(
                pdfLib.Page(
                  build: (context) {
                    return pdfLib.Center(
                      child: pdfLib.Text('Regular User Report Content'),
                    );
                  },
                ),
              );

              // Convert the PDF document to bytes
              final bytes = await pdf.save();

              // Print the PDF document
              Printing.sharePdf(bytes: bytes);
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('Receipt').get(), // Change the collection name as needed
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<Map<String, dynamic>> payments = snapshot.data!.docs.map<
                Map<String, dynamic>>((doc) =>
            doc.data() as Map<String,
                dynamic>).toList();
            return _buildDataTable(payments);
          } else {
            return Center(child: Text('No payments found'));
          }
        },
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> payments) {
    double totalAmount = 0;

    // Calculate the total amount
    for (var payment in payments) {
      totalAmount += payment['amount_to_pay'] ?? 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Report ID: ${_generateReportId()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Vehicle Number')),
              DataColumn(label: Text('Amount to Pay')),
              DataColumn(label: Text('Date')),
            ],
            rows: [
              // Rows for individual payments
              ...payments.map(
                    (payment) => DataRow(
                  cells: [
                    DataCell(Text(payment['name'] ?? '')),
                    DataCell(Text(payment['vehicle_number'] ?? '')),
                    DataCell(Text(payment['amount_to_pay'].toString())),
                    DataCell(Text(_formatTimestamp(payment['date']))),
                  ],
                ),
              ),
              // Row for the total amount
              DataRow(
                cells: [
                  DataCell(Text('Total')),
                  DataCell(Text('')),
                  DataCell(Text(totalAmount.toString())),
                  DataCell(Text('')), // Empty cell for date
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Format the timestamp into a human-readable date and time string
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
  }

  String _generateReportId() {
    // Generate a random report ID or use some other logic to generate it
    return 'Regular_${DateTime.now().millisecondsSinceEpoch}';
  }
}


  Widget _buildDataTable(List<Map<String, dynamic>> payments) {
    double totalAmount = 0;

    // Calculate the total amount
    for (var payment in payments) {
      totalAmount += payment['amount'] ?? 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Report ID: ${_generateReportId()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Date')),
            ],
            rows: [
              // Rows for individual payments
              ...payments.map(
                    (payment) => DataRow(
                  cells: [
                    DataCell(Text(payment['email'])),
                    DataCell(Text(payment['amount'].toString())),
                    DataCell(Text(_formatTimestamp(payment['date']))),
                  ],
                ),
              ),
              // Row for the total amount
              DataRow(
                cells: [
                  DataCell(Text('Total')),
                  DataCell(Text(totalAmount.toString())),
                  DataCell(Text('')), // Empty cell for date
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Format the timestamp into a human-readable date and time string
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
  }

  String _generateReportId() {
    // Generate a random report ID or use some other logic to generate it
    return 'Regular_${DateTime.now().millisecondsSinceEpoch}';
  }

