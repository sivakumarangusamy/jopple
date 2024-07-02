import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jopple/main.dart';
import 'package:jopple/services.dart';
import 'package:jopple/profile_view.dart';
import 'package:vibration/vibration.dart';
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
  return _firestore.collection('User_Employer').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
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
    'SaveduserEmployers': firestoreService.saveduserEmployers,
    'job_state': firestoreService.job_state_list
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
    'job_state': firestoreService.job_state_list
  };
  List<String> result = [];
  if (fieldMap.containsKey(fields)) {
    result = fieldMap[fields] ?? [];
  }
  return result;
}

class EmployeeMenuPage extends StatefulWidget {

  @override
  _EmployeeMenuPageState createState() => _EmployeeMenuPageState();
}

class _EmployeeMenuPageState extends State<EmployeeMenuPage> {
  String _searchQuery = '';
  int _currentPage = 0;
  int _itemsPerPage = 10;
  List<String> job_cat = [];
  List<String> _selectedEmployerCategory = [];
  List<String> selectedItems = [];
  int selectedCount = 0;

  Future<void> fetchJobCategories() async {
    job_cat = (await FirebaseFirestore.instance.collection('Employer_Ids').doc('Employer_Title_List')
        .get()).data()?['titles'].cast<String>() ?? []; }

  @override
  void initState() {
    super.initState();
    fetchJobCategories();
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
    final double width = MediaQuery.of(context).size.width;
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchData(),
        builder: (context, snapshot) {
          final employerListings = snapshot.data ?? [];
          List<Map<String, dynamic>> filteredEmployerListings = employerListings.where((employer) {
            final matchesSearchQuery = _searchQuery.isEmpty ||
                employer['title']?.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedEmployerCategory.contains(employer['title']) || _selectedEmployerCategory.isEmpty;
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
                        print(job_cat);
                        print(_selectedEmployerCategory);
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
                                  return CandidateInfo();
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
                        .width * 0.65,
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
                                    return Profile_Viewer();
                                  }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.done_outline_rounded),
                            title: Text('Job Offers'),
                            onTap: () {
                              // Navigate to about screen or perform any action
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (BuildContext context) {
                                    return ReceivedJobs();
                                  }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Saved Jobs'),
                            onTap: () {
                              // Navigate to about screen or perform any action
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (BuildContext context) {
                                    return SavedJobs();
                                  }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.add_task_sharp),
                            title: Text('Applied Jobs'),
                            onTap: () {
                              // Navigate to about screen or perform any action
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (BuildContext context) {
                                    return AppliedJobs();
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
                                      labelText: ' Search for jobs',
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
                                  SizedBox(height: 5),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton2<String>(
                                                    isExpanded: true,
                                                    hint: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left:8.0),
                                                          child: Text(
                                                            selectedCount > 0 ? "Filtered - ${selectedCount.toString()}"
                                                                : 'Select categories',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: selectedCount > 0 ? Colors.black : Theme.of(context).hintColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    items: job_cat.map((item) {
                                                      return DropdownMenuItem(
                                                        value: item,
                                                        enabled: true,
                                                        child: StatefulBuilder(
                                                          builder: (context, menuSetState) {
                                                            final isSelected = selectedItems.contains(item);
                                                            return InkWell(
                                                              onTap: () {
                                                                isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                                                setState(() {
                                                                  _selectedEmployerCategory = selectedItems;
                                                                  selectedCount = selectedItems.length; // Update selected count
                                                                });
                                                                menuSetState(() {});
                                                              },
                                                              child: Container(
                                                                height: double.infinity,
                                                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                child: Row(
                                                                  children: [
                                                                    if (isSelected)
                                                                      const Icon(Icons.check_box_outlined)
                                                                    else
                                                                      const Icon(Icons.check_box_outline_blank),
                                                                    const SizedBox(width: 16),
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
                                                        _selectedEmployerCategory = selectedItems;
                                                        selectedCount = selectedItems.length; // Update selected count
                                                      });
                                                    },
                                                    buttonStyleData: ButtonStyleData(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey,width: 2), // Border color
                                                        borderRadius: BorderRadius.circular(8.0), // Border radius
                                                      ),
                                                      height: 50,
                                                      width: 150,
                                                    ),
                                                    menuItemStyleData: MenuItemStyleData(
                                                      height: 40,
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    dropdownStyleData: DropdownStyleData(
                                                      width: width * 0.85,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15.0),
                                            StreamBuilder<List<Map<String, dynamic>>>(
                                            stream: fetchData_secondary(),
                                            builder: (context, snapshot) {
                                              Map<String,
                                                  dynamic>? data = snapshot.data
                                                  ?.first;
                                              return Column(
                                                children: List.generate(
                                                    currentEmployers.length, (
                                                    index) {
                                                  final employer = currentEmployers[index];
                                                  if (employer['title'] == null) {
                                                    return SizedBox();
                                                  }
                                                  if (employer['title'] ==
                                                      "*") {
                                                    return SizedBox(); // Skip generating UI for null jobs
                                                  }
                                                  /* if (employer['FetchValid'] ==
                                                      false) {
                                                    return SizedBox(); // Skip generating UI for null jobs
                                                  } */
                                                  if ((data != null &&
                                                      data['RemoveduserEmployers'] != null &&
                                                      data['RemoveduserEmployers'] is List &&
                                                      data['RemoveduserEmployers'].contains(employer['id']))) {
                                                    return SizedBox();
                                                  }
                                                  return Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(10.0),
                                                        child: Dismissible(
                                                          key: Key(
                                                              employer['id'] ??
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
                                                                                    .adppendValueToField_User_Employee(
                                                                                  fieldName: 'RemoveduserEmployers',
                                                                                  newValue: employer['id'] ??
                                                                                      '',
                                                                                );
                                                                                firestoreService
                                                                                    .removeValueFromField_User_Employee(
                                                                                  fieldName: 'ApplieduserEmployers',
                                                                                  valueToRemove: employer['id'] ??
                                                                                      '',
                                                                                );
                                                                                firestoreService
                                                                                    .removeValueFromField_User_Employee(
                                                                                  fieldName: 'SaveduserEmployers',
                                                                                  valueToRemove: employer['id'] ??
                                                                                      '',
                                                                                );
                                                                                firestoreService
                                                                                    .removeValueFromField_User_Employee(
                                                                                  fieldName: 'job_state',
                                                                                  valueToRemove: "${employer['id']} - Job rejected",
                                                                                );
                                                                                for (String status in statuses) {
                                                                                  firestoreService
                                                                                      .removeValueFromField_User_Employee(
                                                                                    fieldName: 'job_state',
                                                                                    valueToRemove: "${employer['id']} - ${status}",
                                                                                  );
                                                                                }
                                                                                firestoreService.deleteValueFromField_Opposite_to_User_Employer(
                                                                                    id: employer['id'],
                                                                                    fieldName: 'ReceiveduserEmployees',
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
                                                                                      'Job removed from recommended list',
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
                                                              if (data?['SaveduserEmployers']
                                                                  ?.contains(
                                                                  employer['id']) ??
                                                                  false) {
                                                                firestoreService
                                                                    .removeValueFromField_User_Employee(
                                                                  fieldName: 'SaveduserEmployers',
                                                                  valueToRemove: employer['id'] ??
                                                                      '',
                                                                );
                                                              } else {
                                                                firestoreService
                                                                    .adppendValueToField_User_Employee(
                                                                  fieldName: 'SaveduserEmployers',
                                                                  newValue: employer['id'] ??
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
                                                              color: Colors.red,
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
                                                            child: data?['SaveduserEmployers']
                                                                ?.contains(
                                                                employer['id']) ??
                                                                false
                                                                ? Icon(
                                                                Icons.bookmark,
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
                                                                  employer['title'] ??
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
                                                                  '${employer['company']} - ${employer['location']}',
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
                                                                        return JobDescription(
                                                                            job: employer); // Pass the job object here
                                                                      },
                                                                    ));
                                                              },
                                                              trailing: ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                    backgroundColor: data?['job_state']
                                                                        ?.contains(
                                                                        "${employer['id']} - Job rejected") ??
                                                                        false
                                                                        ? Colors
                                                                        .grey
                                                                        : data?['ApplieduserEmployers']
                                                                        ?.contains(
                                                                        employer['id']) ??
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
                                                                                data?['job_state']
                                                                                ?.contains(
                                                                                "${employer['id']} - Job rejected") ?
                                                                                    'Are you sure you want to\rremove this Job'
                                                                              : data?['ApplieduserEmployers']
                                                                                  ?.contains(
                                                                                  employer['id']) ??
                                                                                  false
                                                                                  ? 'Are you sure you want to\nwithdraw this application?'
                                                                                  : 'Are you sure you want to\napply for this job?',
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
                                                                                    if (data?['ApplieduserEmployers']
                                                                                        ?.contains(
                                                                                        employer['id']) ??
                                                                                        false) {
                                                                                      if (data?['job_state']
                                                                                          ?.contains(
                                                                                          "${employer['id']} - Job rejected")) {
                                                                                        firestoreService
                                                                                            .adppendValueToField_User_Employee(
                                                                                          fieldName: 'RemoveduserEmployers',
                                                                                          newValue: employer['id'] ??
                                                                                              '',
                                                                                        );
                                                                                      }
                                                                                      firestoreService
                                                                                          .removeValueFromField_User_Employee(
                                                                                        fieldName: 'ApplieduserEmployers',
                                                                                        valueToRemove: employer['id'] ??
                                                                                            '',
                                                                                      );
                                                                                      for (String status in statuses) {
                                                                                        firestoreService
                                                                                            .removeValueFromField_User_Employee(
                                                                                          fieldName: 'job_state',
                                                                                          valueToRemove: "${employer['id']} - ${status}",
                                                                                        );
                                                                                      }
                                                                                      firestoreService
                                                                                          .removeValueFromField_User_Employee(
                                                                                        fieldName: 'job_state',
                                                                                        valueToRemove: "${employer['id']} - Job rejected",
                                                                                      );
                                                                                      firestoreService
                                                                                          .deleteValueFromField_Opposite_to_User_Employer(
                                                                                          id: employer['id'] ??
                                                                                              '',
                                                                                          fieldName: 'ReceiveduserEmployees',
                                                                                          valueToRemove: data?['id'] ??
                                                                                              ''
                                                                                      );
                                                                                    } else {
                                                                                      firestoreService
                                                                                          .adppendValueToField_User_Employee(
                                                                                        fieldName: 'ApplieduserEmployers',
                                                                                        newValue: employer['id'] ??
                                                                                            '',
                                                                                      );
                                                                                      firestoreService
                                                                                          .adppendValueToField_User_Employee(
                                                                                        fieldName: 'job_state',
                                                                                        newValue: "${employer['id']} - ${statuses[0]}",
                                                                                      );
                                                                                      firestoreService
                                                                                          .appendValueToField_Opposite_to_User_Employer(
                                                                                          id: employer['id'] ??
                                                                                              '',
                                                                                          fieldName: 'ReceiveduserEmployees',
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
                                                                                          data?['job_state']
                                                                                              ?.contains(
                                                                                              "${employer['id']} - Job rejected") ?
                                                                                          'Job removed from suggestion'
                                                                                              : data?['ApplieduserEmployers']
                                                                                              ?.contains(
                                                                                              employer['id']) ??
                                                                                              false
                                                                                              ? 'Application withdrawn successfully.'
                                                                                              : 'Job applied successfully.',
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
                                                                      data?['job_state']
                                                                          ?.contains(
                                                                          "${employer['id']} - Job rejected")
                                                                          ? 'Rejected'
                                                                          : data?['ApplieduserEmployers']
                                                                          ?.contains(
                                                                          employer['id'])
                                                                          ? 'Applied'
                                                                          : 'Apply',
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
                                              );
                                            }
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

class SavedJobs extends StatefulWidget {
  @override
  _SavedJobsState createState() => _SavedJobsState();
}

class _SavedJobsState extends State<SavedJobs> {
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
        final employerListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
            Map<String, dynamic>? data = snapshot.data?.first;
            List<Map<String, dynamic>> savedEmployers = employerListings.where((employer) =>
                data?['SaveduserEmployers'].contains(employer['id'])).toList();
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: GestureDetector(
                  onTap: () {
                    print(data?['location']);
                  },
                  child: const Text(
                    'Saved Jobs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'cour',
                      fontSize: 28,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
              body: savedEmployers.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Container(
                    width: width,
                    child: Text(
                      'Saved jobs list is empty',
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
                itemCount: savedEmployers.length,
                itemBuilder: (context, index) {
                  final employer = savedEmployers[index];
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
                              employer['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                          ),
                          subtitle: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${employer['company']} - ${employer['location']}',
                              maxLines: 2,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                                return JobDescription(job: employer); // Pass the job object here
                              },
                            ));
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
                                                firestoreService.removeValueFromField_User_Employee(
                                                  fieldName: 'SaveduserEmployers',
                                                  valueToRemove: employer['id'] ?? '',
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Job removed from Saved list',
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

class AppliedJobs extends StatefulWidget {
  @override
  _AppliedJobsState createState() => _AppliedJobsState();
}

class _AppliedJobsState extends State<AppliedJobs> {
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
        final employerListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
              Map<String, dynamic>? data = snapshot.data?.first;
              List<Map<String, dynamic>> appliedEmployers = employerListings.where((employer) =>
                  data?['ApplieduserEmployers'].contains(employer['id'])).toList();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {
                      print(data?['location']);
                    },
                    child: const Text(
                      'Applied Jobs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cour',
                        fontSize: 28,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                body: appliedEmployers.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: width,
                      child: Text(
                        'Applied jobs list is empty',
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
                  itemCount: appliedEmployers.length,
                  itemBuilder: (context, index) {
                    final employer = appliedEmployers[index];
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
                                employer['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ),
                            subtitle: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${employer['company']} - ${employer['location']}',
                                maxLines: 2,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return JobDescription(job: employer); // Pass the job object here
                                },
                              ));
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
                                                  firestoreService.removeValueFromField_User_Employee(
                                                    fieldName: 'ApplieduserEmployers',
                                                    valueToRemove: employer['id'] ?? '',
                                                  );
                                                  for (String status in statuses) {
                                                    firestoreService.removeValueFromField_User_Employee(
                                                      fieldName: 'job_state',
                                                      valueToRemove: "${employer['id']} - ${status}",
                                                    );
                                                  }
                                                  firestoreService.deleteValueFromField_Opposite_to_User_Employer(
                                                      id: employer['id'],
                                                      fieldName: 'ReceiveduserEmployees',
                                                      valueToRemove: data?['id']
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Job removed from Applied list',
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

class ReceivedJobs extends StatefulWidget {
  @override
  _ReceivedJobsState createState() => _ReceivedJobsState();
}

class _ReceivedJobsState extends State<ReceivedJobs> {
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
        final employerListings = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchData_secondary(),
            builder: (context, snapshot) {
              Map<String, dynamic>? data = snapshot.data?.first;
              List<Map<String, dynamic>> appliedEmployers = employerListings.where((employer) =>
                  data?['ReceiveduserEmployers'].contains(employer['id'])).toList();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: GestureDetector(
                    onTap: () {
                    },
                    child: const Text(
                      'Job Offers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cour',
                        fontSize: 28,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                body: appliedEmployers.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: width,
                      child: Text(
                        'Job Offers list is empty',
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
                  itemCount: appliedEmployers.length,
                  itemBuilder: (context, index) {
                    final employer = appliedEmployers[index];
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
                                employer['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ),
                            subtitle: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${employer['company']} - ${employer['location']}',
                                maxLines: 2,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return JobDescription(job: employer); // Pass the job object here
                                },
                              ));
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
                                            'Are you sure you want to decline this job offer?',
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
                                                  firestoreService.removeValueFromField_User_Employee(
                                                    fieldName: 'ReceiveduserEmployers',
                                                    valueToRemove: employer['id'] ?? '',
                                                  );
                                                  for (String status in statuses) {
                                                    firestoreService.deleteValueFromField_Opposite_to_User_Employer(
                                                        id: employer['id'],
                                                        fieldName: 'hire_state',
                                                        valueToRemove: "${data?['id']} - ${status}"
                                                    );
                                                  }
                                                  firestoreService.appendValueToField_Opposite_to_User_Employer(
                                                      id: employer['id'],
                                                      fieldName: 'hire_state',
                                                      newValue: "${data?['id']} - Offer declined"
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Declined the job offer',
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

class JobDescription extends StatefulWidget {
  final Map<String, dynamic> job; // Define a field to store the job object
  JobDescription({required this.job}); // Constructor to receive the job object

  @override
  _JobDescriptionState createState() => _JobDescriptionState();
}

class _JobDescriptionState extends State<JobDescription> {
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
                      List<dynamic>? statusList = data?['job_state'];
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
                    int currentStatus = findStatus(widget.job['id']);
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: GestureDetector(
                          onTap: () {
                            _vibrate();
                            print(getId('job_state'));
                            print(findStatus(widget.job['id']));
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
                                      return CandidateInfo();
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
                                                       checkIds(widget.job['id'],'ApplieduserEmployers') ?
                                                      'Are you sure you want to\nwithdraw this application?'
                                                          :
                                                      'Are you sure you want to\napply for this job?',
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
                                                            if (data?['ApplieduserEmployers']
                                                                ?.contains(
                                                                widget.job['id']) ??
                                                                false) {
                                                              if (data?['job_state']
                                                                  ?.contains(
                                                                  "${widget.job['id']} - Job rejected")) {
                                                                firestoreService
                                                                    .adppendValueToField_User_Employee(
                                                                  fieldName: 'RemoveduserEmployers',
                                                                  newValue: widget.job['id'] ??
                                                                      '',
                                                                );
                                                              }
                                                              firestoreService
                                                                  .removeValueFromField_User_Employee(
                                                                fieldName: 'ApplieduserEmployers',
                                                                valueToRemove: widget.job['id'] ??
                                                                    '',
                                                              );
                                                              for (String status in statuses) {
                                                                firestoreService
                                                                    .removeValueFromField_User_Employee(
                                                                  fieldName: 'job_state',
                                                                  valueToRemove: "${widget.job['id']} - ${status}",
                                                                );
                                                              }
                                                              firestoreService
                                                                  .removeValueFromField_User_Employee(
                                                                fieldName: 'job_state',
                                                                valueToRemove: "${widget.job['id']} - Job rejected",
                                                              );
                                                              firestoreService
                                                                  .deleteValueFromField_Opposite_to_User_Employer(
                                                                  id: widget.job['id'] ??
                                                                      '',
                                                                  fieldName: 'ReceiveduserEmployees',
                                                                  valueToRemove: data?['id'] ??
                                                                      ''
                                                              );
                                                            } else {
                                                              firestoreService
                                                                  .adppendValueToField_User_Employee(
                                                                fieldName: 'ApplieduserEmployers',
                                                                newValue: widget.job['id'] ??
                                                                    '',
                                                              );
                                                              firestoreService
                                                                  .adppendValueToField_User_Employee(
                                                                fieldName: 'job_state',
                                                                newValue: "${widget.job['id']} - ${statuses[0]}",
                                                              );
                                                              firestoreService
                                                                  .appendValueToField_Opposite_to_User_Employer(
                                                                  id: widget.job['id'] ??
                                                                      '',
                                                                  fieldName: 'ReceiveduserEmployees',
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
                                                                  data?['job_state']
                                                                      ?.contains(
                                                                      "${widget.job['id']} - Job rejected") ?
                                                                  'Job removed from suggestion'
                                                                      : data?['ApplieduserEmployers']
                                                                      ?.contains(
                                                                      widget.job['id']) ??
                                                                      false
                                                                      ? 'Application withdrawn successfully.'
                                                                      : 'Job applied successfully.',
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
                                        icon: (checkIds(widget.job['id'],'ApplieduserEmployers')) ? Icon(
                                            Icons.done_all_rounded,
                                            color: Colors.white) :
                                        Icon(
                                            Icons.done_outline_rounded,
                                            color: Colors.white),
                                        // Icon with white color
                                        label: Text((checkIds(widget.job['id'],'ApplieduserEmployers'))
                                              ? 'Applied' : 'Apply',
                                          style: TextStyle(
                                              fontSize: 17, // Unique font size
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          backgroundColor: (checkIds(widget.job['id'],'ApplieduserEmployers')) ?
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
                                          if (data?['SaveduserEmployers']
                                              ?.contains(
                                              widget.job['id']) ??
                                              false) {
                                            firestoreService
                                                .removeValueFromField_User_Employee(
                                              fieldName: 'SaveduserEmployers',
                                              valueToRemove: widget.job['id'] ??
                                                  '',
                                            );
                                          } else {
                                            firestoreService
                                                .adppendValueToField_User_Employee(
                                              fieldName: 'SaveduserEmployers',
                                              newValue: widget.job['id'] ??
                                                  '',
                                            );
                                          }
                                          // Using null-aware operator to handle potential null value
                                        },
                                        icon: (data?['SaveduserEmployers']?.contains(widget.job['id']) ?? false)
                                            ? Icon(
                                          Icons.bookmark,
                                          color: Colors.deepOrangeAccent,
                                        )
                                            : Icon(
                                          Icons.bookmark_outline,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          (data?['SaveduserEmployers']?.contains(widget.job['id']) ?? false)
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
                                      '${widget.job['title']} :',
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.red,
                                          fontFamily: 'rowdy'
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Visibility(
                                    visible: (data?['ApplieduserEmployers']?.contains(widget.job['id']) ?? false),
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
                                      visible: checkIds(widget.job['id'],'ApplieduserEmployers'),
                                      child: SizedBox(height: 20)),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        'Company : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.job['company']}',
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
                                            '${widget.job['location']}',
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
                                        'Work Mode : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.job['Company Details']['Work Modes']}',
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
                                        'Required : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.job['Company Details']['Required Qualification']}',
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
                                        'Work Type : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${widget.job['Company Details']['Work Type']}',
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
                                            '${widget.job['Company Details']['Language']}',
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
                                        'Skills required : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${widget.job['Company Details']['Skills required']}', // Replace with actual skills if available
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
                                              '${widget.job['Company Details']['Phone Number']}',
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
                                              '${widget.job['Company Details']['Email Address']}',
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
                                      visible: widget.job['Company Details']['Web Site'] != null,
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
                                                '${widget.job['Company Details']['Web Site']}', // Replace with actual URL if available
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
                              visible: widget.job['Company Details']['Job Description'] != null,
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
                                        '${widget.job['Company Details']['Job Description']}',
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