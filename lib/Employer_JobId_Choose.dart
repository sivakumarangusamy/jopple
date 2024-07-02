import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jopple/Employer_Menu.dart';
import 'package:jopple/main.dart';
import 'package:jopple/services.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _vibrate() async {
  bool hasVibrator = await Vibration.hasVibrator() ?? false;
  if (hasVibrator) {
    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
  }
}
void _scrollToTop() {
  _scrollController.animateTo(
    0.0,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
    );
  } catch (e) {
    print('Error logging out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out. Please try again.')),
    );
  }
}
FirestoreService firestoreService = FirestoreService();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
ScrollController _scrollController = ScrollController();
String? displayName = current_user_displayName;
final StreamController<void> _Stream_controller = StreamController<void>.broadcast();

String extractBeforeSecondHyphen(String input) {
  List<String> parts = input.split(' - ');
  if (parts.length > 2) {
    return parts.sublist(0, 2).join(' - ');
  } else {
    return input;
  }
}
Stream<List<Map<String, dynamic>>> fetchData() {
  return _firestore.collection('User_Employer').snapshots().map((snapshot) {
    var filteredDocs = snapshot.docs.where((doc) => doc.id.startsWith(extractBeforeSecondHyphen(uid)));
    return filteredDocs.map((doc) => doc.data()).toList();
  });
}
Stream<List<Map<String, dynamic>>> fetchData_secondary() {
  DocumentReference<Map<String, dynamic>> documentRef =
  FirebaseFirestore.instance.collection('User_Employee').doc(uid).withConverter<Map<String, dynamic>>(
    fromFirestore: (snapshot, _) => snapshot.data()!,
    toFirestore: (data, _) => data,
  );
  return documentRef.snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data != null) {
      return [data]; // Return the document data as a list with one element
    } else {
      return []; // Return an empty list if the document does not exist
    }
  });
}
bool checkIds(String id, String fields) {
  firestoreService.initializeUserData_User_Employee();
  Map<String, List<String>> fieldMap = {
    'ApplieduserEmployers': firestoreService.applieduserEmployers,
    'ReceiveduserEmployers': firestoreService.receiveduserEmployers,
    'SaveduserEmployers': firestoreService.saveduserEmployers
  };
  List<String>? fieldList = fieldMap[fields];
  return fieldList?.contains(id) ?? false;
}
List<String> getId(String fields) {
  firestoreService.initializeUserData_User_Employee();
  Map<String, List<String>> fieldMap = {
    'ApplieduserEmployers': firestoreService.applieduserEmployers,
    'ReceiveduserEmployers': firestoreService.receiveduserEmployers,
    'SaveduserEmployers': firestoreService.saveduserEmployers,
  };
  List<String> result = [];
  if (fieldMap.containsKey(fields)) {
    result = fieldMap[fields] ?? [];
  }
  return result;
}

class Employer_JObID_Choose extends StatefulWidget {
  @override
  _Employer_JObID_ChooseState createState() => _Employer_JObID_ChooseState();
}

class _Employer_JObID_ChooseState extends State<Employer_JObID_Choose>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedEmployerCategory = '';
  int _currentPage = 0;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    firestoreService.initializeUserData_User_Employee();
    // Simulate changes in the widget
    Future.delayed(Duration(seconds: 1), () {
      _Stream_controller.add(null);
    });

    // Repeat the change every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _Stream_controller.add(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchData(),
        builder: (context, snapshot) {
          final employerListings = snapshot.data ?? [];
          List<Map<String, dynamic>> filteredEmployerListings = employerListings.where((employer) {
            final matchesSearchQuery = _searchQuery.isEmpty ||
                employer['title']?.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedEmployerCategory.isEmpty ||
                employer['category'] == _selectedEmployerCategory;
            return matchesSearchQuery && matchesCategory;
          }).toList();
          int totalPages = (filteredEmployerListings.length / _itemsPerPage).ceil();
          int startIndex = _currentPage * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;
          List<Map<String, dynamic>> currentEmployers = filteredEmployerListings.sublist(
            startIndex,
            endIndex > filteredEmployerListings.length
                ? filteredEmployerListings.length
                : endIndex,
          );
          if (snapshot.hasError) { print({snapshot.error}); }
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: StreamBuilder<void>(
                stream: _Stream_controller.stream,
                builder: (context, snapshot) {
                  return Scaffold(
                    // key: _scaffoldKey,
                    appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Colors.yellow.shade100,
                      title: GestureDetector(
                        onTap: () async {
                          _vibrate();
                          print(uid);
                        },
                        child: const Text(
                          'Jobs Posted',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'cour',
                              fontSize: 28,
                              color: Colors.teal),
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          /* showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Logout',style: TextStyle(fontWeight: FontWeight.bold)),
                                content: Text('Are you sure you want to logout?'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      _vibrate();
                                      Navigator.of(context).pop(); // Close the dialog
                                      logout(context); // Proceed with the logout
                                    },
                                    child: Text('Yes'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              );
                            },
                          ); */
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    body: Stack(
                      children: [
                        Container(color: Colors.yellow.shade100),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Colors.black, // Border color
                                width: 3.0, // Border width
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top:10.0, left:16.0, right:16.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top:10.0),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        TextField(
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: _searchQuery.isEmpty ? 'Search your posted jobs' : '',
                                            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
                                            // Ensure the label text is not floating when focused
                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value;
                                            });
                                          },
                                        ),
                                        // Optionally, you can add an icon and text inside the TextField
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 12.0),
                                              child: Icon(Icons.search, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _vibrate();
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return MyAlertDialog();
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    color: Colors.red,
                                                  ),
                                                  child: Center(
                                                    child: Text("+ Create new job",
                                                      style: TextStyle(color: Colors.white,
                                                          fontWeight: FontWeight.bold, fontSize: 17,
                                                      fontFamily: 'anta')),
                                                  )),
                                            ),
                                            SizedBox(height: 15),
                                            Column(
                                              children: List.generate(currentEmployers.length, (index) {
                                                final employer = currentEmployers[index];
                                                if (employer['title'] == null) {
                                                  return SizedBox();
                                                }
                                                return Column(
                                                  children: [
                                                      ClipRRect(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                          child: Dismissible(
                                                            key: Key(employer['id'] ?? ''),
                                                            direction: DismissDirection.horizontal,
                                                            confirmDismiss: (direction) async {
                                                              if (direction == DismissDirection.startToEnd) {
                                                                _vibrate();
                                                                return showDialog<bool>(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(height: 20),
                                                                          Text(
                                                                            'Are you sure you want to remove\nthis from the recommended list?',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          SizedBox(height: 20), // Add some space between text and buttons
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.green[500],
                                                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  firestoreService.removeValueFromField_User_Employee(
                                                                                    fieldName: 'ApplieduserEmployers',
                                                                                    valueToRemove: employer['id'] ?? '',
                                                                                  );
                                                                                  Navigator.of(context).pop(true); // Close the dialog and return true
                                                                                  _vibrate();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text(
                                                                                        'Job removed from recommended list',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 16, // Adjust the font size as needed
                                                                                        ),
                                                                                      ),
                                                                                      duration: Duration(seconds: 1),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Yes',
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10), // Add some space between buttons
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.red[500],
                                                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(false); // Close the dialog and return false
                                                                                },
                                                                                child: Text(
                                                                                  'No',
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              else {
                                                                _vibrate();
                                                                return showDialog<bool>(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(height: 20),
                                                                          Text(
                                                                            'Are you sure you want to remove\nthis from the recommended list?',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          SizedBox(height: 20), // Add some space between text and buttons
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.green[500],
                                                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  firestoreService.removeValueFromField_User_Employee(
                                                                                    fieldName: 'ApplieduserEmployers',
                                                                                    valueToRemove: employer['id'] ?? '',
                                                                                  );
                                                                                  Navigator.of(context).pop(true); // Close the dialog and return true
                                                                                  _vibrate();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text(
                                                                                        'Job removed from recommended list',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 16, // Adjust the font size as needed
                                                                                        ),
                                                                                      ),
                                                                                      duration: Duration(seconds: 1),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Yes',
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10), // Add some space between buttons
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.red[500],
                                                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(false); // Close the dialog and return false
                                                                                },
                                                                                child: Text(
                                                                                  'No',
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            background: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.red,
                                                              ),
                                                              alignment: Alignment.centerLeft,
                                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                              child: Icon(Icons.delete, color: Colors.white, size: 35),
                                                            ),
                                                            secondaryBackground: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.red,
                                                              ),
                                                              alignment: Alignment.centerLeft,
                                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                              child: Icon(Icons.delete, color: Colors.white, size: 35),
                                                            ),
                                                            child: Container(
                                                              width: double.infinity,
                                                              decoration: BoxDecoration(
                                                                color: Colors.green[300],
                                                              ),
                                                              child: ListTile(
                                                                title: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  child: Text(
                                                                    "${employer['title']} - ${employer['location']}",
                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                                onTap: () async {
                                                                  _vibrate();
                                                                  String? docId = employer['id'];
                                                                  String? documentName = await firestoreService.getDocumentNameById(docId);
                                                                  print("###############################");
                                                                  print("UID Initital - $uid");
                                                                  print("ID - $docId");
                                                                  setState(() {
                                                                    uid = documentName ?? '';
                                                                  });
                                                                  print("UID Final - $uid");
                                                                  print("###############################");
                                                                  Navigator.of(context).push(MaterialPageRoute(
                                                                    builder: (BuildContext context) {
                                                                    return EmployerMenuPage(); },
                                                                    ));
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    SizedBox(height: 8.0), // Add spacing between items
                                                  ],
                                                );
                                              }),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Container(
                                                height: 50,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: List.generate(totalPages, (index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _vibrate();
                                                          _scrollToTop();
                                                          setState(() {
                                                            _currentPage = index;
                                                          });
                                                        },
                                                        child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: _currentPage == index
                                                              ? Colors.indigo
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    _Stream_controller.close();
    super.dispose();
  }

}

class MyAlertDialog extends StatefulWidget {
  @override
  _MyAlertDialogState createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  TextEditingController _field1Controller = TextEditingController();
  TextEditingController _field2Controller = TextEditingController();
  TextEditingController _field3Controller = TextEditingController();
  bool _isValid = false;

  Future<void> Customized_createNewUserEmployer() async {

    String extractBeforeSecondHyphen(String input) {
      List<String> parts = input.split(' - ');
      if (parts.length > 2) {
        return parts.sublist(0, 2).join(' - ');
      } else {
        return input;
      }
    }
    uid = extractBeforeSecondHyphen(uid);
    print("Creating new user for employer - $uid");
    // Reference to Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Function to generate a unique random id
    Future<String> generateUniqueRandomId() async {
      Random random = Random();
      String id;
      bool idExists;

      do {
        id = random.nextInt(1000000).toString();
        DocumentSnapshot employerIdSnapshot = await firestore
            .collection('Employer_Ids')
            .doc('Employer_ID_List')
            .get();

        if (employerIdSnapshot.exists) {
          var data = employerIdSnapshot.data() as Map<String, dynamic>;
          if (data.containsKey('ids')) {
            List<dynamic> existingIds = data['ids'];
            idExists = existingIds.contains(id);
          } else {
            idExists = false;
          }
        } else {
          idExists = false;
        }
      } while (idExists);

      return id;
    }

    // Generate a unique random id
    String id = await generateUniqueRandomId();
    String Doc = "$uid - $id";

    // Reference to the document
    DocumentReference docRef = firestore.collection('User_Employer').doc(Doc);

    try {
      // Check if the document already exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('Document with name $uid already exists.');
        return; // Abort the function
      }

      Map<String, List<dynamic>> data = {
        "ApplieduserEmployees": [],
        "SaveduserEmployees": [],
        "ReceiveduserEmployees": [],
        "RemoveduserEmployees": [],
        "hire_state": []
      };

      bool documentExist = false;
      Map<String, dynamic> documentExistField = {"DocumentExist": documentExist};

      bool fetchValid = false;
      Map<String, dynamic> fetchValidField = {"FetchValid": fetchValid};

      String title = _field1Controller.text;
      String company = _field2Controller.text;
      String location = _field3Controller.text;

      Map<String, dynamic> titleField = {"title": title};
      Map<String, dynamic> companyField = {"name": company};
      Map<String, dynamic> locationField = {"location": location};

      Map<String, dynamic> idField = {"id": id};

      // Merge all data
      Map<String, dynamic> mergedData = {...data, ...documentExistField, ...fetchValidField, ...idField,
        ...titleField, ...companyField, ...locationField};

      // Set the document with the merged data
      await docRef.set(mergedData);

      uid = Doc;

      // Update ID's
      Future<void> updateEmployeeIds() async {
        // Reference to the collections and documents
        final CollectionReference userEmployeeCollection = FirebaseFirestore.instance.collection('User_Employee');
        final DocumentReference employeeIdListDoc = FirebaseFirestore.instance.collection('Employee_Ids').doc('Employee_ID_List');

        // Fetch all documents from User_Employee collection
        final QuerySnapshot userEmployeeSnapshot = await userEmployeeCollection.get();

        // Extract all unique id values from User_Employee documents
        Set<String> uniqueIds = userEmployeeSnapshot.docs.map((doc) => doc.get('id') as String).toSet();

        // Update Employee_ID_List document in Employee_Ids collection
        await employeeIdListDoc.set({
          'ids': uniqueIds.toList(), // Convert Set to List to store in Firestore
        });

        // Log that the operation is completed
        print('Employee IDs updated successfully.');
      }
      await updateEmployeeIds();
      Future<void> updateEmployerIds() async {
        // Reference to the collections and documents
        final CollectionReference userEmployerCollection = FirebaseFirestore.instance.collection('User_Employer');
        final DocumentReference employerIdListDoc = FirebaseFirestore.instance.collection('Employer_Ids').doc('Employer_ID_List');

        // Fetch all documents from User_Employer collection
        final QuerySnapshot userEmployerSnapshot = await userEmployerCollection.get();

        // Extract all unique id values from User_Employer documents
        Set<String> uniqueIds = userEmployerSnapshot.docs.map((doc) => doc.get('id') as String).toSet();

        // Update Employer_ID_List document in Employer_Ids collection
        await employerIdListDoc.set({
          'ids': uniqueIds.toList(), // Convert Set to List to store in Firestore
        });

        // Log that the operation is completed
        print('Employer IDs updated successfully.');
      }
      await updateEmployerIds();
      print('Document $uid created successfully with userEmployees and unique id $id.');
    } catch (e) {
      print('Failed to create document or fetch Employees IDs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Validate fields initially
    _validateFields();
  }

  void _validateFields() {
    setState(() {
      _isValid = _field1Controller.text.isNotEmpty &&
          _field2Controller.text.isNotEmpty &&
          _field3Controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      title: Text(
        'New Job Creation',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
          color: Colors.blueAccent,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _field1Controller,
              onChanged: (value) {
                _validateFields();
              },
              decoration: InputDecoration(
                labelText: 'Job Title',
                hintText: 'Enter the job you are hiring for',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _field2Controller,
              onChanged: (value) {
                _validateFields();
              },
              decoration: InputDecoration(
                labelText: 'Organization Name',
                hintText: 'Enter your organization name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _field3Controller,
              onChanged: (value) {
                _validateFields();
              },
              decoration: InputDecoration(
                labelText: 'Job Location',
                hintText: 'Enter the location-city of the job',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: _isValid
                  ? () {
                // Handle form submission
                String value1 = _field1Controller.text;
                String value2 = _field2Controller.text;
                String value3 = _field3Controller.text;

                print('Title: $value1');
                print('Company: $value2');
                print('Location: $value3');

                Customized_createNewUserEmployer();

                Navigator.of(context).pop(); // Close the dialog
              }
                  : null,
              child: Text(
                'Submit',
                style: TextStyle(
                  color: _isValid ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}