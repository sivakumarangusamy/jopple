import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:jopple/main.dart';
import 'package:jopple/services.dart';
import 'package:vibration/vibration.dart';
import 'candidate infopage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool? FileExistt;
bool? Validation_pass;
FirestoreService firestoreService = FirestoreService();

Future<void> _vibrate() async {
  bool hasVibrator = await Vibration.hasVibrator() ?? false;
  if (hasVibrator) {
    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
  }
}

Future<void> _doesFileExistt() async {
  FileExist = false;
  firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: false);
  final storageRef = FirebaseStorage.instance.ref().child('Jopple_Storage_Files');
  final result = await storageRef.listAll();
  String temp_name = '${uid} - Resume';
  for (var item in result.items) {
    print('${item.name} == $temp_name');
    if (item.name == temp_name) {
      firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: true);
      FileExistt = true;
      break;
    }
    else {
      firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: false);
      FileExistt = false;
    }
  }
  print('FileExistt - $FileExistt');
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _doesFileExistt();
    print('Navigated to ${route.settings.name}');
    if (previousRoute != null) {
      print('Previous route was ${previousRoute.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _doesFileExistt();
    print('Popped from ${route.settings.name}');
    if (previousRoute != null) {
      print('Navigated back to ${previousRoute.settings.name}');
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _doesFileExistt();
    print('Removed ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _doesFileExistt();
    print('Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

class Profile_Viewer extends StatefulWidget {
  @override
  _Profile_ViewerState createState() => _Profile_ViewerState();
}

class _Profile_ViewerState extends State<Profile_Viewer> {

  late bool profile_view_state;
  final DocumentReference _userDoc = FirebaseFirestore.instance.collection('User_Employee').doc(uid);

  Widget customBackButton(BuildContext context) {
    return SizedBox(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        ),
        child: Icon(
          Icons.arrow_back,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    firestoreService.initializeUserData_User_Employee();
    _doesFileExistt();
  }

  Future<void> _viewFile() async {
    try {
      String downloadURL = await FirebaseStorage.instance.
      ref('Jopple_Storage_Files/${uid} - Resume').getDownloadURL();
      print('Jopple_Storage_Files/${uid} - Resume');
      Uri downloadUri = Uri.parse(downloadURL);
      if (await canLaunchUrl(downloadUri)) {
        await launchUrl(downloadUri);
      } else {
        throw 'Could not launch $downloadURL';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _testLaunch() async {
    const url = 'https://www.google.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      navigatorObservers: [MyNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: customBackButton(context),
          centerTitle: true,
          title: GestureDetector(
            onTap: () async {
              _vibrate();
              await _testLaunch();
            },
            child: const Text(
              'Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cour',
                  fontSize: 28,
                  color: Colors.teal),
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
        body: StreamBuilder<DocumentSnapshot>(
          stream: _userDoc.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No data found'));
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            if (data.containsKey('Education Details')) {
              List<dynamic> educationDetailsList = List.from(data['Education Details']);
              for (var educationDetail in educationDetailsList) {
                (educationDetail as Map<String, dynamic>).remove('Honors/Awards');
              }
              data['Education Details'] = educationDetailsList;
            }
            if (data.containsKey('Employment Details')) {
              List<dynamic> educationDetailsList = List.from(data['Employment Details']);
              for (var educationDetail in educationDetailsList) {
                (educationDetail as Map<String, dynamic>).remove('Additional Skills');
              }
              data['Employment Details'] = educationDetailsList;
            }
            if (data.containsKey('Education Details')) {
              List<dynamic> educationDetailsList = List.from(data['Education Details']);
              for (var educationDetail in educationDetailsList) {
                var educationMap = educationDetail as Map<String, dynamic>;
                educationMap.removeWhere((key, value) => value == null || value.toString().isEmpty || (value is List && value.isEmpty));
              }
              data['Education Details'] = educationDetailsList;
            }
            if (data.containsKey('Employment Details')) {
              List<dynamic> educationDetailsList = List.from(data['Employment Details']);
              for (var educationDetail in educationDetailsList) {
                var educationMap = educationDetail as Map<String, dynamic>;
                educationMap.removeWhere((key, value) => value == null || value.toString().isEmpty || (value is List && value.isEmpty));
              }
              data['Employment Details'] = educationDetailsList;
            }
            if (data.containsKey('Personal Details')) {
              Map<String, dynamic> personalDetailsMap = data['Personal Details'];
              personalDetailsMap.removeWhere((key, value) => value == null || value.toString().isEmpty || (value is List && value.isEmpty));
            }
            if (data.containsKey('Skills')) {
              Map<String, dynamic> personalDetailsMap = data['Skills'];
              personalDetailsMap.removeWhere((key, value) => value == null || value.toString().isEmpty || (value is List && value.isEmpty));
            }
            if (data.containsKey('Personal Details')) {
              Map<String, dynamic> personalDetailsMap = data['Personal Details'];
              personalDetailsMap.remove('time');
            }
            data.removeWhere((key, value) => value == null || value.toString().isEmpty);
            data.removeWhere((key, value) => value is List && value.isEmpty);
            data.removeWhere((key, value) => value is Map && value.isEmpty);
            data.remove('JobIds');
            data.remove('AppliedJobIds');
            data.remove('SavedJobIds');
            data.remove('Status');
            data.remove('Skills');
            bool resumeExist = data['ResumeExist'];
            Map<String, dynamic> dataCopy = Map.from(data)..remove('ResumeExist');
            if (dataCopy.isEmpty) {
              profile_view_state = true;
            }
            else {
              profile_view_state = false;
            }
            return profile_view_state
                ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Container(
                  width: width,
                  child: Text(
                    'Profile details are empty,\n'
                        'please click on the top right\n'
                        'corner icon to fill the details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ) : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Visibility(
                        child: resumeExist == true ? Padding(
                          padding: const EdgeInsets.only(left:10,top:10,bottom:10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.38,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _vibrate();
                                    await _viewFile();
                                    print(resumeExist);
                                  },
                                  child: Text('View Resume',
                                      style: TextStyle(color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                      )),
                                  style: ElevatedButton.styleFrom(
                                    side: BorderSide(color: Colors.black, width: 2),
                                    backgroundColor: Colors.green[500],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : SizedBox(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:0,horizontal:10),
                        child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                            color:Color.fromRGBO(245, 230, 210, 1.0),
                              border: Border.all(color: Colors.black, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:15,horizontal:15),
                              child: _buildSection('Personal Details', data['Personal Details']),
                            )),
                      ),
                      SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:5,horizontal:10),
                        child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                color:Color.fromRGBO(245, 230, 210, 1.0),
                                border: Border.all(color: Colors.black, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:15,horizontal:15),
                              child: _buildSection('Education Details', data['Education Details']),
                            )),
                      ),
                      SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:0,horizontal:10),
                        child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                color:Color.fromRGBO(245, 230, 210, 1.0),
                                border: Border.all(color: Colors.black, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:15,horizontal:15),
                              child: _buildSection('Employment Details', data['Employment Details']),
                            )),
                      ),
                      SizedBox(height: 10),
                      /* Padding(
                        padding: const EdgeInsets.symmetric(vertical:10,horizontal:10),
                        child: Container(
                            color:Color.fromRGBO(245, 230, 210, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:10,horizontal:10),
                              child: _buildSection('Skills', data['Skills']),
                            )),
                      ),
                      SizedBox(height: 20), */
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(String sectionTitle, dynamic sectionData) {
    double width = MediaQuery.of(context).size.width;
    if (sectionData == null) return SizedBox.shrink();

    List<Widget> sectionWidgets = [];

    // Add section title
    sectionWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom:5),
        child: Container(
          width: width,
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "$sectionTitle :",
                  style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 20, color: Colors.indigo,fontFamily: 'anta'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ),
      ),
    );
    ///////////////////////////////////////////////////////
    if (sectionData is Map<String, dynamic>) {
      sectionData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          sectionWidgets.add(
            Container(
              // color: Color.fromRGBO(245, 230, 210, 1.0),
              height: 32,
              child:
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Text(
                        '$key : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        maxLines: 1,
                        ' ${value.toString()}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ),
          );
        }
      });
    }
    ///////////////////////////////////////////////////////
    else if (sectionData is List) {
      for (int i = 0; i < sectionData.length; i++) {
        var item = sectionData[i];
        if (item is Map<String, dynamic>) {
          item.forEach((key, value) {
            if (value != null && value.toString().isNotEmpty) {
              sectionWidgets.add(
                Container(
                  height: 32,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          '$key : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ' ${value.toString()}',
                          style: TextStyle(fontSize: 14), // Adjust font size
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          });
          // Add a line break and divider if there are multiple items
          if (sectionData.length > 1 && i < sectionData.length - 1) {
            sectionWidgets.add(SizedBox(height: 5));
            sectionWidgets.add(
            Container(
                width : width,
                child: Divider(thickness: 3,color: Colors.grey)));
            sectionWidgets.add(SizedBox(height: 5));
          }
        } else {
          if (item != null && item.toString().isNotEmpty) {
            sectionWidgets.add(
              Container(
                height: 32,
                child: ListTile(
                  title: Text(
                    item.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
        }
      }
    } else {
      // Handle other data types or null values here
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sectionWidgets,
    );
  }
}