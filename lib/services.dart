import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jopple/main.dart';
import 'Employee_Menu.dart';
import 'Employer_Menu.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference userEmployee = FirebaseFirestore.instance.collection('User_Employee');
  final CollectionReference joblisting = FirebaseFirestore.instance.collection('User_Employer');

  late DocumentSnapshot userDocument_1;
  Map<String, dynamic>? userData_1;
  late DocumentSnapshot userDocument_2;
  Map<String, dynamic>? userData_2;

  List<String> applieduserEmployers = [];
  List<String> receiveduserEmployers = [];
  List<String> saveduserEmployers = [];
  List<String> job_state_list = [];
  List<String> applieduserEmployees = [];
  List<String> receiveduserEmployees = [];
  List<String> saveduserEmployees = [];
  List<String> hire_state_list = [];

  // Define getField outside of initializeUserData
  dynamic getField(Map<String, dynamic>? document, String fieldName) {
    if (document != null && document.containsKey(fieldName)) {
      return document[fieldName];
    } else {
      return null; // or any default value you want to return if the field doesn't exist
    }
  }

  Future<String?> getDocumentNameById(String? docId) async {
    if (docId == null) return null;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionRef = firestore.collection('User_Employer');

    try {
      QuerySnapshot querySnapshot = await collectionRef.where('id', isEqualTo: docId).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      // Handle any errors here if necessary
      print('Error fetching document: $e');
      return null;
    }
  }

  Future<void> updateEmployeeIds() async {
    // Reference to the collections and documents
    final CollectionReference userEmployeeCollection = FirebaseFirestore.instance.collection('User_Employee');
    final DocumentReference employeeIdListDoc = FirebaseFirestore.instance.collection('Employee_Ids').doc('Employee_ID_List');
    final DocumentReference employeeIdListDoc_2 = FirebaseFirestore.instance.collection('Employee_Ids').doc('Employee_Title_List');

    // Fetch all documents from User_Employee collection
    final QuerySnapshot userEmployeeSnapshot = await userEmployeeCollection.get();

    // Extract all unique id values from User_Employee documents
    Set<String> uniqueIds = userEmployeeSnapshot.docs.map((doc) => doc.get('id') as String).toSet();
    Set<String> uniqueIds_2 = userEmployeeSnapshot.docs.map((doc) => doc.get('title') as String).toSet();

    // Update Employee_ID_List document in Employee_Ids collection
    await employeeIdListDoc.set({
      'ids': uniqueIds.toList(), // Convert Set to List to store in Firestore
    });
    await employeeIdListDoc_2.set({
      'titles': uniqueIds_2.toList(), // Convert Set to List to store in Firestore
    });

    // Log that the operation is completed
    print('Employee IDs updated successfully.');
  }

  Future<void> updateEmployerIds() async {
    // Reference to the collections and documents
    final CollectionReference userEmployerCollection = FirebaseFirestore.instance.collection('User_Employer');
    final DocumentReference employerIdListDoc = FirebaseFirestore.instance.collection('Employer_Ids').doc('Employer_ID_List');
    final DocumentReference employerIdListDoc_2 = FirebaseFirestore.instance.collection('Employer_Ids').doc('Employer_Title_List');

    // Fetch all documents from User_Employer collection
    final QuerySnapshot userEmployerSnapshot = await userEmployerCollection.get();

    // Extract all unique id values from User_Employer documents
    Set<String> uniqueIds = userEmployerSnapshot.docs.map((doc) => doc.get('id') as String).toSet();
    Set<String> uniqueIds_2 = userEmployerSnapshot.docs.map((doc) => doc.get('title') as String).toSet();

    // Update Employer_ID_List document in Employer_Ids collection
    await employerIdListDoc.set({
      'ids': uniqueIds.toList(), // Convert Set to List to store in Firestore
    });
    await employerIdListDoc_2.set({
      'titles': uniqueIds_2.toList(), // Convert Set to List to store in Firestore
    });

    // Log that the operation is completed
    print('Employer IDs updated successfully.');
  }

  Future<void> appendValueToField_Opposite_to_User_Employee({ required String id,
    required String fieldName, required dynamic newValue }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User_Employee')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentRef = querySnapshot.docs.first.reference;
        await documentRef.update({
          fieldName: FieldValue.arrayUnion([newValue])
        });
      } else {
        print('Document with id $id not found.');
      }
    }
  }

  Future<void> appendValueToField_Opposite_to_User_Employer({ required String id,
    required String fieldName, required dynamic newValue }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User_Employer')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentRef = querySnapshot.docs.first.reference;
        await documentRef.update({
          fieldName: FieldValue.arrayUnion([newValue])
        });
      } else {
        print('Document with id $id not found.');
      }
    }
  }

  Future<void> deleteValueFromField_Opposite_to_User_Employee({ required String id,
    required String fieldName, required dynamic valueToRemove }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User_Employee')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentRef = querySnapshot.docs.first.reference;
        await documentRef.update({
          fieldName: FieldValue.arrayRemove([valueToRemove])
        });
      } else {
        print('Document with id $id not found.');
      }
    }
  }

  Future<void> deleteValueFromField_Opposite_to_User_Employer({ required String id,
    required String fieldName, required dynamic valueToRemove }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User_Employer')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentRef = querySnapshot.docs.first.reference;
        await documentRef.update({
          fieldName: FieldValue.arrayRemove([valueToRemove])
        });
      } else {
        print('Document with id $id not found.');
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<void> createNewUserEmployee(BuildContext context) async {
    print("Creating new user for employee - $uid");
    // Reference to Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the document
    DocumentReference docRef = firestore.collection('User_Employee').doc(uid);

    try {
      // Check if the document already exists
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('Document with name $uid already exists.');
        return; // Abort the function
      }

      Map<String, List<dynamic>> data = {
        "ApplieduserEmployers": [],
        "SaveduserEmployers": [],
        "ReceiveduserEmployers": [],
        "RemoveduserEmployers": [],
        "job_state": [],
      };

      bool resumeExist = false;
      Map<String, dynamic> resumeExistField = {"ResumeExist": resumeExist};

      bool fetchValid = false;
      Map<String, dynamic> fetchValidField = {"FetchValid": fetchValid};

      String title = "*";
      String name = "*";
      String location = "*";

      Map<String, dynamic> titleField = {"title": title};
      Map<String, dynamic> nameField = {"name": name};
      Map<String, dynamic> locationField = {"location": location};

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
      Map<String, dynamic> mergedData = {...data, ...resumeExistField, ...fetchValidField, ...idField,
      ...titleField, ...nameField, ...locationField};

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

      print('Document $uid created successfully with userEmployers and unique id $id.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmployeeMenuPage(),
        ),
      );
    } catch (e) {
      print('Failed to create document or fetch Employers IDs: $e');
    }
  }

  Future<void> initializeUserData_User_Employee() async {
    userDocument_1 = await FirebaseFirestore.instance.collection('User_Employee').doc(uid).get();
    userData_1 = userDocument_1.data() as Map<String, dynamic>?;
    if (userData_1 == null) {
      print('User data is null');
      return;
    }
    // Filter out non-string elements from the lists
    applieduserEmployers = List<String>.from(
        (getField(userData_1, 'ApplieduserEmployers') ?? []).where((item) => item is String)
    );
    receiveduserEmployers = List<String>.from(
        (getField(userData_1, 'ReceiveduserEmployers') ?? []).where((item) => item is String)
    );
    saveduserEmployers = List<String>.from(
        (getField(userData_1, 'SaveduserEmployers') ?? []).where((item) => item is String)
    );
    job_state_list = List<String>.from(
        (getField(userData_1, 'job_state') ?? []).where((item) => item is String)
    );
  }

  Future<void> updateField_User_Employee({ required String fieldName,
    required dynamic newValue }) async {
    try {
      await FirebaseFirestore.instance
          .collection('User_Employee')
          .doc(uid)
          .update({fieldName: newValue});
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  Future<void> adppendValueToField_User_Employee({ required String fieldName,
    required dynamic newValue }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employee').doc(documentName);
      await documentRef.update({
        fieldName: FieldValue.arrayUnion([newValue])
      });
    }
  }

  Future<void> removeValueFromField_User_Employee({ required String fieldName,
    required dynamic valueToRemove }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employee').doc(documentName);
      await documentRef.update({
        fieldName: FieldValue.arrayRemove([valueToRemove])
      });
    }
  }

  Future<void> removeFieldFrom_User_Employee({required String fieldName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employee').doc(documentName);
      await documentRef.update({ fieldName: FieldValue.delete()
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<void> createNewUserEmployer(BuildContext context) async {

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

      String title = "*";
      String company = "*";
      String location = "*";

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmployerMenuPage(),
          ),
        );
      }
      await updateEmployerIds();
      print('Document $uid created successfully with userEmployees and unique id $id.');
    } catch (e) {
      print('Failed to create document or fetch Employees IDs: $e');
    }
  }

  Future<void> initializeUserData_User_Employer() async {
    userDocument_2 = await FirebaseFirestore.instance.collection('User_Employer').doc(uid).get();
    userData_2 = userDocument_2.data() as Map<String, dynamic>?;
    if (userData_2 == null) {
      print('User data is null');
      return;
    }
    // Filter out non-string elements from the lists
    applieduserEmployees = List<String>.from(
        (getField(userData_2, 'ApplieduserEmployees') ?? []).where((item) => item is String)
    );
    receiveduserEmployees = List<String>.from(
        (getField(userData_2, 'ReceiveduserEmployees') ?? []).where((item) => item is String)
    );
    saveduserEmployees = List<String>.from(
        (getField(userData_2, 'SaveduserEmployees') ?? []).where((item) => item is String)
    );
    hire_state_list = List<String>.from(
        (getField(userData_2, 'hire_state') ?? []).where((item) => item is String)
    );
  }

  Future<void> updateField_User_Employer({ required String fieldName,
    required dynamic newValue }) async {
    try {
      await FirebaseFirestore.instance
          .collection('User_Employer')
          .doc(uid)
          .update({fieldName: newValue});
    } catch (e) {
      print('Error updating field: $e');
    }
  }

  Future<void> adppendValueToField_User_Employer({ required String fieldName,
    required dynamic newValue }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employer').doc(documentName);
      await documentRef.update({
        fieldName: FieldValue.arrayUnion([newValue])
      });
    }
  }

  Future<void> removeValueFromField_User_Employer({ required String fieldName,
    required dynamic valueToRemove }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employer').doc(documentName);
      await documentRef.update({
        fieldName: FieldValue.arrayRemove([valueToRemove])
      });
    }
  }

  Future<void> removeFieldFrom_User_Employer({required String fieldName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentName = uid;
      final documentRef = FirebaseFirestore.instance.collection('User_Employer').doc(documentName);
      await documentRef.update({ fieldName: FieldValue.delete()
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  /* Future<bool> checkIfuserEmployerExists(String fieldName, String userEmployer) async {
    Stream<bool> stream = _db.collection('User_Employee').doc(uid).snapshots().map((documentSnapshot) {
      if (documentSnapshot.exists) {
        List<dynamic> fieldArray = documentSnapshot.get(fieldName);
        return fieldArray.contains(userEmployer);
      } else {
        return false;
      }
    });
    return await stream.first;
  } */

  Future<void> replaceData(String uid, String field, dynamic newData) async {
    final docRef = firestore.collection('User_Employee').doc(uid);
    await docRef.set({field: newData}, SetOptions(merge: true));
  }
  // Create operation for personal details
  Future<void> addPersonalDetails(String fullName, String dob, String gender,
      String ms, String nation, String address, String pn, String email, String ji, String lang) {
    final Map<String, dynamic> personalDetails = {
      'Full Name': fullName,
      'Date of Birth': dob,
      'Gender': gender,
      'Marital Status': ms,
      'Nationality': nation,
      'Address': address,
      'Phone Number': pn,
      'Email Address': email,
      'Language': lang,
      'Job Interested': ji,
      'time': Timestamp.now(),
    };
    return replaceData(uid, 'Personal Details', personalDetails);
  }
  // Create operation for education details
  Future<void> addEducationDetails(
      List<String> institutionNames,
      List<String> degrees,
      List<String> gpas,
      List<String> graduationYears,
      List<String> majors,
      List<List<String>> honorsAwards,
      List<List<String>> thesisProjects,
      ) async {
    List<Map<String, dynamic>> educationList = [];

    for (int i = 0; i < institutionNames.length; i++) {
      Map<String, dynamic> educationDetail = {
        'Institution Name': institutionNames[i],
        'Degree': degrees[i],
        'GPA': gpas[i],
        'Graduation Year': graduationYears[i],
        'Major': majors[i],
        'Honors/Awards': honorsAwards[i],
        'Thesis/Projects': thesisProjects[i],
      };
      educationList.add(educationDetail);
    }

    return replaceData(uid, 'Education Details', educationList);
  }
  // Create operation for employment details
  Future<void> addEmploymentDetails(
      List<String> companyNames,
      List<String> positions,
      List<String> jdDates,
      List<String> lwDates,
      List<String> locations,
      List<String> rfls,
      List<List<String>> askills,
      ) async {
    List<Map<String, dynamic>> employmentList = [];

    for (int i = 0; i < companyNames.length; i++) {
      Map<String, dynamic> employmentDetail = {
        'Company Name': companyNames[i],
        'Position': positions[i],
        'Joining Date': jdDates[i],
        'Leaving Date': lwDates[i],
        'Location': locations[i],
        'Reason for Leaving': rfls[i],
        'Additional Skills': askills[i],
      };
      employmentList.add(employmentDetail);
    }

    return replaceData(uid, 'Employment Details', employmentList);
  }
  // Create operation for skills
  Future<void> addSkills(
      List<String> technicalSkills,
      List<String> softSkills,
      List<String> certifications,
      List<String> educationTraining,
      String professionalAffiliations,
      String volunteerExperience,
      String about,
      ) async {
    final Map<String, dynamic> skillsMap = {
      'Technical Skills': technicalSkills,
      'Soft Skills': softSkills,
      'Certifications': certifications,
      'Education/Training': educationTraining,
      'Professional Affiliations': professionalAffiliations,
      'Volunteer Experience': volunteerExperience,
      'Candidate Description': about,
    };

    return replaceData(uid, 'Skills', skillsMap);
  }
  // Create operation for job listings
  Future<void> addJobListing(
      String id,
      String title,
      String company,
      String location,
      String experience,
      String education,
      String salary,
      String skills,
      String category,
      String description,
      String site,
      String email,
      String phone,
      bool applyStatus,
      bool saveStatus,
      int applicationStatus,
      ) {
    final Map<String, dynamic> jobListing = {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'experience': experience,
      'education': education,
      'salary': salary,
      'skills': skills,
      'category': category,
      'description': description,
      'site': site,
      'email': email,
      'phone': phone,
      'apply_status': applyStatus,
      'save_status': saveStatus,
      'application_status': applicationStatus,
      'time': Timestamp.now(),
    };
    return replaceData(uid, 'Job Listings', FieldValue.arrayUnion([jobListing]));
  }

  /////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  Future<void> replaceData_2(String uid, String field, dynamic newData) async {
    final docRef = firestore.collection('User_Employer').doc(uid);
    await docRef.set({field: newData}, SetOptions(merge: true));
  }
  Future<void> addCompanyDetails(String compName, String lda, String workType,
      String requal, String modes, String address, String pn,
      String email, String site, String jh, String jd, String lang) {
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
    return replaceData_2(uid, 'Company Details', companyDetails);
  }

}

/* Stream<List<Map<String, dynamic>>> getAllStream_Employer() {
    CollectionReference userEmployerCollection = FirebaseFirestore.instance.collection('User_Employer');
    return userEmployerCollection.doc(uid).snapshots().asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) {
        return []; }
      List<dynamic> userEmployees = (docSnapshot.data() as Map<String, dynamic>)['userEmployees'] ?? [];
      // Fetch the IDs from User_Employee collection in batches
      CollectionReference userEmployeeIdsCollection = FirebaseFirestore.instance.collection('User_Employee');
      List<List<String>> userEmployeeIdBatches = _splitListIntoBatches(userEmployees, 10); // Split userEmployees into batches
      List<Map<String, dynamic>> allDocuments = [];
      for (var batch in userEmployeeIdBatches) {
        QuerySnapshot querySnapshot = await userEmployeeIdsCollection.where('id', whereIn: batch).get();
        List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        allDocuments.addAll(documents);
      }
      return allDocuments;
    });
  } */
/* Stream<List<Map<String, dynamic>>> getAllStream_Employee() {
    CollectionReference userEmployeeCollection = FirebaseFirestore.instance.collection('User_Employee');
    return userEmployeeCollection.doc(uid).snapshots().asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) {
        return []; }
      List<dynamic> userEmployers = (docSnapshot.data() as Map<String, dynamic>)['User_Employer'] ?? [];
      // Fetch the IDs from User_Employer collection in batches
      CollectionReference userEmployerIdsCollection = FirebaseFirestore.instance.collection('User_Employer');
      List<List<String>> userEmployerIdBatches = _splitListIntoBatches(userEmployers, 10); // Split userEmployers into batches
      List<Map<String, dynamic>> allDocuments = [];
      for (var batch in userEmployerIdBatches) {
        QuerySnapshot querySnapshot = await userEmployerIdsCollection.where('id', whereIn: batch).get();
        List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        allDocuments.addAll(documents);
      }
      return allDocuments;
    });
  } */
/* Stream<List<Map<String, dynamic>>> getAllStream_Employee_additional() {
    return FirebaseFirestore.instance.collection('User_Employee').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }
  Stream<List<Map<String, dynamic>>> getAllStream_Employer_additional() {
    return FirebaseFirestore.instance.collection('User_Employer').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  } */
/* Future<void> adduserEmployeringle() async {
    final List<Map<String, dynamic>> userEmployer = [];
    for (var job in userEmployer) {
      await firestore.collection('User_Employer').add(job);
    }
  } */
/* Stream<List<Map<String, dynamic>>> getAllEmployee_details() {
    final collection = FirebaseFirestore.instance.collection('User_Employee');
    return collection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  } */
/* Future<void> deleteDocumentByFieldValue({required String fieldName, required dynamic fieldValue}) async {
    try {
      // Query the collection to find the document with the specified field value
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User_Employer')
          .where(fieldName, isEqualTo: fieldValue)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID
        String documentId = querySnapshot.docs.first.id;

        // Delete the document
        await FirebaseFirestore.instance
            .collection('User_Employer')
            .doc(documentId)
            .delete();

        print('Document with $fieldName: $fieldValue deleted successfully');
      } else {
        print('No document found with $fieldName: $fieldValue');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  } */
/* Future<void> adduserEmployer() async {
    final List<Map<String, dynamic>> userEmployer = [
      {
        'id': '1',
        'title': 'Software Engineer',
        'company': 'ABC Tech',
        'location': 'New York',
        'experience': '2 years',
        'education': 'B.E/B.SC (Computer science)',
        'salary': '3.5 lacs',
        'skills': 'Java, Python, Spring',
        'category': 'IT',
        'description': 'We are seeking a skilled Software Engineer to join our team at ABC Tech. The ideal candidate should have experience in software development and be proficient in programming languages such as Java, Python, or C++. Responsibilities include designing, developing, and maintaining software applications.',
        'site': 'http://www.abctechsoftwareengineer.com/',
        'email': 'john.doe@example.com',
        'phone': '+1 123-456-7890'
      },
      {
        'id': '2',
        'title': 'Marketing Manager',
        'company': 'XYZ Corp',
        'location': 'Los Angeles',
        'category': 'Marketing',
        'experience': '3-5 years',
        'education': 'Bachelor\'s degree in Marketing or related field',
        'salary': 'Negotiable',
        'skills': 'Strategic planning, Market research, Communication',
        'description': 'XYZ Corp is looking for a Marketing Manager to lead our marketing efforts in Los Angeles. The successful candidate will develop and implement marketing strategies to promote our products and services. Responsibilities include market research, advertising campaigns, and customer engagement.',
        'site': 'http://www.xyzcorpmarketingmanager.com/',
        'email': 'jane.smith@example.com',
        'phone': '+1 234-567-8901'
      },
      {
        'id': '3',
        'title': 'Sales Representative',
        'company': '123 Inc',
        'location': 'Chicago',
        'category': 'Sales',
        'experience': '1-3 years',
        'education': 'High school diploma required, Bachelor\'s degree preferred',
        'salary': 'Commission-based',
        'skills': 'Communication, Negotiation, Sales techniques',
        'description': '123 Inc is hiring a Sales Representative to drive sales in the Chicago area. The Sales Representative will identify and site potential customers, present products or services, and negotiate contracts. Strong communication and sales skills are required.',
        'site': 'http://www.123incsalesrepresentative.com/',
        'email': 'michael.johnson@example.com',
        'phone': '+1 345-678-9012'
      },
      {
        'id': '4',
        'title': 'Data Scientist',
        'company': 'DataWorks',
        'location': 'San Francisco',
        'category': 'IT',
        'experience': '3-5 years',
        'education': 'Master\'s degree in Computer Science or related field',
        'salary': 'Competitive',
        'skills': 'Machine Learning, Statistical Analysis, Data Mining',
        'description': 'DataWorks is seeking a talented Data Scientist to join our team in San Francisco. The ideal candidate will have strong analytical skills and experience in machine learning and statistical analysis. Responsibilities include data mining, modeling, and developing predictive algorithms.',
        'site': 'http://www.dataworksdatascientist.com/',
        'email': 'emily.brown@example.com',
        'phone': '+1 456-789-0123'
      },
      {
        'id': '5',
        'title': 'Product Manager',
        'company': 'Innovatech',
        'location': 'Boston',
        'category': 'Product Management',
        'experience': '5+ years',
        'education': 'Bachelor\'s degree in Business Administration or related field',
        'salary': 'Negotiable',
        'skills': 'Product Development, Strategy, Leadership',
        'description': 'Innovatech is looking for a Product Manager to oversee product development and strategy in Boston. The Product Manager will work closely with cross-functional teams to define product features, prioritize tasks, and launch new products. Strong leadership and communication skills are required.',
        'site': 'http://www.innovatechproductmanager.com/',
        'email': 'david.wilson@example.com',
        'phone': '+1 567-890-1234'
      },
      {
        'id': '6',
        'title': 'Graphic Designer',
        'company': 'Creative Solutions',
        'location': 'Seattle',
        'category': 'Design',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Graphic Design or related field',
        'salary': 'Based on experience',
        'skills': 'Adobe Creative Suite, Typography, Branding',
        'description': 'Creative Solutions is seeking a creative Graphic Designer to join our team in Seattle. The Graphic Designer will work on various design projects, including branding, advertising, and digital media. Proficiency in design software and a strong portfolio are required.',
        'site': 'http://www.creativesolutionsgraphicdesigner.com/',
        'email': 'sarah.johnson@example.com',
        'phone': '+1 678-901-2345'
      },
      {
        'id': '7',
        'title': 'HR Specialist',
        'company': 'PeopleFirst',
        'location': 'Denver',
        'category': 'Human Resources',
        'experience': '3-5 years',
        'education': 'Bachelor\'s degree in Human Resources or related field',
        'salary': 'Competitive',
        'skills': 'Employee Relations, Recruitment, Training',
        'description': 'PeopleFirst is hiring an HR Specialist to manage human resources functions in Denver. The HR Specialist will handle employee relations, recruitment, training, and compliance with labor laws. Strong interpersonal and organizational skills are required.',
        'site': 'http://www.peoplefirsthrspecialist.com/',
        'email': 'mark.thompson@example.com',
        'phone': '+1 789-012-3456'
      },
      {
        'id': '8',
        'title': 'Business Analyst',
        'company': 'Business Insights',
        'location': 'Austin',
        'category': 'Business',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Business Administration, Finance, or related field',
        'salary': 'Negotiable',
        'skills': 'Data Analysis, Business Intelligence, Report Writing',
        'description': 'Business Insights is seeking a Business Analyst to analyze business processes and make recommendations for improvement in Austin. The Business Analyst will gather and analyze data, create reports, and collaborate with stakeholders to implement solutions.',
        'site': 'http://www.businessinsightsbusinessanalyst.com/',
        'email': 'emma.garcia@example.com',
        'phone': '+1 901-234-5678'
      },
      {
        'id': '9',
        'title': 'Operations Manager',
        'company': 'Global Logistics',
        'location': 'Miami',
        'category': 'Operations',
        'experience': '5+ years',
        'education': 'Bachelor\'s degree in Logistics, Supply Chain Management, or related field',
        'salary': 'Competitive',
        'skills': 'Logistics Management, Supply Chain Optimization, Leadership',
        'description': 'Global Logistics is looking for an Operations Manager to oversee daily operations in Miami. The Operations Manager will manage logistics, supply chain, and distribution activities to ensure efficiency and customer satisfaction. Strong leadership and problem-solving skills are required.',
        'site': 'http://www.globallogisticsoperationsmanager.com/',
        'email': 'john.smith@example.com',
        'phone': '+1 234-567-8901'
      },
      {
        'id': '10',
        'title': 'Web Developer',
        'company': 'TechWave',
        'location': 'San Diego',
        'category': 'IT',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Computer Science or related field',
        'salary': 'Based on experience',
        'skills': 'HTML, CSS, JavaScript, Web Frameworks',
        'description': 'TechWave is seeking a Web Developer to design and develop web applications in San Diego. The Web Developer will work with front-end and back-end technologies to create responsive and user-friendly websites. Proficiency in HTML, CSS, JavaScript, and web frameworks is required.',
        'site': 'http://www.techwavewebdeveloper.com/s',
        'email': 'emily.davis@example.com',
        'phone': '+1 345-678-9012'
      },
      {
        'id': '11',
        'title': 'Content Writer',
        'company': 'WriteRight',
        'location': 'Portland',
        'category': 'Content',
        'experience': '1-3 years',
        'education': 'Bachelor\'s degree in English, Journalism, or related field',
        'salary': 'Based on experience',
        'skills': 'Content Creation, SEO, Research',
        'description': 'WriteRight is hiring a Content Writer to create engaging and informative content in Portland. The Content Writer will produce articles, blog posts, social media content, and other written materials. Strong writing and research skills are required.',
        'site': 'http://www.writerightcontentwriter.com/',
        'email': 'michael.brown@example.com',
        'phone': '+1 456-789-0123'
      },
      {
        'id': '12',
        'title': 'IT Support Specialist',
        'company': 'TechHelp',
        'location': 'Houston',
        'category': 'IT',
        'experience': '1-3 years',
        'education': 'Associate\'s degree in Information Technology or related field',
        'salary': 'Competitive',
        'skills': 'Technical Support, Troubleshooting, Customer Service',
        'description': 'TechHelp is seeking an IT Support Specialist to provide technical support to end-users in Houston. The IT Support Specialist will troubleshoot hardware and software issues, install and configure systems, and maintain IT infrastructure. Strong problem-solving and communication skills are required.',
        'site': 'http://www.techhelpitsupportspecialist.com/',
        'email': 'jessica.miller@example.com',
        'phone': '+1 567-890-1234'
      },
      {
        'id': '13',
        'title': 'Financial Analyst',
        'company': 'Finance Plus',
        'location': 'Dallas',
        'category': 'Finance',
        'experience': '3-5 years',
        'education': 'Bachelor\'s degree in Finance, Accounting, or related field',
        'salary': 'Competitive',
        'skills': 'Financial Analysis, Forecasting, Budgeting',
        'description': 'Finance Plus is looking for a Financial Analyst to analyze financial data and provide insights in Dallas. The Financial Analyst will prepare financial reports, forecasts, and budgets, and conduct financial analysis to support decision-making. Strong analytical and quantitative skills are required.',
        'site': 'http://www.financeplusfinancialanalyst.com/',
        'email': 'sarah.johnson@example.com',
        'phone': '+1 678-901-2345'
      },
      {
        'id': '14',
        'title': 'UX/UI Designer',
        'company': 'DesignHub',
        'location': 'Atlanta',
        'category': 'Design',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Design, Human-Computer Interaction, or related field',
        'salary': 'Based on experience',
        'skills': 'User Experience Design, User Interface Design, Prototyping',
        'description': 'DesignHub is seeking a UX/UI Designer to create intuitive and visually appealing user interfaces in Atlanta. The UX/UI Designer will collaborate with product managers and developers to design wireframes, prototypes, and user experiences. Proficiency in design tools and understanding of user-centered design principles are required.',
        'site': 'http://www.designhubuxuidesigner.com/',
        'email': 'daniel.wilson@example.com',
        'phone': '+1 789-012-3456'
      },
      {
        'id': '15',
        'title': 'Digital Marketer',
        'company': 'Market Masters',
        'location': 'Orlando',
        'category': 'Marketing',
        'experience': '3-5 years',
        'education': 'Bachelor\'s degree in Marketing, Communication, or related field',
        'salary': 'Competitive',
        'skills': 'Digital Marketing, Social Media Management, SEO',
        'description': 'Market Masters is hiring a Digital Marketer to develop and execute digital marketing strategies in Orlando. The Digital Marketer will manage social media campaigns, email marketing, SEO, and PPC advertising. Strong analytical and creative skills are required.',
        'site': 'http://www.marketmastersdigitalmarketer.com/',
        'email': 'jennifer.lee@example.com',
        'phone': '+1 890-123-4567'
      },
      {
        'id': '16',
        'title': 'Sales Manager',
        'company': 'SellWell',
        'location': 'Las Vegas',
        'category': 'Sales',
        'experience': '5+ years',
        'education': 'Bachelor\'s degree in Business Administration, Sales, or related field',
        'salary': 'Competitive',
        'skills': 'Sales Management, Leadership, Negotiation',
        'description': 'SellWell is looking for a Sales Manager to lead our sales team in Las Vegas. The Sales Manager will develop sales strategies, set targets, and oversee sales activities to achieve revenue goals. Strong leadership and negotiation skills are required.',
        'site': 'http://www.sellwellsalesmanager.com/',
        'email': 'david.brown@example.com',
        'phone': '+1 901-234-5678'
      },
      {
        'id': '17',
        'title': 'Network Engineer',
        'company': 'NetSecure',
        'location': 'Phoenix',
        'category': 'IT',
        'experience': '3-5 years',
        'education': 'Bachelor\'s degree in Computer Science, Information Technology, or related field',
        'salary': 'Competitive',
        'skills': 'Network Configuration, Troubleshooting, Network Security',
        'description': 'NetSecure is seeking a Network Engineer to design and maintain computer networks in Phoenix. The Network Engineer will install and configure network equipment, troubleshoot network issues, and ensure network security. Strong technical skills and knowledge of networking protocols are required.',
        'site': 'http://www.netsecurenetworkengineer.com/',
        'email': 'jessica.rodriguez@example.com',
        'phone': '+1 012-345-6789'
      },
      {
        'id': '18',
        'title': 'Customer Service Representative',
        'company': 'ClientFirst',
        'location': 'Philadelphia',
        'category': 'Customer Service',
        'experience': '1-3 years',
        'education': 'High school diploma or equivalent',
        'salary': 'Competitive',
        'skills': 'Customer Support, Communication, Problem-solving',
        'description': 'ClientFirst is hiring a Customer Service Representative to assist customers and resolve inquiries in Philadelphia. The Customer Service Representative will handle incoming calls, emails, and messages, and provide exceptional customer support. Strong communication and problem-solving skills are required.',
        'site': 'http://www.clientfirstcustomerservicerep.com/',
        'email': 'jessica.thompson@example.com',
        'phone': '+1 234-567-8901'
      },
      {
        'id': '19',
        'title': 'Recruiter',
        'company': 'TalentFind',
        'location': 'Charlotte',
        'category': 'Human Resources',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Human Resources, Psychology, or related field',
        'salary': 'Negotiable',
        'skills': 'Recruitment, Interviewing, Candidate Sourcing',
        'description': 'TalentFind is looking for a Recruiter to attract and hire qualified candidates in Charlotte. The Recruiter will source candidates, conduct interviews, and manage the hiring process. Strong interpersonal skills and knowledge of recruiting techniques are required.',
        'site': 'http://www.talentfindrecruiter.com/',
        'email': 'john.smith@example.com',
        'phone': '+1 345-678-9012'
      },
      {
        'id': '20',
        'title': 'Project Coordinator',
        'company': 'ManageRight',
        'location': 'Nashville',
        'category': 'Project Management',
        'experience': '2-4 years',
        'education': 'Bachelor\'s degree in Project Management, Business Administration, or related field',
        'salary': 'Competitive',
        'skills': 'Project Planning, Coordination, Stakeholder Management',
        'description': 'ManageRight is seeking a Project Coordinator to oversee project planning and execution in Nashville. The Project Coordinator will coordinate project activities, track progress, and communicate with stakeholders. Strong organizational and multitasking skills are required.',
        'site': 'http://www.managerightprojectcoordinator.com/',
        'email': 'emily.davis@example.com',
        'phone': '+1 678-901-2345'
      }
    ];
    for (var job in userEmployer) {
      String documentName = "${job['company']} - ${job['title']}";

      // Add job listing to User_Employer collection
      await FirebaseFirestore.instance.collection('User_Employer').doc(documentName).set(job);

      // Append job['id'] to userEmployers array in User_Employee document
      DocumentReference userEmployeeDocRef = FirebaseFirestore.instance.collection('User_Employee').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userEmployeeSnapshot = await transaction.get(userEmployeeDocRef);

        if (userEmployeeSnapshot.exists) {
          List<dynamic> userEmployers = userEmployeeSnapshot.get('userEmployers') ?? [];
          userEmployers.add(job['id']);
          transaction.update(userEmployeeDocRef, {'userEmployers': userEmployers});
        } else {
          transaction.set(userEmployeeDocRef, {'userEmployers': [job['id']]});
        }
      });
    }
  } */
