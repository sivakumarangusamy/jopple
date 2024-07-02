import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jopple/job%20infopage.dart';
import 'package:jopple/main.dart';
import 'package:jopple/profile_view_2.dart';
import 'package:jopple/services.dart';
import 'package:vibration/vibration.dart';
import 'Employer_JobId_Choose.dart';
import 'candidate infopage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
final List<String> statuses = ["APPLIED", "PENDING", "CONFIRM", "FINISH"];

/* Stream<List<Map<String, dynamic>>> fetchData() {
  return CombineLatestStream.combine2(
    firestoreService.getAllStream_Employee(),
    firestoreService.getAllStream_Employee_additional(),
        (List<Map<String, dynamic>> stream1Data, List<Map<String, dynamic>> stream2Data) {
      // Combine the data from both streams
      // You can merge, concatenate, or perform any other operation you need on the data
      return [...stream1Data, ...stream2Data];
    },
  );
} */

Stream<List<Map<String, dynamic>>> fetchData() {
  return _firestore.collection('User_Employee').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

Stream<List<Map<String, dynamic>>> fetchData_secondary() {
  DocumentReference<Map<String, dynamic>> documentRef =
  FirebaseFirestore.instance.collection('User_Employer').doc(uid).withConverter<Map<String, dynamic>>(
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
  firestoreService.initializeUserData_User_Employer();
  Map<String, List<String>> fieldMap = {
    'ApplieduserEmployees': firestoreService.applieduserEmployees,
    'ReceiveduserEmployees': firestoreService.receiveduserEmployees,
    'SaveduserEmployees': firestoreService.saveduserEmployees,
    'hire_state': firestoreService.hire_state_list
  };
  List<String>? fieldList = fieldMap[fields];
  return fieldList?.contains(id) ?? false;
}

List<String> getId(String fields) {
  firestoreService.initializeUserData_User_Employer();
  Map<String, List<String>> fieldMap = {
    'ApplieduserEmployees': firestoreService.applieduserEmployees,
    'ReceiveduserEmployees': firestoreService.receiveduserEmployees,
    'SaveduserEmployees': firestoreService.saveduserEmployees,
    'hire_state': firestoreService.hire_state_list
  };
  List<String> result = [];
  if (fieldMap.containsKey(fields)) {
    result = fieldMap[fields] ?? [];
  }
  return result;
}

class EmployerMenuPage extends StatefulWidget {

  @override
  _EmployerMenuPageState createState() => _EmployerMenuPageState();
}

class _EmployerMenuPageState extends State<EmployerMenuPage> {
  String _searchQuery = '';
  int _currentPage = 0;
  int _itemsPerPage = 10;
  List<String> candid_cat = [];
  List<String> _selectedEmployeeCategory = [];
  List<String> selectedItems = [];
  int selectedCount = 0;

  Future<void> fetchCandidCategories() async {
    candid_cat = (await FirebaseFirestore.instance.collection('Employee_Ids').doc('Employee_Title_List')
        .get()).data()?['titles'].cast<String>() ?? []; }

  @override
  void initState() {
    super.initState();
    fetchCandidCategories();
    firestoreService.initializeUserData_User_Employer();
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
          final employeeListings = snapshot.data ?? [];
          List<Map<String, dynamic>> filteredEmployeeListings = employeeListings.where((employee) {
            final matchesSearchQuery = _searchQuery.isEmpty ||
                employee['title']?.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedEmployeeCategory.contains(employee['title']) || _selectedEmployeeCategory.isEmpty;
            return matchesSearchQuery && matchesCategory;
          }).toList();
          int totalPages = (filteredEmployeeListings.length / _itemsPerPage).ceil();
          int startIndex = _currentPage * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;
          List<Map<String, dynamic>> currentEmployees = filteredEmployeeListings.sublist(
            startIndex,
            endIndex > filteredEmployeeListings.length
                ? filteredEmployeeListings.length
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
                          print(candid_cat);
                        },
                        child: const Text(
                          'Menu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'cour',
                              fontSize: 28,
                              color: Colors.teal),
                        ),
                      ),
                      leading: Builder(
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: IconButton(
                                iconSize: 40,
                                color: Colors.indigo,
                                icon: Icon(Icons.menu),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                  // _scaffoldKey.currentState.openDrawer();
                                },
                              ),
                            );
                          }
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: IconButton(
                            color: Colors.indigo,
                            iconSize: 40,
                            icon: Icon(Icons.account_circle_rounded),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return JobInfo();
                                  }));
                            },
                          ),
                        ),
                      ],
                    ),
                    drawer: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.74,
                      child: Drawer(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.142,
                              child: DrawerHeader(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                ),
                                child: Text(
                                  '$current_user_displayName',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.account_circle),
                              title: Text('Profile'),
                              onTap: () {
                                // Navigate to home screen or perform any action
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return Profile_Viewer_2();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.account_tree),
                              title: Text('Login with different Job'),
                              onTap: () {
                                // Navigate to home screen or perform any action
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return Employer_JObID_Choose();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.done_outline_rounded),
                              title: Text('Candidates Applied'),
                              onTap: () {
                                // Navigate to about screen or perform any action
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return ReceivedCandidates();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.star),
                              title: Text('Saved Candidates'),
                              onTap: () {
                                // Navigate to about screen or perform any action
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return SavedCandidates();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.add_task_sharp),
                              title: Text('Selected Candidates'),
                              onTap: () {
                                // Navigate to about screen or perform any action
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return AppliedCandidates();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.info),
                              title: Text('About'),
                              onTap: () {
                                // Navigate to about screen or perform any action
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return InfoPage();
                                    }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Settings'),
                              onTap: () {
                                // Navigate to settings screen or perform any action
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Logout'),
                              onTap: () {
                                _vibrate();
                                logout(context);
                              },
                            ),
                          ],
                        ),
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
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: ' Search for candidates',
                                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: fetchData_secondary(),
                                    builder: (context, snapshot) {
                                      Map<String,
                                          dynamic>? data = snapshot
                                          .data?.first;
                                      return Expanded(
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton2<
                                                          String>(
                                                        isExpanded: true,
                                                        hint: Row(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                              child: Text(
                                                                selectedCount >
                                                                    0
                                                                    ? "Filtered - ${selectedCount
                                                                    .toString()}"
                                                                    : 'Select categories',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: selectedCount >
                                                                      0
                                                                      ? Colors
                                                                      .black
                                                                      : Theme
                                                                      .of(
                                                                      context)
                                                                      .hintColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        items: candid_cat.map((
                                                            item) {
                                                          return DropdownMenuItem(
                                                            value: item,
                                                            enabled: true,
                                                            child: StatefulBuilder(
                                                              builder: (context,
                                                                  menuSetState) {
                                                                final isSelected = selectedItems
                                                                    .contains(
                                                                    item);
                                                                return InkWell(
                                                                  onTap: () {
                                                                    isSelected
                                                                        ? selectedItems
                                                                        .remove(
                                                                        item)
                                                                        : selectedItems
                                                                        .add(
                                                                        item);
                                                                    setState(() {
                                                                      _selectedEmployeeCategory =
                                                                          selectedItems;
                                                                      selectedCount =
                                                                          selectedItems
                                                                              .length; // Update selected count
                                                                    });
                                                                    menuSetState(() {});
                                                                  },
                                                                  child: Container(
                                                                    height: double
                                                                        .infinity,
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 16.0),
                                                                    child: Row(
                                                                      children: [
                                                                        if (isSelected)
                                                                          const Icon(
                                                                              Icons
                                                                                  .check_box_outlined)
                                                                        else
                                                                          const Icon(
                                                                              Icons
                                                                                  .check_box_outline_blank),
                                                                        const SizedBox(
                                                                            width: 16),
                                                                        Expanded(
                                                                          child: Text(
                                                                            item,
                                                                            style: const TextStyle(
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedEmployeeCategory =
                                                                selectedItems;
                                                            selectedCount =
                                                                selectedItems
                                                                    .length; // Update selected count
                                                          });
                                                        },
                                                        buttonStyleData: ButtonStyleData(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey,
                                                                width: 2),
                                                            // Border color
                                                            borderRadius: BorderRadius
                                                                .circular(
                                                                8.0), // Border radius
                                                          ),
                                                          height: 50,
                                                          width: 150,
                                                        ),
                                                        menuItemStyleData: MenuItemStyleData(
                                                          height: 40,
                                                          padding: EdgeInsets
                                                              .zero,
                                                        ),
                                                        dropdownStyleData: DropdownStyleData(
                                                          width: width * 0.85,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(8.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15.0),
                                                Row(
                                                  children: [
                                                    Text(" Logged in for : ",
                                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                                    Flexible(
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(" ${data?['title']} - ${data?['location']}",
                                                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15.0),
                                                Column(
                                                  children:
                                                  List.generate(
                                                      currentEmployees.length, (
                                                      index) {
                                                    final employee = currentEmployees[index];
                                                    if (employee['title'] ==
                                                        null) {
                                                      return SizedBox(); // Skip generating UI for null jobs
                                                    }
                                                    if (employee['title'] ==
                                                        "*") {
                                                      return SizedBox(); // Skip generating UI for null jobs
                                                    }
                                                    if (employee['title'] ==
                                                        "*") {
                                                      return SizedBox(); // Skip generating UI for null jobs
                                                    }
                                                    /* if (employee['FetchValid'] ==
                                                          false) {
                                                        return SizedBox(); // Skip generating UI for null jobs
                                                      } */
                                                    if ((data != null &&
                                                        data['RemoveduserEmployees'] !=
                                                            null &&
                                                        data['RemoveduserEmployees'] is List &&
                                                        data['RemoveduserEmployees']
                                                            .contains(
                                                            employee['id']))) {
                                                      return SizedBox();
                                                    }
                                                    return Column(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius
                                                              .circular(10.0),
                                                          child: Dismissible(
                                                            key: Key(
                                                                employee['id'] ??
                                                                    ''),
                                                            direction: DismissDirection
                                                                .horizontal,
                                                            confirmDismiss: (
                                                                direction) async {
                                                              if (direction ==
                                                                  DismissDirection
                                                                      .startToEnd) {
                                                                _vibrate();
                                                                return showDialog<
                                                                    bool>(
                                                                  context: context,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize
                                                                            .min,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 20),
                                                                          Text(
                                                                            'Are you sure you want to remove\nthis from the recommended list?',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight
                                                                                    .bold),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 20),
                                                                          // Add some space between text and buttons
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment
                                                                                .center,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton
                                                                                    .styleFrom(
                                                                                  backgroundColor: Colors
                                                                                      .green[500],
                                                                                  padding: EdgeInsets
                                                                                      .symmetric(
                                                                                      horizontal: 30,
                                                                                      vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius
                                                                                        .circular(
                                                                                        10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  firestoreService
                                                                                      .adppendValueToField_User_Employer(
                                                                                    fieldName: 'RemoveduserEmployees',
                                                                                    newValue: employee['id'] ??
                                                                                        '',
                                                                                  );
                                                                                  firestoreService
                                                                                      .removeValueFromField_User_Employer(
                                                                                    fieldName: 'ApplieduserEmployees',
                                                                                    valueToRemove: employee['id'] ??
                                                                                        '',
                                                                                  );
                                                                                  firestoreService
                                                                                      .removeValueFromField_User_Employer(
                                                                                    fieldName: 'SaveduserEmployees',
                                                                                    valueToRemove: employee['id'] ??
                                                                                        '',
                                                                                  );
                                                                                  firestoreService
                                                                                      .removeValueFromField_User_Employer(
                                                                                    fieldName: 'hire_state',
                                                                                    valueToRemove: "${employee['id']} - Offer declined",
                                                                                  );
                                                                                  for (String status in statuses) {
                                                                                    firestoreService
                                                                                        .removeValueFromField_User_Employer(
                                                                                      fieldName: 'hire_state',
                                                                                      valueToRemove: "${employee['id']} - ${status}",
                                                                                    );
                                                                                  }
                                                                                  firestoreService
                                                                                      .deleteValueFromField_Opposite_to_User_Employee(
                                                                                    id: employee['id'],
                                                                                    fieldName: 'ReceiveduserEmployers',
                                                                                    valueToRemove: data?['id'] ??
                                                                                        '',
                                                                                  );
                                                                                  Navigator
                                                                                      .of(
                                                                                      context)
                                                                                      .pop(
                                                                                      true); // Close the dialog and return true
                                                                                  _vibrate();
                                                                                  ScaffoldMessenger
                                                                                      .of(
                                                                                      context)
                                                                                      .showSnackBar(
                                                                                    SnackBar(
                                                                                      content: Text(
                                                                                        'Candidate removed from recommended list',
                                                                                        textAlign: TextAlign
                                                                                            .center,
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight
                                                                                              .bold,
                                                                                          fontSize: 16, // Adjust the font size as needed
                                                                                        ),
                                                                                      ),
                                                                                      duration: Duration(
                                                                                          seconds: 1),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Yes',
                                                                                  style: TextStyle(
                                                                                      color: Colors
                                                                                          .white,
                                                                                      fontWeight: FontWeight
                                                                                          .bold),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                  width: 10),
                                                                              // Add some space between buttons
                                                                              ElevatedButton(
                                                                                style: ElevatedButton
                                                                                    .styleFrom(
                                                                                  backgroundColor: Colors
                                                                                      .red[500],
                                                                                  padding: EdgeInsets
                                                                                      .symmetric(
                                                                                      horizontal: 30,
                                                                                      vertical: 12),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius
                                                                                        .circular(
                                                                                        10),
                                                                                  ),
                                                                                ),
                                                                                onPressed: () {
                                                                                  Navigator
                                                                                      .of(
                                                                                      context)
                                                                                      .pop(
                                                                                      false); // Close the dialog and return false
                                                                                },
                                                                                child: Text(
                                                                                  'No',
                                                                                  style: TextStyle(
                                                                                      color: Colors
                                                                                          .white,
                                                                                      fontWeight: FontWeight
                                                                                          .bold),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                _vibrate();
                                                                if (data?['SaveduserEmployees']
                                                                    ?.contains(
                                                                    employee['id']) ??
                                                                    false) {
                                                                  firestoreService
                                                                      .removeValueFromField_User_Employer(
                                                                    fieldName: 'SaveduserEmployees',
                                                                    valueToRemove: employee['id'] ??
                                                                        '',
                                                                  );
                                                                } else {
                                                                  firestoreService
                                                                      .adppendValueToField_User_Employer(
                                                                    fieldName: 'SaveduserEmployees',
                                                                    newValue: employee['id'] ??
                                                                        '',
                                                                  );
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                            onDismissed: (
                                                                direction) {
                                                              // firestoreService.deleteDocumentByFieldValue(fieldName: 'id',fieldValue: job['id']);
                                                            },
                                                            background: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .red,
                                                              ),
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 16.0),
                                                              child: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 35),
                                                            ),
                                                            secondaryBackground: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 16.0),
                                                              child: data?['SaveduserEmployees']
                                                                  ?.contains(
                                                                  employee['id']) ??
                                                                  false
                                                                  ? Icon(Icons
                                                                  .bookmark,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 35)
                                                                  : Icon(Icons
                                                                  .bookmark_outline,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 35),
                                                            ),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .teal[200],
                                                              ),
                                                              child: ListTile(
                                                                title: FittedBox(
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  child: Text(
                                                                    employee['title'] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold),
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                subtitle: FittedBox(
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  child: Text(
                                                                    '${employee['name']} - ${employee['location']}',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.of(
                                                                      context)
                                                                      .push(
                                                                      MaterialPageRoute(
                                                                        builder: (
                                                                            BuildContext context) {
                                                                          return CandidateDescription(
                                                                              candidate: employee);
                                                                        },
                                                                      ));
                                                                },
                                                                trailing: ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                      backgroundColor: data?['hire_state']
                                                                          ?.contains(
                                                                          "${employee['id']} - Offer declined") ??
                                                                          false
                                                                          ? Colors
                                                                          .grey
                                                                          : data?['ApplieduserEmployees']
                                                                          ?.contains(
                                                                          employee['id']) ??
                                                                          false
                                                                          ? Colors
                                                                          .green
                                                                          : Colors
                                                                          .red),
                                                                  onPressed: () async {
                                                                    _vibrate();
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (
                                                                          BuildContext context) {
                                                                        return AlertDialog(
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize
                                                                                .min,
                                                                            children: [
                                                                              SizedBox(
                                                                                  height: 20),
                                                                              Text(
                                                                                data?['hire_state']
                                                                                    ?.contains(
                                                                                    "${employee['id']} - Offer declined")
                                                                                    ?
                                                                                'Are you sure you want to\rremove this Candidate'
                                                                                    : data?['ApplieduserEmployees']
                                                                                    ?.contains(
                                                                                    employee['id']) ??
                                                                                    false
                                                                                    ? 'Are you sure you want to\nwithdraw this Candidate?'
                                                                                    : 'Are you sure you want to\napply for this Candidate?',
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight
                                                                                        .bold),
                                                                                textAlign: TextAlign
                                                                                    .center,
                                                                              ),
                                                                              SizedBox(
                                                                                  height: 20),
                                                                              // Add some space between text and buttons
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                    .center,
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton
                                                                                        .styleFrom(
                                                                                      backgroundColor: Colors
                                                                                          .green[500],
                                                                                      padding: EdgeInsets
                                                                                          .symmetric(
                                                                                          horizontal: 30,
                                                                                          vertical: 12),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                            10),
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      if (data?['ApplieduserEmployees']
                                                                                          ?.contains(
                                                                                          employee['id']) ??
                                                                                          false) {
                                                                                        if (data?['hire_state']
                                                                                            ?.contains(
                                                                                            "${employee['id']} - Offer declined")) {
                                                                                          firestoreService
                                                                                              .adppendValueToField_User_Employer(
                                                                                            fieldName: 'RemoveduserEmployees',
                                                                                            newValue: employee['id'] ??
                                                                                                '',
                                                                                          );
                                                                                        }
                                                                                        firestoreService
                                                                                            .removeValueFromField_User_Employer(
                                                                                          fieldName: 'ApplieduserEmployees',
                                                                                          valueToRemove: employee['id'] ??
                                                                                              '',
                                                                                        );
                                                                                        for (String status in statuses) {
                                                                                          firestoreService
                                                                                              .removeValueFromField_User_Employer(
                                                                                            fieldName: 'hire_state',
                                                                                            valueToRemove: "${employee['id']} - ${status}",
                                                                                          );
                                                                                        }
                                                                                        firestoreService
                                                                                            .removeValueFromField_User_Employer(
                                                                                          fieldName: 'hire_state',
                                                                                          valueToRemove: "${employee['id']} - Offer declined",
                                                                                        );
                                                                                        firestoreService
                                                                                            .deleteValueFromField_Opposite_to_User_Employee(
                                                                                            id: employee['id'] ??
                                                                                                '',
                                                                                            fieldName: 'ReceiveduserEmployers',
                                                                                            valueToRemove: data?['id'] ??
                                                                                                ''
                                                                                        );
                                                                                      } else {
                                                                                        firestoreService
                                                                                            .adppendValueToField_User_Employer(
                                                                                          fieldName: 'ApplieduserEmployees',
                                                                                          newValue: employee['id'] ??
                                                                                              '',
                                                                                        );
                                                                                        firestoreService
                                                                                            .adppendValueToField_User_Employer(
                                                                                          fieldName: 'hire_state',
                                                                                          newValue: "${employee['id']} - ${statuses[0]}",
                                                                                        );
                                                                                        firestoreService
                                                                                            .appendValueToField_Opposite_to_User_Employee(
                                                                                            id: employee['id'] ??
                                                                                                '',
                                                                                            fieldName: 'ReceiveduserEmployers',
                                                                                            newValue: data?['id'] ??
                                                                                                ''
                                                                                        );
                                                                                      }
                                                                                      Navigator
                                                                                          .of(
                                                                                          context)
                                                                                          .pop(
                                                                                          true); // Close the dialog and return true
                                                                                      _vibrate();
                                                                                      ScaffoldMessenger
                                                                                          .of(
                                                                                          context)
                                                                                          .showSnackBar(
                                                                                        SnackBar(
                                                                                          content: Text(
                                                                                            data?['hire_state']
                                                                                                ?.contains(
                                                                                                "${employee['id']} - Offer declined")
                                                                                                ?
                                                                                            'Candidate removed from suggestion'
                                                                                                : data?['ApplieduserEmployees']
                                                                                                ?.contains(
                                                                                                employee['id']) ??
                                                                                                false
                                                                                                ? 'Candidate withdrawn successfully.'
                                                                                                : 'Candidate elected successfully.',
                                                                                            textAlign: TextAlign
                                                                                                .center,
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight
                                                                                                  .bold,
                                                                                              fontSize: 16, // Adjust the font size as needed
                                                                                            ),
                                                                                          ),
                                                                                          duration: Duration(
                                                                                              seconds: 1),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    child: Text(
                                                                                      'Yes',
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .white,
                                                                                          fontWeight: FontWeight
                                                                                              .bold),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                      width: 10),
                                                                                  // Add some space between buttons
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton
                                                                                        .styleFrom(
                                                                                      backgroundColor: Colors
                                                                                          .red[500],
                                                                                      padding: EdgeInsets
                                                                                          .symmetric(
                                                                                          horizontal: 30,
                                                                                          vertical: 12),
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                            10),
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      Navigator
                                                                                          .of(
                                                                                          context)
                                                                                          .pop(
                                                                                          false); // Close the dialog and return false
                                                                                    },
                                                                                    child: Text(
                                                                                      'No',
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .white,
                                                                                          fontWeight: FontWeight
                                                                                              .bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    width: 50,
                                                                    child: FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      child: Text(
                                                                        maxLines: 1,
                                                                        data?['hire_state']
                                                                            ?.contains(
                                                                            "${employee['id']} - Offer declined")
                                                                            ? 'Declined'
                                                                            : data?['ApplieduserEmployees']
                                                                            ?.contains(
                                                                            employee['id'])
                                                                            ? 'Elected'
                                                                            : 'Elect',
                                                                        textAlign: TextAlign
                                                                            .center,
                                                                        style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        // Add spacing between items
                                                      ],
                                                    );
                                                  }),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Container(
                                                    height: 50,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .center,
                                                      children: List.generate(
                                                          totalPages, (index) {
                                                        return Padding(
                                                          padding: const EdgeInsets
                                                              .all(5.0),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _vibrate();
                                                              _scrollToTop();
                                                              setState(() {
                                                                _currentPage =
                                                                    index;
                                                              });
                                                            },
                                                            child: Text(
                                                                '${index + 1}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              backgroundColor: _currentPage ==
                                                                  index
                                                                  ? Colors
                                                                  .indigo
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
                                      );
                                    }
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

class SavedCandidates extends StatefulWidget {
  @override
  _SavedCandidatesState createState() => _SavedCandidatesState();
}

class _SavedCandidatesState extends State<SavedCandidates> {
  @override
  void initState() {
    super.initState();
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
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          print({snapshot.error});
        }
        final employeeListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
              Map<String, dynamic>? data = snapshot.data?.first;
              List<Map<String, dynamic>> savedEmployees = employeeListings.where((employee) =>
              data?['SaveduserEmployees']?.contains(employee['id']) ?? false).toList();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {
                      print(data?['location']);
                    },
                    child: const Text(
                      'Saved List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cour',
                        fontSize: 24,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                body: savedEmployees.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: width,
                      child: Text(
                        'Saved candidates list is empty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: savedEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = savedEmployees[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          color: Colors.teal[200],
                          child: ListTile(
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                employee['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ),
                            subtitle: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${employee['name'] ?? ''} - ${employee['location'] ?? ''}',
                                maxLines: 2,
                              ),
                            ),
                            onTap: () {
                              /* Navigator.of(context).push(MaterialPageRoute(
                               builder: (BuildContext context) {
                               return Need to build this -> CandidateDescription(job: employee); // Pass the job object here
                               },
                              )); */
                            },
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              onPressed: () async {
                                _vibrate();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'Are you sure you want to remove this from the saved list?',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20), // Add some space between text and buttons
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green[500],
                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Close the dialog and return true
                                                  _vibrate();
                                                  firestoreService.removeValueFromField_User_Employer(
                                                    fieldName: 'SaveduserEmployees',
                                                    valueToRemove: employee['id'] ?? '',
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Candidate removed from Saved list',
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              },
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _Stream_controller.close();
    super.dispose();
  }
}

class AppliedCandidates extends StatefulWidget {
  @override
  _AppliedCandidatesState createState() => _AppliedCandidatesState();
}

class _AppliedCandidatesState extends State<AppliedCandidates> {
  @override
  void initState() {
    super.initState();
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
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          print({snapshot.error});
        }
        final employeeListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
              Map<String, dynamic>? data = snapshot.data?.first;
              List<Map<String, dynamic>> appliedEmployees = employeeListings.where((employee) =>
              data?['ApplieduserEmployees']?.contains(employee['id']) ?? false).toList();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {
                      print(data?['location']);
                    },
                    child: const Text(
                      'Selected List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cour',
                        fontSize: 22,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                body: appliedEmployees.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: width,
                      child: Text(
                        'Selected candidates list is empty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: appliedEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = appliedEmployees[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          color: Colors.teal[200],
                          child: ListTile(
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                employee['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ),
                            subtitle: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${employee['name'] ?? ''} - ${employee['location'] ?? ''}',
                                maxLines: 2,
                              ),
                            ),
                            onTap: () {
                              /* Navigator.of(context).push(MaterialPageRoute(
                               builder: (BuildContext context) {
                               return Need to build this -> CandidateDescription(job: employee); // Pass the job object here
                               },
                              )); */
                            },
                            /* trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              onPressed: () async {
                                _vibrate();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'Are you sure you want to remove this from the applied list?',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20), // Add some space between text and buttons
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green[500],
                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Close the dialog and return true
                                                  _vibrate();
                                                  firestoreService.removeValueFromField_User_Employer(
                                                    fieldName: 'ApplieduserEmployees',
                                                    valueToRemove: employee['id'] ?? '',
                                                  );
                                                  for (String status in statuses) {
                                                    firestoreService.removeValueFromField_User_Employer(
                                                      fieldName: 'hire_state',
                                                      valueToRemove: "${employee['id']} - ${status}",
                                                    );
                                                  }
                                                  firestoreService.removeValueFromField_User_Employer(
                                                    fieldName: 'hire_state',
                                                    valueToRemove: "${employee['id']} - Offer declined",
                                                  );
                                                  firestoreService.deleteValueFromField_Opposite_to_User_Employee(
                                                      id: employee['id'] ?? '',
                                                      fieldName: 'ReceiveduserEmployers',
                                                      valueToRemove: data?['id']
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Candidate removed from Applied list',
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ), */
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _Stream_controller.close();
    super.dispose();
  }
}

class ReceivedCandidates extends StatefulWidget {
  @override
  _ReceivedCandidatesState createState() => _ReceivedCandidatesState();
}

class _ReceivedCandidatesState extends State<ReceivedCandidates> {
  @override
  void initState() {
    super.initState();
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
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          print({snapshot.error});
        }
        final employeeListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
              Map<String, dynamic>? data = snapshot.data?.first;
              List<Map<String, dynamic>> appliedEmployees = employeeListings.where((employee) =>
              data?['ReceiveduserEmployees']?.contains(employee['id']) ?? false).toList();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Applied List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cour',
                        fontSize: 22,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                body: appliedEmployees.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: width,
                      child: Text(
                        'Candidates applied list is empty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: appliedEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = appliedEmployees[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          color: Colors.teal[200],
                          child: ListTile(
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                employee['title'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ),
                            subtitle: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${employee['name'] ?? ''} - ${employee['location'] ?? ''}',
                                maxLines: 2,
                              ),
                            ),
                            onTap: () {
                              /* Navigator.of(context).push(MaterialPageRoute(
                               builder: (BuildContext context) {
                               return Need to build this -> CandidateDescription(job: employee); // Pass the job object here
                               },
                              )); */
                            },
                            /* trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              onPressed: () async {
                                _vibrate();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'Are you sure you want to decline this candidate acceptance?',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 20), // Add some space between text and buttons
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green[500],
                                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // Close the dialog and return true
                                                  _vibrate();
                                                  firestoreService.removeValueFromField_User_Employer(
                                                    fieldName: 'ReceiveduserEmployees',
                                                    valueToRemove: employee['id'] ?? '',
                                                  );
                                                  for (String status in statuses) {
                                                    firestoreService.deleteValueFromField_Opposite_to_User_Employee(
                                                        id: employee['id'] ?? '',
                                                        fieldName: 'job_state',
                                                        valueToRemove: "${data?['id']} - ${status}"
                                                    );
                                                  }
                                                  firestoreService.appendValueToField_Opposite_to_User_Employee(
                                                      id: employee['id'] ?? '',
                                                      fieldName: 'job_state',
                                                      newValue: "${data?['id']} - Job rejected"
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Declined the candidate acceptance',
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              },
                              child: const Text(
                                'Decline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ), */
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _Stream_controller.close();
    super.dispose();
  }
}

class CandidateDescription extends StatefulWidget {
  final Map<String, dynamic> candidate; // Define a field to store the job object
  CandidateDescription({required this.candidate}); // Constructor to receive the job object

  @override
  _CandidateDescriptionState createState() => _CandidateDescriptionState();
}

class _CandidateDescriptionState extends State<CandidateDescription> {
  final List<String> statusess = [
    "APPLIED",
    "PENDING",
    "CONFIRM",
    "  FINISH  "
  ];

  @override
  void initState() {
    super.initState();

    // Simulate changes in the widget
    Future.delayed(Duration(seconds: 1), () {
      _Stream_controller.add(null);
    });

    // Repeat the change every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _Stream_controller.add(null);
    });
  }

  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting)
          { print({snapshot.error}); }
          // final jobListings = snapshot.data;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchData_secondary(),
                builder: (context, snapshot) {
                  Map<String, dynamic>? data = snapshot.data?.first;
                  int findStatus(String input) {
                    List<dynamic>? statusList = data?['hire_state'];
                    for (String status in statusList ?? []) {
                      if (status.startsWith(input.trim() + " -")) {
                        List<String> parts = status.split("-");
                        if (parts.length > 1) {
                          String trimmedStatus = parts[1].trim();
                          switch (trimmedStatus) {
                            case "APPLIED":
                              return 1;
                            case 'PENDING':
                              return 2;
                            case 'CONFIRM':
                              return 3;
                            case 'FINISH':
                              return 4;
                            default:
                              return 0;
                          }
                        }
                      }
                    }
                    return 0;
                  }
                  int currentStatus = findStatus(widget.candidate['id']);
                  return Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: GestureDetector(
                        onTap: () {
                          _vibrate();
                          print(getId('hire_state'));
                          print(findStatus(widget.candidate['id']));
                        },
                        child: const Text(
                          'Description',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'cour',
                              fontSize: 28,
                              color: Colors.teal),
                        ),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: IconButton(
                          iconSize: 30,
                          color: Colors.black,
                          icon: Icon(Icons.arrow_back_outlined),
                          onPressed: () {
                            _vibrate();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: IconButton(
                            color: Colors.indigo,
                            iconSize: 40,
                            icon: Icon(Icons.account_circle_rounded),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return JobInfo();
                                  }));
                            },
                          ),
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 10, top: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Add your submit functionality here
                                        _vibrate();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(height: 20),
                                                  Text(
                                                    checkIds(widget.candidate['id'],'ApplieduserEmployees') ?
                                                    'Are you sure you want to\nwithdraw this candidate?'
                                                        :
                                                    'Are you sure you want to\napply for this candidate?',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 20),
                                                  // Add some space between text and buttons
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor: Colors
                                                              .green[500],
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal: 30,
                                                              vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(10),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          if (data?['ApplieduserEmployees']
                                                              ?.contains(
                                                              widget.candidate['id']) ??
                                                              false) {
                                                            if (data?['hire_state']
                                                                ?.contains(
                                                                "${widget.candidate['id']} - Offer declined")) {
                                                              firestoreService
                                                                  .adppendValueToField_User_Employer(
                                                                fieldName: 'RemoveduserEmployees',
                                                                newValue: widget.candidate['id'] ??
                                                                    '',
                                                              );
                                                            }
                                                            firestoreService
                                                                .removeValueFromField_User_Employer(
                                                              fieldName: 'ApplieduserEmployees',
                                                              valueToRemove: widget.candidate['id'] ??
                                                                  '',
                                                            );
                                                            for (String status in statuses) {
                                                              firestoreService
                                                                  .removeValueFromField_User_Employer(
                                                                fieldName: 'hire_state',
                                                                valueToRemove: "${widget.candidate['id']} - ${status}",
                                                              );
                                                            }
                                                            firestoreService
                                                                .removeValueFromField_User_Employer(
                                                              fieldName: 'hire_state',
                                                              valueToRemove: "${widget.candidate['id']} - Offer declined",
                                                            );
                                                            firestoreService
                                                                .deleteValueFromField_Opposite_to_User_Employee(
                                                                id: widget.candidate['id'] ??
                                                                    '',
                                                                fieldName: 'ReceiveduserEmployers',
                                                                valueToRemove: data?['id'] ??
                                                                    ''
                                                            );
                                                          } else {
                                                            firestoreService
                                                                .adppendValueToField_User_Employer(
                                                              fieldName: 'ApplieduserEmployees',
                                                              newValue: widget.candidate['id'] ??
                                                                  '',
                                                            );
                                                            firestoreService
                                                                .adppendValueToField_User_Employer(
                                                              fieldName: 'hire_state',
                                                              newValue: "${widget.candidate['id']} - ${statuses[0]}",
                                                            );
                                                            firestoreService
                                                                .appendValueToField_Opposite_to_User_Employee(
                                                                id: widget.candidate['id'] ??
                                                                    '',
                                                                fieldName: 'ReceiveduserEmployers',
                                                                newValue: data?['id'] ??
                                                                    ''
                                                            );
                                                          }
                                                          Navigator
                                                              .of(
                                                              context)
                                                              .pop(
                                                              true); // Close the dialog and return true
                                                          _vibrate();
                                                          ScaffoldMessenger
                                                              .of(
                                                              context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                data?['hire_state']
                                                                    ?.contains(
                                                                    "${widget.candidate['id']} - Offer declined") ?
                                                                'Candidate removed from suggestion'
                                                                    : data?['ApplieduserEmployees']
                                                                    ?.contains(
                                                                    widget.candidate['id']) ??
                                                                    false
                                                                    ? 'Candidate withdrawn successfully.'
                                                                    : 'Candidate elected successfully.',
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: 16, // Adjust the font size as needed
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  seconds: 1),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('Yes',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      // Add some space between buttons
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red[500],
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false); // Close the dialog and return false
                                                        },
                                                        child: Text('No',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: (checkIds(widget.candidate['id'],'ApplieduserEmployees')) ? Icon(
                                          Icons.done_all_rounded,
                                          color: Colors.white) :
                                      Icon(
                                          Icons.done_outline_rounded,
                                          color: Colors.white),
                                      // Icon with white color
                                      label: Text((checkIds(widget.candidate['id'],'ApplieduserEmployees'))
                                          ? 'Elected' : 'Elect',
                                        style: TextStyle(
                                            fontSize: 17, // Unique font size
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        backgroundColor: (checkIds(widget.candidate['id'],'ApplieduserEmployees')) ?
                                        Colors.green : Colors.indigo,
                                        // Good color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Rounded corners for good layout
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Add your submit functionality here
                                        _vibrate();
                                        if (data?['SaveduserEmployees']
                                            ?.contains(
                                            widget.candidate['id']) ??
                                            false) {
                                          firestoreService
                                              .removeValueFromField_User_Employer(
                                            fieldName: 'SaveduserEmployees',
                                            valueToRemove: widget.candidate['id'] ??
                                                '',
                                          );
                                        } else {
                                          firestoreService
                                              .adppendValueToField_User_Employer(
                                            fieldName: 'SaveduserEmployees',
                                            newValue: widget.candidate['id'] ??
                                                '',
                                          );
                                        }
                                        // Using null-aware operator to handle potential null value
                                      },
                                      icon: (data?['SaveduserEmployees']?.contains(widget.candidate['id']) ?? false)
                                          ? Icon(
                                        Icons.bookmark,
                                        color: Colors.deepOrangeAccent,
                                      )
                                          : Icon(
                                        Icons.bookmark_outline,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        (data?['SaveduserEmployees']?.contains(widget.candidate['id']) ?? false)
                                            ? 'Saved'
                                            : 'Save',
                                        style: TextStyle(
                                          fontSize: 17, // Unique font size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.indigo,
                                        // Good color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Rounded corners for good layout
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${widget.candidate['title']} :',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.red,
                                        fontFamily: 'rowdy'
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Visibility(
                                  visible: (data?['ApplieduserEmployees']?.contains(widget.candidate['id']) ?? false),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start,
                                    children: List.generate(
                                        statusess.length, (index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: index <
                                                        currentStatus
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    child: Icon(Icons.check,
                                                        color: index <
                                                            currentStatus
                                                            ? Colors.black
                                                            : Colors.white),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(statusess[index],
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                          fontFamily: 'rowdy',
                                                          color: Colors.black)),
                                                ],
                                              ),
                                              if (index < statusess.length -
                                                  1) // Only draw line if not last avatar
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 18),
                                                  child: Container(
                                                    width: 22,
                                                    height: 2,
                                                    color: Colors.grey,
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                Visibility(
                                    visible: checkIds(widget.candidate['id'],'ApplieduserEmployees'),
                                    child: SizedBox(height: 20)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: [
                                    Text(
                                      'Name : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['name']}',
                                          style: TextStyle(fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: [
                                    Text(
                                      'Location : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['location']}',
                                          style: TextStyle(fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Gender : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['Personal Details']['Gender']}',
                                          style: TextStyle(fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Education : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['Education Details'][0]['Degree']}',
                                          style: TextStyle(fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Marital Status : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['Personal Details']['Marital Status']}',
                                          style: TextStyle(fontSize: 15),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Language preferred : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.candidate['Personal Details']['Language']}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Skills : ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                        '${widget.candidate['Skills']['Technical Skills']}', // Replace with actual skills if available
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                color: Colors.lightGreen,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Contact details : ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'rowdy'
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '✆ : ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.candidate['Personal Details']['Phone Number']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '@ : ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.candidate['Personal Details']['Email Address']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 3),
                                  Visibility(
                                    visible: 1>2, // widget.candidate['Personal Details']['Web Site'] != null,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '🌏︎︎ : ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'blah', // Replace with actual URL if available
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Visibility(
                            visible: widget.candidate['Skills']['Candidate Description'] != null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description : ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'rowdy'
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '${widget.candidate['Skills']['Candidate Description']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
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

class StatusIndicator extends StatelessWidget {
  final List<String> statuses = ["APPLIED", "PENDING", "CONFIRM", "FINISH"];
  final int currentStatus = 2; // Example: status 0 out of 4 (APPLIED)

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(statuses.length, (index) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: index < currentStatus ? Colors.greenAccent : Colors.grey,
                    child: index < currentStatus
                        ? Icon(Icons.check, color: index < currentStatus ? Colors.black : Colors.grey)
                        : Icon(Icons.check, color: index < currentStatus ? Colors.grey : Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    statuses[index],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: index < currentStatus ? Colors.black : Colors.grey,
                        fontSize: 9
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}