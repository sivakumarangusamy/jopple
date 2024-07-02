import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';

late String current_id;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Big + Button Example'),
        ),
        body: Center(
          child: BigPlusButton(),
        ),
      ),
    );
  }
}

class BigPlusButton extends StatelessWidget {
  Future<void> replaceData(String uid, String field, dynamic newData) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('User_Employer').doc(uid);
    await docRef.set({field: newData}, SetOptions(merge: true));
  }
  /* Future<void> cus_createNewUserEmployee() async {
    print("Creating new user for employee - sample");
    // Reference to Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String generateRandomEmail() {
      const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
      Random random = Random();
      String username = List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
      return "$username@example.com";
    }

    String random_name = generateRandomEmail();

    // Reference to the document
    DocumentReference docRef = firestore.collection('User_Employee').doc("$random_name - uid_syntax");

    current_id = "$random_name - uid_syntax";

    try {
      // Check if the document already exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('Document with name sample already exists.');
        return; // Abort the function
      }

      // Function to generate a unique random id
      Future<String> generateUniqueRandomId() async {
        Random random = Random();
        String id;
        bool idExists;

        do {
          id = random.nextInt(1000000).toString();
          DocumentSnapshot employeeIdSnapshot = await firestore
              .collection('Employee_Ids')
              .doc('Employee_ID_List')
              .get();

          if (employeeIdSnapshot.exists) {
            var data = employeeIdSnapshot.data() as Map<String, dynamic>;
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

      Map<String, dynamic> idField = {"id": id};

      // Merge all data
      Map<String, dynamic> mergedData = {...idField};

      // Set the document with the merged data
      await docRef.set(mergedData);

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

      print('Document sample created successfully with userEmployers and unique id $id.');
    } catch (e) {
      print('Failed to create document or fetch Employers IDs: $e');
    }
  } */
  Future<void> cus_createNewUserEmployer() async {
    // Reference to Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String generateRandomEmail() {
      const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
      Random random = Random();
      String username = List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
      return "$username@example.com";
    }

    String random_name = generateRandomEmail();

    current_id = "$random_name - uid_syntax";


    // Reference to the document
    DocumentReference docRef = firestore.collection('User_Employer').doc("$random_name - uid_syntax");

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

    try {
      // Check if the document already exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('Document with name $uid already exists.');
        return; // Abort the function
      }

      // Generate a unique random id
      String id = await generateUniqueRandomId();

      Map<String, dynamic> idField = {"id": id};

      // Merge all data
      Map<String, dynamic> mergedData = {...idField};

      // Set the document with the merged data
      await docRef.set(mergedData);

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

  Future<void> addDetails({
    String? compName, String? lda, String? workType,
    String? requal, String? modes, String? address, String? pn,
    String? email, String? site, String? jh, String? jd, String? lang
  }) async {

    await cus_createNewUserEmployer();

    await replaceData(current_id, 'docExist', false);
    await replaceData(current_id, 'fetchValid', false);
    await replaceData(current_id, 'title', jh);
    await replaceData(current_id, 'name', compName);
    await replaceData(current_id, 'location', address);
    await replaceData(current_id, 'ApplieduserEmployees', []);
    await replaceData(current_id, 'SaveduserEmployees', []);
    await replaceData(current_id, 'ReceiveduserEmployees', []);
    await replaceData(current_id, 'RemoveduserEmployees', []);
    await replaceData(current_id, 'hire_state', []);

    // Adding company details
    if (compName != null &&
        lda != null &&
        workType != null &&
        requal != null &&
        modes != null &&
        address != null &&
        pn != null &&
        email != null &&
        jh != null &&
        jd != null &&
        lang != null) {
      final Map<String, dynamic> companyDetails = {
        'Company Name': compName,
        'Deadline Date': lda,
        'Work Type': workType,
        'Required Qualification': requal,
        'Work Modes': modes,
        'Address': address,
        'Phone Number': pn,
        'Email Address': email,
        'Web Site': site,
        'Job Hiring': jh,
        'Job Description': jd,
        'Language': lang,
        'time': Timestamp.now(),
      };
      await replaceData(current_id, 'Company Details', companyDetails);
    }
  }

  Future<void> callAddDetails() async {
    await addDetails(
      compName: "Digital Marketing Experts",
      lda: "2025-10-31",
      workType: "Full-time",
      requal: "Bachelor's degree in Marketing or related field",
      modes: "On-site",
      address: "123 Marketing Avenue, Advert City, CA",
      pn: "555-111-2222",
      email: "careers@digitalmarketingexperts.com",
      site: "https://www.digitalmarketingexperts.com",
      jh: "Digital Marketing Specialist",
      jd: "Create and implement digital marketing strategies.",
      lang: "English",
    );
  }

  Future<void> removeSubstringFromRequiredQualification() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference usersRef = firestore.collection('User_Employer');

    try {
      // Get all documents from the collection
      QuerySnapshot snapshot = await usersRef.get();

      // Iterate through each document
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Get the document reference and data
        final DocumentReference docRef = usersRef.doc(doc.id);
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        // Check if data is not null and contains 'Company Details'
        if (data != null && data.containsKey('Company Details')) {
          // Get the 'Company Details' field
          final Map<String, dynamic>? companyDetails =
          data['Company Details'] as Map<String, dynamic>?;

          // Check if 'Company Details' is not null and contains 'Required Qualification'
          if (companyDetails != null &&
              companyDetails.containsKey('Required Qualification')) {
            // Update the 'Required Qualification' field inside 'Company Details'
            String oldValue = companyDetails['Required Qualification'];
            String newValue =
            oldValue.replaceAll(" degree", "");

            // Create a new map with updated 'Company Details'
            final Map<String, dynamic> updatedData = {
              ...data,
              'Company Details': {
                ...companyDetails,
                'Required Qualification': newValue,
              },
            };

            // Update the document with the new data
            await docRef.update(updatedData);
          }
        }
      }
      print('Substring removed successfully from Required Qualification field.');
    } catch (e) {
      print('Error removing substring from Required Qualification field: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await removeSubstringFromRequiredQualification();
      },
      child: Text(
        '+',
        style: TextStyle(fontSize: 50), // Large font size for the + symbol
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Increase padding for a larger button
      ),
    );
  }
}
