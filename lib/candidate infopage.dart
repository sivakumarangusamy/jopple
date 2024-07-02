import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jopple/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'Employee_Menu.dart';
import 'package:jopple/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

final List<String> _technicalSkillsController_tags = [];
final List<String> _softSkillsController_tags = [];
final List<String> _certificationsController_tags = [];
final List<String> _educationTrainingController_tags = [];

// For Personal Details
TextEditingController fullNameController = TextEditingController();
TextEditingController dobController = TextEditingController();
var selectedGender;
var selectedMaritalStatus;
var selectedNationality;
TextEditingController addressController = TextEditingController();
TextEditingController phoneNumberController = TextEditingController();
TextEditingController emailAddressController = TextEditingController();
TextEditingController jobInterestedController = TextEditingController();
var selectedLanguage;

bool fullNameInvalid = false;
bool dobInvalid = false;
bool genderInvalid = false;
bool maritalStatusInvalid = false;
bool nationalityInvalid = false;
bool addressInvalid = false;
bool phoneNumberInvalid = false;
bool emailAddressInvalid = false;
bool jobInterestedInvalid = false;
bool languageInvalid = false;

// For Skills & Qualifications
TextEditingController _technicalSkillsController = TextEditingController();
TextEditingController _softSkillsController = TextEditingController();
TextEditingController _certificationsController = TextEditingController();
TextEditingController _educationTrainingController = TextEditingController();
TextEditingController professionalAffiliationsController = TextEditingController();
TextEditingController volunteerExperienceController = TextEditingController();
TextEditingController aboutController = TextEditingController();

bool technicalSkillsInvalid = false;
bool softSkillsInvalid = false;
bool certificationsInvalid = false;
bool educationTrainingInvalid = false;

////////////////////////////////////////////////////////////////////////////////

List<TextEditingController> institutionNameControllers = [TextEditingController()];
List<TextEditingController> degreeControllers = [TextEditingController()];
List<String> selectedDegrees = [''];
List<TextEditingController> gpaControllers = [TextEditingController()];
List<TextEditingController> gradyearControllers = [TextEditingController()];
List<String> selectedMajors = [''];
List<TextEditingController> _honorsAwardsController = [TextEditingController()];
List<TextEditingController> _thesisProjectsController = [TextEditingController()];

// Initialize these lists as lists of lists to manage tags per education entry
List<List<String>> _honorsAwardsControllerTags = [[]];
List<List<String>> _thesisProjectsControllerTags = [[]];

List<bool> institutionNameInvalid = [false];
List<bool> degreeInvalid = [false];
List<bool> gpaInvalid = [false];
List<bool> gradyearInvalid = [false];
List<bool> majorInvalid = [false];
List<bool> _honorsAwardsInvalid = [false];
List<bool> _thesisProjectsInvalid = [false];

List<TextEditingController> companyNameControllers = [TextEditingController()];
List<TextEditingController> positionControllers = [TextEditingController()];
List<TextEditingController> jdDateControllers = [TextEditingController()];
List<TextEditingController> lwDateControllers = [TextEditingController()];
List<TextEditingController> locationControllers = [TextEditingController()];
List<TextEditingController> rflControllers = [TextEditingController()];
List<TextEditingController> askillsControllers = [TextEditingController()];

List<List<String>> _askillsControllerTags = [[]];

List<bool> companyNameInvalid = [false];
List<bool> positionInvalid = [false];
List<bool> jdDateInvalid = [false];
List<bool> lwDateInvalid = [false];
List<bool> locationInvalid = [false];
List<bool> rflInvalid = [false];
List<bool> askillsInvalid = [false];

FirestoreService firestoreService = FirestoreService();
final RegExp phoneRegex =
RegExp(r'^\+?\d{1,3}[-\s]?\d{3}[-\s]?\d{3}[-\s]?\d{4}$|^\d{10}$');
final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
final RegExp nameRegex = RegExp(r'^[a-zA-Z\s.]+$');
late TabController _tabController;
ScrollController _scrollController_1 = ScrollController();
ScrollController _scrollController_2 = ScrollController();
ScrollController _scrollController_3 = ScrollController();
ScrollController _scrollController_4 = ScrollController();
Color softSage = const Color(0xFFB2C9AB);
Color tab1_Color = Colors.red;
Color tab2_Color = Colors.red;
Color tab3_Color = Colors.red;
Color tab4_Color = Colors.red;
Color allTab_Color = Colors.red;
int _currentIndex = 0;
bool isShowingSnackBar = false;
bool isShowingSnackBar_2 = false;
bool tab1_validState = false;
bool tab2_validState = false;
bool tab3_validState = false;
bool tab4_validState = false;
bool dob_check = false;
bool switchEducation = false;
bool switchEmployment = false;
int expandedIndex = 0;
int expandedIndex_2 = 0;
int rough = 0;
String? filePath;
PlatformFile? pickedFile;
UploadTask? uploadTask;
bool? FileExist;

// late AnimationController _controller;

Future<void> _vibrate() async {
  bool hasVibrator = await Vibration.hasVibrator() ?? false;
  if (hasVibrator) {
    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
  }
}

class CandidateInfo_Tab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CandidateInfo(),
    );
  }
}

class CandidateInfo extends StatefulWidget {
  @override
  _CandidateInfoState createState() => _CandidateInfoState();
}

class _CandidateInfoState extends State<CandidateInfo> with SingleTickerProviderStateMixin {
  final DocumentReference _userDoc = FirebaseFirestore.instance.collection('User_Employee').doc(uid);

  bool validateFields() {
    bool allValid = true;
    bool invalid = false;
    print('Executed from _validation function : FileExist - $FileExist');

    if (fullNameController.text.isEmpty) {
      // Assuming you have a variable called fullNameInvalid
      fullNameInvalid = true;
      invalid = true;
    } else {
      fullNameInvalid = false;
    }

    if (isAtLeast18YearsOld(dobController.text) == false || dobController.text.isEmpty) {
      dobInvalid = true; // Assuming you have a variable called dobInvalid
      invalid = true;
    } else {
      dobInvalid = false;
    }

    if (selectedGender == null) {
      genderInvalid = true; // Assuming you have a variable called genderInvalid
      invalid = true;
    } else {
      genderInvalid = false;
    }

    if (selectedMaritalStatus == null) {
      maritalStatusInvalid = true; // Assuming you have a variable called maritalStatusInvalid
      invalid = true;
    } else {
      maritalStatusInvalid = false;
    }

    if (selectedNationality == null) {
      nationalityInvalid = true; // Assuming you have a variable called nationalityInvalid
      invalid = true;
    } else {
      nationalityInvalid = false;
    }

    if (addressController.text.isEmpty) {
      addressInvalid = true; // Assuming you have a variable called addressInvalid
      invalid = true;
    } else {
      addressInvalid = false;
    }

    if (phoneNumberController.text.isEmpty) {
      phoneNumberInvalid = true; // Assuming you have a variable called phoneNumberInvalid
      invalid = true;
    } else {
      phoneNumberInvalid = false;
    }

    if (emailAddressController.text.isEmpty) {
      emailAddressInvalid = true; // Assuming you have a variable called emailAddressInvalid
      invalid = true;
    } else {
      emailAddressInvalid = false;
    }

    if (jobInterestedController.text.isEmpty) {
      jobInterestedInvalid = true; // Assuming you have a variable called jobInterestedInvalid
      invalid = true;
    } else {
      jobInterestedInvalid = false;
    }

    if (selectedLanguage == null) {
      languageInvalid = true; // Assuming you have a variable called languageInvalid
      invalid = true;
    } else {
      languageInvalid = false;
    }

    if (FileExist == false) {
      invalid = true;
    }

    if (invalid) {
      /* ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              textAlign: TextAlign.center,
              'Not able to submit, Check fields',
              style: TextStyle(
                  fontWeight:
                  FontWeight.bold)),
          backgroundColor: Colors.red,
          behavior:
          SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          showCloseIcon: true,
          padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0.0),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10.0),
          ),
        ),
      ); */
      allValid = false;
    }
    return allValid;
  }

  bool validateFields_1() {
    bool allValid = true;
    for (int i = 0; i < institutionNameControllers.length; i++) {
      bool invalid = false;
      if (institutionNameControllers[i].text.isEmpty) {
        institutionNameInvalid[i] = true;
        invalid = true;
      } else {
        institutionNameInvalid[i] = false;
      }
      if (selectedDegrees[i].isEmpty) {
        degreeInvalid[i] = true;
        invalid = true;
      }
      else {
        degreeInvalid[i] = false;
      }
      if (gpaControllers[i].text.isEmpty || gpaControllers[i].text.contains(RegExp(r'[^0-9.]'))) {
        gpaInvalid[i] = true;
        invalid = true;
      } else {
        gpaInvalid[i] = false;
      }
      if (gradyearControllers[i].text.isEmpty) {
        gradyearInvalid[i] = true;
        invalid = true;
      } else {
        gradyearInvalid[i] = false;
      }
      if (selectedMajors[i].isEmpty) {
        majorInvalid[i] = true;
        invalid = true;
      }
      else {
        majorInvalid[i] = false;
      }

      if (invalid) {
        if (switchEducation == false) {
          /* ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                  textAlign: TextAlign.center,
                  'Not able to submit, Check fields',
                  style: TextStyle(
                      fontWeight:
                      FontWeight.bold)),
              backgroundColor: Colors.red,
              behavior:
              SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              showCloseIcon: true,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0.0),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0),
              ),
            ),
          ); */
          expandedIndex = i;
          allValid = false;
        }
      }
    }
    if (switchEducation) {
      allValid = true;
    }
    return allValid;
  }

  bool validateFields_2() {
    bool allValid = true;
    for (int i = 0; i < companyNameControllers.length; i++) {
      bool invalid = false;
      if (companyNameControllers[i].text.isEmpty) {
        companyNameInvalid[i] = true;
        invalid = true;
      } else {
        companyNameInvalid[i] = false;
      }
      if (positionControllers[i].text.isEmpty) {
        positionInvalid[i] = true;
        invalid = true;
      } else {
        positionInvalid[i] = false;
      }
      if (jdDateControllers[i].text.isEmpty) {
        jdDateInvalid[i] = true;
        invalid = true;
      } else {
        jdDateInvalid[i] = false;
      }
      bool isNotLessThanjdDate(String lwDateText) {
        if (lwDateText.isEmpty || jdDateControllers[i].text.isEmpty) {
          return false; // Or handle empty dates as per your logic
        }
        DateTime lwDate = DateFormat('dd-MM-yyyy').parse(lwDateText);
        DateTime jdDate = DateFormat('dd-MM-yyyy').parse(jdDateControllers[i].text);
        return lwDate.isAtSameMomentAs(jdDate) || lwDate.isAfter(jdDate);
      }
      if (isNotLessThanjdDate(lwDateControllers[i].text) == false || lwDateControllers[i].text.isEmpty) {
        lwDateInvalid[i] = true;
        invalid = true;
      } else {
        lwDateInvalid[i] = false;
      }
      if (locationControllers[i].text.isEmpty) {
        locationInvalid[i] = true;
        invalid = true;
      } else {
        locationInvalid[i] = false;
      }
      if (rflControllers[i].text.isEmpty) {
        rflInvalid[i] = true;
        invalid = true;
      } else {
        rflInvalid[i] = false;
      }
      /* if (_askillsControllerTags[i].isEmpty) {
      askillsInvalid[i] = true; // Assuming you have a variable called certificationsInvalid
      invalid = true;
    } else {
      askillsInvalid[i] = false;
    } */

      if (invalid) {
        if (switchEmployment == false) {
          /* ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                  textAlign: TextAlign.center,
                  'Not able to submit, Check fields',
                  style: TextStyle(
                      fontWeight:
                      FontWeight.bold)),
              backgroundColor: Colors.red,
              behavior:
              SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              showCloseIcon: true,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0.0),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10.0),
              ),
            ),
          ); */
          expandedIndex_2 = i;
          allValid = false;
        }
      }
    }
    if (switchEmployment) {
      allValid = true;
    }
    return allValid;
  }

  bool validateFields_3() {
    bool allValid = true;
    /* bool invalid = false;
  if (_technicalSkillsController_tags.isEmpty) {
    technicalSkillsInvalid = true; // Assuming you have a variable called technicalSkillsInvalid
    invalid = true;
  } else {
    technicalSkillsInvalid = false;
  }

  if (_softSkillsController_tags.isEmpty) {
    softSkillsInvalid = true; // Assuming you have a variable called softSkillsInvalid
    invalid = true;
  } else {
    softSkillsInvalid = false;
  }

  if (_certificationsController_tags.isEmpty) {
    certificationsInvalid = true; // Assuming you have a variable called certificationsInvalid
    invalid = true;
  } else {
    certificationsInvalid = false;
  }

  if (_educationTrainingController_tags.isEmpty) {
    educationTrainingInvalid = true; // Assuming you have a variable called educationTrainingInvalid
    invalid = true;
  } else {
    educationTrainingInvalid = false;
  }

  if (invalid) {
    allValid = false;
  } */
    return allValid;
  }

  Future<void> allValidCheck() async {
    print("1 - ${validateFields()}, 2 - ${validateFields_1()}, 3 -  ${validateFields_2()}");
    if (validateFields() && validateFields_1() && validateFields_2()) {
      await firestoreService.updateField_User_Employee(fieldName: 'FetchValid', newValue: true);
      await firestoreService.updateField_User_Employee(fieldName: 'title', newValue: jobInterestedController.text);
      await firestoreService.updateField_User_Employee(fieldName: 'name', newValue: fullNameController.text);
      await firestoreService.updateField_User_Employee(fieldName: 'location', newValue: addressController.text);

    }
    else {
      await firestoreService.updateField_User_Employee(fieldName: 'FetchValid', newValue: false);
    }
  }

  String Allcheck () {
    String allcheck = "";
    validateFields() == false ? allcheck = "Please check for invalid fields\nin personal details section" :
    validateFields_1() == false ? allcheck = "Please check for invalid fields\nin education details section" :
    validateFields_2() == false ? allcheck = "Please check for invalid fields\nin work experience section" :
    validateFields_3() == false ? allcheck = "Please check for invalid fields\nin skills section" :
    "Please validate all the fields";
    return allcheck;
  }

  void fetch_personal_details() {
    print("********* fetch_personal_details *********");
    firestoreService.addPersonalDetails(fullNameController.text,
        dobController.text,
        selectedGender,
        selectedMaritalStatus,
        selectedNationality,
        addressController.text,
        phoneNumberController.text,
        emailAddressController.text,
        jobInterestedController.text,
        selectedLanguage);
  }

  void fetch_education_details() {
    print("********* fetch_education_details *********");
    List<String> institutionNames = institutionNameControllers.map((controller) => controller.text).toList();
    List<String> degrees = selectedDegrees;
    List<String> gpas = gpaControllers.map((controller) => controller.text).toList();
    List<String> graduationYears = gradyearControllers.map((controller) => controller.text).toList();
    List<String> majors = selectedMajors;
    List<List<String>> honorsAwards = _honorsAwardsControllerTags;
    List<List<String>> thesisProjects = _thesisProjectsControllerTags;
    firestoreService.addEducationDetails(
      institutionNames,
      degrees,
      gpas,
      graduationYears,
      majors,
      honorsAwards,
      thesisProjects,
    );
  }

  void fetch_employment_details() {
    print("********* fetch_employment_details *********");
    List<String> companyNames = companyNameControllers.map((controller) => controller.text).toList();
    List<String> positions = positionControllers.map((controller) => controller.text).toList();
    List<String> jdDates = jdDateControllers.map((controller) => controller.text).toList();
    List<String> lwDates = lwDateControllers.map((controller) => controller.text).toList();
    List<String> locations = locationControllers.map((controller) => controller.text).toList();
    List<String> rfls = rflControllers.map((controller) => controller.text).toList();
    List<List<String>> askills = _askillsControllerTags;
    firestoreService.addEmploymentDetails(
      companyNames,
      positions,
      jdDates,
      lwDates,
      locations,
      rfls,
      askills,
    );
  }

  void fetch_skills_details() {
    print("********* fetch_skills_details *********");
    List<String> technicalSkills = _technicalSkillsController_tags;
    List<String> softSkills = _softSkillsController_tags;
    List<String> certifications = _certificationsController_tags;
    List<String> educationTraining = _educationTrainingController_tags;
    String professionalAffiliations = professionalAffiliationsController.text;
    String volunteerExperience = volunteerExperienceController.text;
    String about = aboutController.text;

    firestoreService.addSkills(
      technicalSkills,
      softSkills,
      certifications,
      educationTraining,
      professionalAffiliations,
      volunteerExperience,
      about,
    );
  }

  bool isAtLeast18YearsOld(String dobText) {

    if (dobText.isEmpty) {
      return false; // Handle empty date string as per your logic
    }

    // Parse the date of birth from the given string
    DateTime dob = DateFormat('dd-MM-yyyy').parse(dobText);

    // Get the current date
    DateTime now = DateTime.now();

    // Calculate the date 18 years ago from now
    DateTime eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    // Check if the date of birth is before or on the date 18 years ago
    return dob.isBefore(eighteenYearsAgo) || dob.isAtSameMomentAs(eighteenYearsAgo);
  }

  void _addTag(String tag, TextEditingController controller) {
    if (tag.trim().isNotEmpty) {
      String lowercaseTag = tag.toLowerCase();
      List<String> tagsList;
      if (controller == _technicalSkillsController) {
        tagsList = _technicalSkillsController_tags;
      } else if (controller == _softSkillsController) {
        tagsList = _softSkillsController_tags;
      } else if (controller == _certificationsController) {
        tagsList = _certificationsController_tags;
      } else if (controller == _educationTrainingController) {
        tagsList = _educationTrainingController_tags;
      } else {
        // Handle other controllers if needed
        return;
      }

      if (!tagsList.map((t) => t.toLowerCase()).contains(lowercaseTag)) {
        setState(() {
          tagsList.add(tag);
          controller.clear();
        });
      }
    }
  }

  void _deleteTag(int index, TextEditingController controller) {
    List<String> tagsList;
    if (controller == _technicalSkillsController) {
      tagsList = _technicalSkillsController_tags;
    } else if (controller == _softSkillsController) {
      tagsList = _softSkillsController_tags;
    } else if (controller == _certificationsController) {
      tagsList = _certificationsController_tags;
    } else if (controller == _educationTrainingController) {
      tagsList = _educationTrainingController_tags;
    } else {
      // Handle other controllers if needed
      return;
    }

    setState(() {
      tagsList.removeAt(index);
    });
  }

  Color _getIndicatorColor(int currentIndex) {
    if (currentIndex == 0) {
      return tab1_Color;
    } else if (currentIndex == 1) {
      return tab2_Color;
    } else if (currentIndex == 2) {
      return tab3_Color;
    } else if (currentIndex == 3) {
      return tab4_Color;
    } else {
      return Colors.transparent;
    }
  }

  Color _getallTabColor() {
    if (tab1_Color == Colors.green && tab2_Color == Colors.green && tab3_Color == Colors.green && tab4_Color == Colors.green) {
      return Colors.green;
    }
    else {
      return allTab_Color;
    }
  }

  Color? _changeallTabColor() {
    tab1_Color = Colors.green;
    tab2_Color = Colors.green;
    tab3_Color = Colors.green;
    tab4_Color = Colors.green;
    tab1_validState = true;
    tab2_validState = true;
    tab3_validState = true;
    tab4_validState = true;
    return null;
  }

  Color? _verifyallTabColor() {
    allTab_Color = Colors.red;
    if (validateFields() == false) { tab1_Color = Colors.red; tab1_validState = false; }
    if (validateFields_1() == false) { tab2_Color = Colors.red; tab2_validState = false; }
    if (validateFields_2() == false) { tab3_Color = Colors.red; tab3_validState = false; }
    return null;
  }

  void _scrollToTop(ScrollController scrollController) {
    scrollController.jumpTo(0.0);
    /* scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ); */
  }

  void _scrollToBottom(ScrollController scrollController) {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    /* scrollController.animateTo(
    scrollController.position.maxScrollExtent,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  ); */
  }

  void addEducation() {
    /* if (!validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            alignment: Alignment.center,
            child: Text(
              "Please correct the fields to proceed adding new education.",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.red,
          elevation: 6.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } */

    setState(() {
      institutionNameControllers.add(TextEditingController());
      degreeControllers.add(TextEditingController());
      selectedDegrees.add('');
      gpaControllers.add(TextEditingController());
      gradyearControllers.add(TextEditingController());
      selectedMajors.add('');
      _honorsAwardsController.add(TextEditingController());
      _thesisProjectsController.add(TextEditingController());

      // Add a new list for tags for the new education entry
      _honorsAwardsControllerTags.add([]);
      _thesisProjectsControllerTags.add([]);

      institutionNameInvalid.add(false);
      degreeInvalid.add(false);
      gpaInvalid.add(false);
      gradyearInvalid.add(false);
      majorInvalid.add(false);
      _honorsAwardsInvalid.add(false);
      _thesisProjectsInvalid.add(false);
      expandedIndex = institutionNameControllers.length - 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController_2.animateTo(
          _scrollController_2.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void deleteEducation(int index) {
    setState(() {
      institutionNameControllers.removeAt(index).dispose();
      degreeControllers.removeAt(index).dispose();
      selectedDegrees.removeAt(index);
      gpaControllers.removeAt(index).dispose();
      gradyearControllers.removeAt(index).dispose();
      selectedMajors.removeAt(index);
      _honorsAwardsController.removeAt(index).dispose();
      _thesisProjectsController.removeAt(index).dispose();

      // Remove the tags list for the deleted entry
      _honorsAwardsControllerTags.removeAt(index);
      _thesisProjectsControllerTags.removeAt(index);

      institutionNameInvalid.removeAt(index);
      degreeInvalid.removeAt(index);
      gpaInvalid.removeAt(index);
      gradyearInvalid.removeAt(index);
      majorInvalid.removeAt(index);
      _honorsAwardsInvalid.removeAt(index);
      _thesisProjectsInvalid.removeAt(index);

      if (expandedIndex == index) {
        expandedIndex = -1;
      } else if (expandedIndex > index) {
        expandedIndex--;
      }
    });
  }

  void toggleExpansion(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = -1;
      } else {
        expandedIndex = index;
      }
    });
  }

  void addWork() {
    /* if (!validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            alignment: Alignment.center,
            child: Text(
              "Please correct the fields to proceed adding new education.",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.red,
          elevation: 6.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } */

    setState(() {
      companyNameControllers.add(TextEditingController());
      positionControllers.add(TextEditingController());
      jdDateControllers.add(TextEditingController());
      lwDateControllers.add(TextEditingController());
      locationControllers.add(TextEditingController());
      rflControllers.add(TextEditingController());
      askillsControllers.add(TextEditingController());

      // Add a new list for tags for the new education entry
      _askillsControllerTags.add([]);

      companyNameInvalid.add(false);
      positionInvalid.add(false);
      jdDateInvalid.add(false);
      lwDateInvalid.add(false);
      locationInvalid.add(false);
      rflInvalid.add(false);
      askillsInvalid.add(false);
      expandedIndex_2 = companyNameControllers.length - 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController_3.animateTo(
          _scrollController_3.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void deleteWork(int index) {
    setState(() {
      companyNameControllers.removeAt(index).dispose();
      positionControllers.removeAt(index).dispose();
      jdDateControllers.removeAt(index).dispose();
      lwDateControllers.removeAt(index).dispose();
      locationControllers.removeAt(index).dispose();
      rflControllers.removeAt(index).dispose();
      askillsControllers.removeAt(index).dispose();

      // Remove the tags list for the deleted entry
      _askillsControllerTags.removeAt(index);

      companyNameInvalid.removeAt(index);
      positionInvalid.removeAt(index);
      jdDateInvalid.removeAt(index);
      lwDateInvalid.removeAt(index);
      locationInvalid.removeAt(index);
      rflInvalid.removeAt(index);
      askillsInvalid.removeAt(index);

      if (expandedIndex_2 == index) {
        expandedIndex_2 = -1;
      } else if (expandedIndex_2 > index) {
        expandedIndex_2--;
      }
    });
  }

  void toggleExpansion_2(int index) {
    setState(() {
      if (expandedIndex_2 == index) {
        expandedIndex_2 = -1;
      } else {
        expandedIndex_2 = index;
      }
    });
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
    FocusScope.of(context).unfocus();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    _scrollToBottom(_scrollController_1);
    _doesFileExist();
    final FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],);
    if (result != null && result.files.single.path != null) {
      setState(() {
        pickedFile = result.files.single;
        filePath = pickedFile!.path;
      });
      print(filePath);
      print(pickedFile);
      print("******* #### Start #### *******");
      await _uploadFile();
      print("******* #### End #### *******");
    } else {
      print('No file selected or path is null');
    }
  }

  Future<void> _uploadFile() async {
    if (pickedFile == null || pickedFile!.path == null) {
      print('No file picked or file path is null');
      return;
    }

    // Check if the file extension is allowed
    List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];
    String extension = pickedFile!.path!.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      _showSnackBar('  File type not supported',Colors.red);
      // await Future.delayed(Duration(seconds: 3));
      print('File type not supported');
      _doesFileExist();
      return;
    }

    final path = 'Jopple_Storage_Files/${uid} - Resume';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      setState(() {
        uploadTask = ref.putFile(file);
      });
      print("Upload started...");
      uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      }, onError: (e) {
        print('Upload failed: $e');
      });
      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Upload completed successfully');
      _scrollToBottom(_scrollController_1);
      _showSnackBar('  Resume added successfully',Colors.green);
      print('Download Link: $urlDownload');
      _doesFileExist();
    } catch (e) {
      _doesFileExist();
      print('Upload failed: $e');
    }
  }

  void _doesFileExist() {
    firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: false);
    final storageRef = FirebaseStorage.instance.ref().child('Jopple_Storage_Files');
    storageRef.listAll().then((result) {
      String temp_name = '${uid} - Resume';
      for (var item in result.items) {
        print('${item.name} == $temp_name');
        if (item.name == temp_name) {
          firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: true);
        } else {
          firestoreService.updateField_User_Employee(fieldName: 'ResumeExist', newValue: false);
        }
      }
    });
    // print('Executed from _doesFileExist function : FileExist - $FileExist');
  }

  Widget customBackButton(BuildContext context) {
    return SizedBox(
      child: TextButton(
        onPressed: () {
          _doesFileExist();
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
    _doesFileExist();
    _verifyallTabColor();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController_1 = ScrollController();
    _scrollController_2 = ScrollController();
    _scrollController_3 = ScrollController();
    _scrollController_4 = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _verifyallTabColor();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController_1.dispose();
    _scrollController_2.dispose();
    _scrollController_3.dispose();
    _scrollController_4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    List<Widget> tabViews = [
      Scrollbar(
        controller: _scrollController_1, // Provide the scroll controller
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userDoc.snapshots(),
          builder: (context, snapshot) {
            var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            FileExist = data['ResumeExist'] ?? false;
            Map<String, dynamic> personalDetails = {};
            if (data.containsKey('Personal Details') && data['Personal Details'] is Map<String, dynamic>) {
              personalDetails = data['Personal Details'] as Map<String, dynamic>;
            }
            String? getValueFromPersonalDetails(Map<String, dynamic> personalDetails, String targetKey) {
              String? targetValue = personalDetails.containsKey(targetKey) ? personalDetails[targetKey] : 'Value not found';
              return targetValue;
            }
          return GestureDetector(
            onTap: () {
              print(getValueFromPersonalDetails(personalDetails,'Full Name'));
              FocusScope.of(context).unfocus();
            },
            onVerticalDragUpdate: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: _getallTabColor(), width: 7),
                    // Reduce the width here
                    bottom: const BorderSide(color: Colors.black, width: 0),
                    // Reduce the width here
                    left: const BorderSide(color: Colors.black, width: 0),
                    // Maintain the original width
                    right: const BorderSide(color: Colors.black, width: 0)),
                // Maintain the original width
                borderRadius: const BorderRadius.all(Radius.zero),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController_1,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: 15.0, left: 15, right: 15, bottom: 0),
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, bottom: 20.0, right: 14.0, left: 14.0),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        ' Personal Information :',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22.0,
                                          fontFamily: 'anta',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: fullNameController,
                                    onChanged: (value) {
                                      setState(() {
                                        fullNameController.text = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      errorText: /* tab1_subState && */fullNameController
                                          .text.isEmpty ?
                                      'Full name is required' :
                                      (!nameRegex.hasMatch(fullNameController.text))
                                          ? 'Name contains invalid characters'
                                          : null,
                                      labelText: 'Full Name',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      prefixIcon: const Icon(Icons.person),
                                      hintText: 'Enter complete legal name',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: dobController,
                                    // Controller for handling text input
                                    onChanged: (value) { // Update the controller's text when input changes
                                      setState(() {
                                        dobController.text = value;
                                      });
                                    },
                                    readOnly: true,
                                    // Prevent manual text input
                                    onTap: () async { // Show date picker when tapped
                                      DateTime? _picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                      );
                                      if (_picked !=
                                          null) { // Update text field when date is picked
                                        setState(() {
                                          final formattedDate = DateFormat(
                                              'dd-MM-yyyy').format(_picked);
                                          dobController.text = formattedDate;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Date of Birth',
                                      // Label for the text field
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: dobController.text.isEmpty
                                          ? 'Date of Birth is required'
                                          : (() {
                                        try {
                                          // Attempt to parse the date from text
                                          DateTime dob = DateFormat('dd-MM-yyyy')
                                              .parse(dobController.text);
                                          DateTime now = DateTime.now();
                                          int age = now.year - dob.year;
                                          if (now.month < dob.month ||
                                              (now.month == dob.month &&
                                                  now.day < dob.day)) {
                                            age--;
                                          }
                                          return age < 18
                                              ? 'Must be at least 18 years old'
                                              : null;
                                        } catch (e) {
                                          // Handle case where date cannot be parsed
                                          return 'Invalid date format';
                                        }
                                      })(),
                                      filled: false,
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      hintText: 'Enter your D.O.B',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify border color
                                          width: 2.0, // Specify border width
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  DropdownButtonFormField(
                                    value: selectedGender,
                                    items: [
                                      'Male',
                                      'Female',
                                      'Non-binary',
                                      'Prefer not to say'
                                    ]
                                        .map<DropdownMenuItem<String>>((
                                        String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(labelText: 'Gender',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: selectedGender == null
                                          ? 'Gender is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.bloodtype),
                                      hintText: 'Choose your gender',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  DropdownButtonFormField(
                                    value: selectedMaritalStatus,
                                    items: [
                                      'Single',
                                      'Married',
                                      'Divorced',
                                      'Widowed'
                                    ]
                                        .map<DropdownMenuItem<String>>((
                                        String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Marital Status',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: selectedMaritalStatus == null
                                          ? 'Marital status is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.people),
                                      hintText: 'Select marital status',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMaritalStatus = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  DropdownButtonFormField(
                                    value: selectedNationality,
                                    items: [
                                      'Afghan',
                                      'Albanian',
                                      'Algerian',
                                      'American',
                                      'Andorran',
                                      'Angolan',
                                      'Antiguans',
                                      'Argentinean',
                                      'Armenian',
                                      'Australian',
                                      'Austrian',
                                      'Azerbaijani',
                                      'Bahamian',
                                      'Bahraini',
                                      'Bangladeshi',
                                      'Barbadian',
                                      'Barbudans',
                                      'Batswana',
                                      'Belarusian',
                                      'Belgian',
                                      'Belizean',
                                      'Beninese',
                                      'Bhutanese',
                                      'Bolivian',
                                      'Bosnian',
                                      'Brazilian',
                                      'British',
                                      'Bruneian',
                                      'Bulgarian',
                                      'Burkinabe',
                                      'Burmese',
                                      'Burundian',
                                      'Cambodian',
                                      'Cameroonian',
                                      'Canadian',
                                      'Cape Verdean',
                                      'Central African',
                                      'Chadian',
                                      'Chilean',
                                      'Chinese',
                                      'Colombian',
                                      'Comoran',
                                      'Congolese',
                                      'Costa Rican',
                                      'Croatian',
                                      'Cuban',
                                      'Cypriot',
                                      'Czech',
                                      'Danish',
                                      'Djibouti',
                                      'Dominican',
                                      'Dutch',
                                      'East Timorese',
                                      'Ecuadorean',
                                      'Egyptian',
                                      'Emirian',
                                      'Equatorial Guinean',
                                      'Eritrean',
                                      'Estonian',
                                      'Ethiopian',
                                      'Fijian',
                                      'Filipino',
                                      'Finnish',
                                      'French',
                                      'Gabonese',
                                      'Gambian',
                                      'Georgian',
                                      'German',
                                      'Ghanaian',
                                      'Greek',
                                      'Grenadian',
                                      'Guatemalan',
                                      'Guinea-Bissauan',
                                      'Guinean',
                                      'Guyanese',
                                      'Haitian',
                                      'Herzegovinian',
                                      'Honduran',
                                      'Hungarian',
                                      'I-Kiribati',
                                      'Icelander',
                                      'Indian',
                                      'Indonesian',
                                      'Iranian',
                                      'Iraqi',
                                      'Irish',
                                      'Israeli',
                                      'Italian',
                                      'Ivorian',
                                      'Jamaican',
                                      'Japanese',
                                      'Jordanian',
                                      'Kazakhstani',
                                      'Kenyan',
                                      'Kittian and Nevisian',
                                      'Kuwaiti',
                                      'Kyrgyz',
                                      'Laotian',
                                      'Latvian',
                                      'Lebanese',
                                      'Liberian',
                                      'Libyan',
                                      'Liechtensteiner',
                                      'Lithuanian',
                                      'Luxembourger',
                                      'Macedonian',
                                      'Malagasy',
                                      'Malawian',
                                      'Malaysian',
                                      'Maldivan',
                                      'Malian',
                                      'Maltese',
                                      'Marshallese',
                                      'Mauritanian',
                                      'Mauritian',
                                      'Mexican',
                                      'Micronesian',
                                      'Moldovan',
                                      'Monacan',
                                      'Mongolian',
                                      'Moroccan',
                                      'Mosotho',
                                      'Motswana',
                                      'Mozambican',
                                      'Namibian',
                                      'Nauruan',
                                      'Nepalese',
                                      'New Zealander',
                                      'Nicaraguan',
                                      'Nigerian',
                                      'Nigerien',
                                      'North Korean',
                                      'Northern Irish',
                                      'Norwegian',
                                      'Omani',
                                      'Pakistani',
                                      'Palauan',
                                      'Panamanian',
                                      'Papua New Guinean',
                                      'Paraguayan',
                                      'Peruvian',
                                      'Polish',
                                      'Portuguese',
                                      'Qatari',
                                      'Romanian',
                                      'Russian',
                                      'Rwandan',
                                      'Saint Lucian',
                                      'Salvadoran',
                                      'Samoan',
                                      'San Marinese',
                                      'Sao Tomean',
                                      'Saudi',
                                      'Scottish',
                                      'Senegalese',
                                      'Serbian',
                                      'Seychellois',
                                      'Sierra Leonean',
                                      'Singaporean',
                                      'Slovakian',
                                      'Slovenian',
                                      'Solomon Islander',
                                      'Somali',
                                      'South African',
                                      'South Korean',
                                      'Spanish',
                                      'Sri Lankan',
                                      'Sudanese',
                                      'Surinamer',
                                      'Swazi',
                                      'Swedish',
                                      'Swiss',
                                      'Syrian',
                                      'Taiwanese',
                                      'Tajik',
                                      'Tanzanian',
                                      'Thai',
                                      'Togolese',
                                      'Tongan',
                                      'Trinidadian or Tobagonian',
                                      'Tunisian',
                                      'Turkish',
                                      'Tuvaluan',
                                      'Ugandan',
                                      'Ukrainian',
                                      'Uruguayan',
                                      'Uzbekistani',
                                      'Venezuelan',
                                      'Vietnamese',
                                      'Welsh',
                                      'Yemenite',
                                      'Zambian',
                                      'Zimbabwean'
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Nationality',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: selectedNationality == null
                                          ? 'Nationality is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.flag),
                                      hintText: 'Choose nationality',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNationality = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: addressController,
                                    onChanged: (value) {
                                      setState(() {
                                        addressController.text = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Current city',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: addressController.text.isEmpty
                                          ? 'Current city is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.home),
                                      hintText: 'Enter the current city',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: phoneNumberController,
                                    onChanged: (value) {
                                      setState(() {
                                        phoneNumberController.text = value;
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: phoneNumberController.text.isEmpty
                                          ?
                                      'Phone number is required'
                                          :
                                      phoneNumberController.text.length < 10 ?
                                      'Please enter the full number' :
                                      !phoneRegex.hasMatch(
                                          phoneNumberController.text) ?
                                      'Invalid phone number' : null,
                                      prefixIcon: const Icon(Icons.phone),
                                      hintText: 'Provide contact phone number',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: emailAddressController,
                                    onChanged: (value) {
                                      setState(() {
                                        emailAddressController.text = value;
                                      });
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: emailAddressController.text.isEmpty
                                          ?
                                      'Email address is required'
                                          :
                                      !emailRegex.hasMatch(
                                          emailAddressController.text)
                                          ?
                                      'Please enter full valid email address'
                                          : null,
                                      prefixIcon: const Icon(Icons.email),
                                      hintText: 'Enter your email address',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  DropdownButtonFormField(
                                    value: selectedLanguage,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select an option'; // Error message when no option is selected
                                      }
                                      return null; // Return null if validation passes
                                    },
                                    items: [
                                      'English',
                                      'Spanish',
                                      'French',
                                      'German',
                                      'Chinese',
                                      'Hindi',
                                      'Arabic',
                                      'Bengali',
                                      'Russian',
                                      'Portuguese',
                                      'Urdu',
                                      'Indonesian',
                                      'Turkish',
                                      'Italian',
                                      'Japanese',
                                      'Vietnamese',
                                      'Korean',
                                      'Tamil',
                                      'Telugu',
                                      'Marathi',
                                      'Thai',
                                      'Persian',
                                      'Malay',
                                      'Ukrainian',
                                      'Romanian',
                                      'Dutch',
                                      'Greek',
                                      'Swedish',
                                      'Polish',
                                      'Punjabi',
                                      'Finnish',
                                      'Hungarian',
                                      'Czech',
                                      'Slovak',
                                      'Norwegian',
                                      'Danish',
                                      'Lithuanian',
                                      'Bulgarian',
                                      'Hebrew',
                                      'Croatian',
                                      'Serbian',
                                      'Slovenian',
                                      'Latvian',
                                      'Estonian',
                                      'Kurdish',
                                      'Albanian',
                                      'Macedonian',
                                      'Montenegrin',
                                      'Bosnian',
                                      'Luxembourgish',
                                      'Irish',
                                      'Maltese',
                                      'Icelandic',
                                      'Welsh',
                                      'Basque',
                                      'Faroese',
                                      'Galician',
                                      'Catalan',
                                      'Corsican',
                                      'Breton',
                                      'Scottish Gaelic',
                                      'Manx',
                                      'Cornish',
                                      'Azerbaijani',
                                      'Armenian',
                                      'Georgian',
                                      'Kazakh',
                                      'Uzbek',
                                      'Turkmen',
                                      'Kyrgyz',
                                      'Tajik',
                                      'Tatar',
                                      'Bashkir',
                                      'Chechen',
                                      'Chuvash',
                                      'Ingush',
                                      'Komi',
                                      'Kabardian',
                                      'Abkhaz',
                                      'Ossetian',
                                      'Karachay-Balkar',
                                      'Adyghe',
                                      'Lezgian',
                                      'Dargin',
                                      'Avar',
                                      'Lak',
                                      'Nogai',
                                      'Circassian',
                                      'Rusyn',
                                      'Karelian',
                                      'Vepsian',
                                      'Mordvin',
                                      'Mari',
                                      'Udmurt',
                                      'Erzya',
                                      'Moksha',
                                      'Komi-Permyak',
                                      'Komi-Zyrian',
                                      'Khanty',
                                      'Mansi',
                                      'Nenets',
                                      'Selkup',
                                      'Nganasan',
                                      'Enets',
                                      'Chukchi',
                                      'Koryak',
                                      'Itelmen',
                                      'Eskimo-Aleut languages',
                                      'Aleut',
                                      'Yupik',
                                      'Siberian Yupik',
                                      'Naukan Yupik',
                                      'Chukotko',
                                      'Chukchi',
                                      'Koryak',
                                      'Alutor',
                                      'Kerek',
                                      'Kamchadal',
                                      'Itelmen',
                                      'Palaihnihan',
                                      'Chukot',
                                      'Eskimo languages',
                                      'Inuit languages',
                                      'Greenlandic',
                                      'Inuktitut',
                                      'Iñupiatun',
                                      'Yupik languages',
                                      'Siberian Yupik',
                                      'Naukan Yupik',
                                      'Sirenik Yupik',
                                      'Siberian Yupik',
                                      'Aleutian',
                                      'Yuit',
                                      'Sugpiaq',
                                      'Eyak',
                                      'Haida',
                                      'Tlingit',
                                      'Kutenai',
                                      'Coast Tsimshian',
                                      'Nisga’a',
                                      'Gitxsan',
                                      'Nuxalk',
                                      'Tsilhqot’in',
                                      'Southern Tsimshian',
                                      'Haisla',
                                      'Northwest Caucasianzzx',
                                      'Abkhaz',
                                      'Adyghe',
                                      'Kabardian',
                                      'Ubykh',
                                      'Rutul',
                                      'Lezgian',
                                      'Tabasaran',
                                      'Aghul',
                                      'Tsez',
                                      'Bats',
                                      'Ingush',
                                      'Khariboli',
                                      'Lingala',
                                      'Shona',
                                      'Sinhala',
                                      'Somali',
                                      'Swahili',
                                      'Tigrinya',
                                      'Tswana',
                                      'Wolof',
                                      'Yoruba',
                                      'Zulu',
                                      'Afrikaans',
                                      'Amharic',
                                      'Bemba',
                                      'Chichewa',
                                      'Hausa',
                                      'Igbo',
                                      'Kikuyu',
                                      'Kinyarwanda',
                                      'Kirundi',
                                      'Luganda',
                                      'Malagasy',
                                      'Oromo',
                                      'Sesotho',
                                      'Setswana',
                                      'Shona',
                                      'SiSwati',
                                      'Sango',
                                      'Tigrinya',
                                      'Tsonga',
                                      'Urundi',
                                      'Venda',
                                      'Xhosa',
                                      'Zande',
                                      'Zulu'
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Preferred Language',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: selectedLanguage == null
                                          ? 'Language is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.language),
                                      hintText: 'Select your Language',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: jobInterestedController,
                                    onChanged: (value) {
                                      setState(() {
                                        jobInterestedController.text = value;
                                      });
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Job looking for?',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      errorText: jobInterestedController.text.isEmpty
                                          ?
                                      'Job Interested is required'
                                          : null,
                                      prefixIcon: const Icon(Icons.app_registration),
                                      hintText: 'Enter your interested job domain name',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 29.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          _vibrate();
                                          _pickFile();
                                          _doesFileExist();
                                          _scrollToBottom(_scrollController_1);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: data['ResumeExist'] == true ?
                                          Colors.green : Colors.grey[500],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.attach_file,
                                                color: Colors.black),
                                            // Add attachment icon
                                            SizedBox(width: 8),
                                            // Add some space between icon and text
                                            Flexible(
                                              child: Text(
                                                'Attach Resume',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                                // Handle text overflow
                                                maxLines: 1, // Limit text to a single line
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    data['ResumeExist'] == true
                                        ? Icon(
                                        Icons.verified_rounded, color: Colors.green) :
                                    Icon(Icons.verified_rounded, color: Colors.grey)
                                  ],
                                ),
                              ),
                              /* if (filePath != null) Text('File path: $filePath',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                  ), */
                                Visibility(
                                  visible: uploadTask != null,
                                  child: StreamBuilder<TaskSnapshot>(
                                    stream: uploadTask?.snapshotEvents,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Transform.scale(
                                            scale: 0.5,
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Text(
                                            'Upload Error: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        final progress = snapshot.data!
                                            .bytesTransferred /
                                            snapshot.data!.totalBytes;
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: [
                                            SizedBox(height: 10),
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  child: Container(
                                                    width: width * 0.6,
                                                    height: 17,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 2),
                                                      // borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: LinearProgressIndicator(
                                                      value: progress,
                                                      color: Colors.green,
                                                      backgroundColor: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child: Text(
                                                      '${(progress * 100)
                                                          .toStringAsFixed(0)} %',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: width * 0.4,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(color: Colors.black, width: 3),
                                backgroundColor: Colors.green[500],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ), onPressed: () async {
                                _doesFileExist();
                              _vibrate();
                              allValidCheck();
                              data['ResumeExist'] == true ? SizedBox() :
                              _showSnackBar('  Resume not attached', Colors.red);
                              if (validateFields()) {
                                fetch_personal_details();
                                setState(() {
                                  tab1_Color = Colors.green;
                                  tab1_validState = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Personal details submitted.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                _tabController.animateTo(1);
                              }
                              else {
                                _scrollToTop(_scrollController_1);
                                setState(() {
                                  tab1_Color = Colors.red;
                                  tab1_validState = false;
                                });
                              }
                            },
                              child: const Text(
                                "Proceed",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        ),
      ),
      Scrollbar(
        controller: _scrollController_2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onVerticalDragUpdate: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: _getallTabColor(), width: 7),
                        bottom: const BorderSide(color: Colors.black, width: 0),
                        left: const BorderSide(color: Colors.black, width: 0),
                        right: const BorderSide(color: Colors.black, width: 0),
                      ),
                      borderRadius: const BorderRadius.all(Radius.zero),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5,left:11),
                    child: Container(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Switch(
                            value: switchEducation,
                            onChanged: (value) async {
                                switchEducation = value;
                                if (switchEducation) {
                                  print("switchEducation - $switchEducation");
                                  setState(() {
                                    expandedIndex = -1;
                                    tab2_Color = Colors.green;
                                    tab2_validState = true;
                                  });
                                  _tabController.animateTo(2);
                                  await firestoreService.removeFieldFrom_User_Employee(fieldName: 'Education Details');
                                }
                                else {
                                  print("switchEducation - $switchEducation");
                                  setState(() {
                                    expandedIndex = 0;
                                    if (validateFields_1() == false) {
                                      tab2_Color = Colors.red;
                                      tab2_validState = false;
                                    }
                                  });
                                }
                            },
                            activeColor: Colors.blue, // Color when switch is ON
                            inactiveThumbColor: Colors.grey, // Color of the switch when it's OFF
                            activeTrackColor: Colors.lightBlueAccent, // Color of the track when switch is ON
                            inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color of the track when switch is OFF
                          ),
                          const SizedBox(width: 10),
                          const Text('-  Want to skip this section?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController_2,
                      itemCount: institutionNameControllers.length + 1, // Add 1 for the buttons row
                      itemBuilder: (context, index) {
                        if (index == institutionNameControllers.length) {
                          // This is the last item, so it's the row with the buttons
                          return Padding(
                            padding: const EdgeInsets.only(top:20.0,bottom:20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: width * 0.4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(17.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      _vibrate();
                                      if (switchEducation) {
                                        null;
                                      }
                                      else if (switchEducation == false && validateFields_1()) {
                                        addEducation();
                                        _scrollToTop(_scrollController_2);
                                      }
                                      else {
                                        if (!isShowingSnackBar) {
                                          isShowingSnackBar = true;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  textAlign: TextAlign.center,
                                                  'Please fill existing required fields\n'
                                                      'or uncheck if the skip section is on',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold)),
                                              backgroundColor: Colors.red,
                                              behavior:
                                              SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 2),
                                              showCloseIcon: true,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 0.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          )
                                              .closed
                                              .then((reason) {
                                            // SnackBar is closed, reset the flag
                                            isShowingSnackBar = false;
                                          });
                                        }
                                        setState(() {
                                          tab2_Color = Colors.red;
                                          tab2_validState = false;
                                        });
                                      }
                                    },
                                    child: const Text(
                                      'Add Education',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * 0.4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(17.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      _vibrate();
                                      await allValidCheck();
                                      if (switchEducation == false) {
                                        if (validateFields_1()) {
                                          fetch_education_details();
                                          setState(() {
                                            tab2_Color = Colors.green;
                                            tab2_validState = true;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Education details submitted.',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                              ));
                                          _tabController.animateTo(2);
                                        } else {
                                          _scrollToTop(_scrollController_2);
                                          setState(() {
                                            tab2_Color = Colors.red;
                                            tab2_validState = false;
                                          });
                                        }
                                      }
                                      else {
                                        setState(() {
                                          tab2_Color = Colors.green;
                                          tab2_validState = true;
                                        });
                                        _tabController.animateTo(2);
                                      }
                                    },
                                    child: const Text(
                                      'Proceed',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // This is a regular education entry
                          return GestureDetector(
                            onTap: () {
                            if (switchEducation == false) {
                              toggleExpansion(index);
                            }
                          },
                            child: AnimatedSize(
                              duration: const Duration(seconds: 2),
                              curve: Curves.fastLinearToSlowEaseIn,
                              child: Container(
                                margin: const EdgeInsets.only(top: 5.0, left: 15, right: 15, bottom: 0),
                                padding: const EdgeInsets.only(top:15.0,bottom:10.0,right:14.0,left:14.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ' Education ${index + 1} :',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              fontFamily: 'anta',
                                              color: Colors.black,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (index != 0)
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () {
                                                    _vibrate();
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Center(
                                                          child: AlertDialog(
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                const SizedBox(height: 20),
                                                                const Text(
                                                                  'Are you sure you want to delete?',
                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                                const SizedBox(height: 20), // Add some space between text and buttons
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: Colors.green[500],
                                                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      onPressed: () {
                                                                        _vibrate();
                                                                        deleteEducation(index);
                                                                        Navigator.of(context).pop(true); // Close the dialog
                                                                      },
                                                                      child: const Text(
                                                                        'Yes',
                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 10), // Add some space between buttons
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: Colors.red[500],
                                                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop(false); // Close the dialog
                                                                      },
                                                                      child: const Text(
                                                                        'No',
                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              // if (expandedIndex != index)
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.black),
                                                onPressed: () {
                                                  if (switchEducation == false) {
                                                    toggleExpansion(index);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (expandedIndex == index)
                                      EducationInputForm(
                                        institutionNameController: institutionNameControllers[index],
                                        selectedDegree: selectedDegrees[index],
                                        gpaController: gpaControllers[index],
                                        gradyearController: gradyearControllers[index],
                                        selectedMajor: selectedMajors[index],
                                        honorsAwardsController: _honorsAwardsController[index],
                                        thesisProjectsController: _thesisProjectsController[index],
                                        institutionNameInvalid: institutionNameInvalid[index],
                                        degreeInvalid: degreeInvalid[index],
                                        gpaInvalid: gpaInvalid[index],
                                        gradyearInvalid: gradyearInvalid[index],
                                        majorInvalid: majorInvalid[index],
                                        honorsAwardsInvalid: _honorsAwardsInvalid[index],
                                        thesisProjectsInvalid: _thesisProjectsInvalid[index],
                                        honorsAwardsControllerTags: _honorsAwardsControllerTags[index],
                                        thesisProjectsControllerTags: _thesisProjectsControllerTags[index],
                                        onDegreeChanged: (value) {
                                          setState(() {
                                            selectedDegrees[index] = value ?? '';
                                          });
                                        },
                                        onMajorChanged: (value) {
                                          setState(() {
                                            selectedMajors[index] = value ?? '';
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Scrollbar(
        controller: _scrollController_3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onVerticalDragUpdate: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: _getallTabColor(), width: 7),
                        bottom: const BorderSide(color: Colors.black, width: 0),
                        left: const BorderSide(color: Colors.black, width: 0),
                        right: const BorderSide(color: Colors.black, width: 0),
                      ),
                      borderRadius: const BorderRadius.all(Radius.zero),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:5,left:11),
                    child: Container(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Switch(
                            value: switchEmployment,
                            onChanged: (value) async {
                              switchEmployment = value;
                              if (switchEmployment) {
                                print("switchEmployment - $switchEmployment");
                                setState(() {
                                  expandedIndex_2 = -1;
                                  tab3_Color = Colors.green;
                                  tab3_validState = true;
                                });
                                _tabController.animateTo(3);
                                await firestoreService.removeFieldFrom_User_Employee(fieldName: 'Employment Details');
                              }
                              else {
                                setState(() {
                                  expandedIndex_2 = 0;
                                  if (validateFields_2() == false) {
                                    tab3_Color = Colors.red;
                                    tab3_validState = false;
                                  }
                                });
                              }
                            },
                            activeColor: Colors.blue, // Color when switch is ON
                            inactiveThumbColor: Colors.grey, // Color of the switch when it's OFF
                            activeTrackColor: Colors.lightBlueAccent, // Color of the track when switch is ON
                            inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color of the track when switch is OFF
                          ),
                          const SizedBox(width: 10),
                          const Text('-  Want to skip this section?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController_3,
                      itemCount: companyNameControllers.length + 1, // Add 1 for the buttons row
                      itemBuilder: (context, index) {
                        if (index == companyNameControllers.length) {
                          // This is the last item, so it's the row with the buttons
                          return Padding(
                            padding: const EdgeInsets.only(top:20.0,bottom:20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: width * 0.4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(17.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      _vibrate();
                                      if (switchEmployment) {
                                        null;
                                      }
                                      else if (switchEmployment == false && validateFields_2()) {
                                        addWork();
                                        _scrollToTop(_scrollController_3);
                                      } else {
                                        if (!isShowingSnackBar_2) {
                                          isShowingSnackBar_2 = true;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  textAlign: TextAlign.center,
                                                  'Please fill existing required fields\n'
                                                      'or uncheck if the skip section is on',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold)),
                                              backgroundColor: Colors.red,
                                              behavior:
                                              SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 2),
                                              showCloseIcon: true,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 0.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          )
                                              .closed
                                              .then((reason) {
                                            // SnackBar is closed, reset the flag
                                            isShowingSnackBar_2 = false;
                                          });
                                        }
                                        setState(() {
                                          tab3_Color = Colors.red;
                                          tab3_validState = false;
                                        });
                                      }
                                    },
                                    child: const Text(
                                      'Add Work',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * 0.4,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    border: Border.all(color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(17.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      _vibrate();
                                      await allValidCheck();
                                      if (switchEmployment == false) {
                                        if (validateFields_2()) {
                                          fetch_employment_details();
                                          setState(() {
                                            tab3_Color = Colors.green;
                                            tab3_validState = true;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Work experience submitted.',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                              ));
                                          _tabController.animateTo(3);
                                        } else {
                                          _scrollToTop(_scrollController_3);
                                          setState(() {
                                            tab3_Color = Colors.red;
                                            tab3_validState = false;
                                          });
                                        }
                                      }
                                      else {
                                        setState(() {
                                          tab3_Color = Colors.green;
                                          tab3_validState = true;
                                        });
                                        _tabController.animateTo(3);
                                      }
                                    },
                                    child: const Text(
                                      'Proceed',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // This is a regular education entry
                          return GestureDetector(
                            onTap: () {
                              if (switchEmployment == false) {
                                toggleExpansion_2(index);
                              }
                            },
                            child: AnimatedSize(
                              duration: const Duration(seconds: 2),
                              curve: Curves.fastLinearToSlowEaseIn,
                              child: Container(
                                margin: const EdgeInsets.only(top: 5.0, left: 15, right: 15, bottom: 0),
                                padding: const EdgeInsets.only(top:15.0,bottom:10.0,right:14.0,left:14.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ' Work Experience ${index + 1} :',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                              fontFamily: 'anta',
                                              color: Colors.black,
                                            ),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (index != 0)
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () {
                                                      _vibrate();
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Center(
                                                            child: AlertDialog(
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const SizedBox(height: 20),
                                                                  const Text(
                                                                    'Are you sure you want to delete?',
                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                  ),
                                                                  const SizedBox(height: 20), // Add some space between text and buttons
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor: Colors.green[500],
                                                                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                        onPressed: () {
                                                                          _vibrate();
                                                                          deleteWork(index);
                                                                          Navigator.of(context).pop(true); // Close the dialog
                                                                        },
                                                                        child: const Text(
                                                                          'Yes',
                                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 10), // Add some space between buttons
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor: Colors.red[500],
                                                                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                          ),
                                                                        ),
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop(false); // Close the dialog
                                                                        },
                                                                        child: const Text(
                                                                          'No',
                                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                // if (expandedIndex != index)
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.black),
                                                  onPressed: () {
                                                    if (switchEmployment == false) {
                                                      toggleExpansion_2(index);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (expandedIndex_2 == index)
                                      WorkInputForm(
                                        companyNameController: companyNameControllers[index],
                                        positionController: positionControllers[index],
                                        jdDateController: jdDateControllers[index],
                                        lwDateController: lwDateControllers[index],
                                        locationController: locationControllers[index],
                                        rflController: rflControllers[index],
                                        askillsController: askillsControllers[index],
                                        askillsControllerTags: _askillsControllerTags[index],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Scrollbar(
          controller: _scrollController_4, // Provide the scroll controller
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onVerticalDragUpdate: (_) {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: _getallTabColor(), width: 7), // Reduce the width here
                    bottom: const BorderSide(color: Colors.black, width: 0), // Reduce the width here
                    left: const BorderSide(color: Colors.black, width: 0), // Maintain the original width
                    right: const BorderSide(color: Colors.black, width: 0)), // Maintain the original width
                borderRadius: const BorderRadius.all(Radius.zero),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                    controller: _scrollController_4,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15.0, left: 15, right: 15, bottom: 0),
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top:20.0,bottom:20.0,right:14.0,left:14.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: const Text(
                                          ' Skills (Optional) :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0,
                                            fontFamily: 'anta',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  //////////////////// Tag Widget
                                  TextFormField(
                                    controller: _technicalSkillsController,
                                    decoration: InputDecoration(
                                      // errorText: tab4_subState & _technicalSkillsController_tags.isEmpty ? 'This field cannot be empty' : null,
                                      prefixIcon: const Icon(Icons.military_tech),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Technical Skills',
                                      labelStyle: const TextStyle(color: Colors.black54, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      hintText: 'eg : Python, CAD, SEO',
                                      hintStyle: const TextStyle(color: Colors.black26, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          _vibrate();
                                          _addTag(_technicalSkillsController.text.trim(), _technicalSkillsController);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 95),
                                    child: Scrollbar(
                                      thickness: 8,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 0.0,
                                              children: _technicalSkillsController_tags.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final tag = entry.value;
                                                return Chip(
                                                  backgroundColor: Colors.deepPurple,
                                                  label: Text(tag,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                                  onDeleted: () => _deleteTag(index, _technicalSkillsController),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //////////////////// Tag Widget
                                  const SizedBox(height: 7),
                                  //////////////////// Tag Widget
                                  TextFormField(
                                    controller: _softSkillsController,
                                    decoration: InputDecoration(
                                      // errorText: tab4_subState & _softSkillsController_tags.isEmpty ? 'This field cannot be empty' : null,
                                      prefixIcon: const Icon(Icons.group_work_outlined),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Soft Skills',
                                      labelStyle: const TextStyle(color: Colors.black54, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      hintText: 'eg : Delegation, Creativity',
                                      hintStyle: const TextStyle(color: Colors.black26, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          _vibrate();
                                          _addTag(_softSkillsController.text.trim(), _softSkillsController);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 95),
                                    child: Scrollbar(
                                      thickness: 8,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 0.0,
                                              children: _softSkillsController_tags.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final tag = entry.value;
                                                return Chip(
                                                  backgroundColor: Colors.deepPurple,
                                                  label: Text(tag,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                                  onDeleted: () => _deleteTag(index, _softSkillsController),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //////////////////// Tag Widget
                                  const SizedBox(height: 7),
                                  //////////////////// Tag Widget
                                  TextFormField(
                                    controller: _certificationsController,
                                    decoration: InputDecoration(
                                      // errorText: tab4_subState & _certificationsController_tags.isEmpty ? 'This field cannot be empty' : null,
                                      prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Certifications',
                                      labelStyle: const TextStyle(color: Colors.black54, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      hintText: 'eg : CCNA, PHR, AWS',
                                      hintStyle: const TextStyle(color: Colors.black26, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          _vibrate();
                                          _addTag(_certificationsController.text.trim(), _certificationsController);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 95),
                                    child: Scrollbar(
                                      thickness: 8,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 0.0,
                                              children: _certificationsController_tags.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final tag = entry.value;
                                                return Chip(
                                                  backgroundColor: Colors.deepPurple,
                                                  label: Text(tag,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                                  onDeleted: () => _deleteTag(index, _certificationsController),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //////////////////// Tag Widget
                                  const SizedBox(height: 7),
                                  //////////////////// Tag Widget
                                  TextFormField(
                                    controller: _educationTrainingController,
                                    decoration: InputDecoration(
                                      // errorText: tab4_subState & _educationTrainingController_tags.isEmpty ? 'This field cannot be empty' : null,
                                      prefixIcon: const Icon(Icons.model_training),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Training & Courses',
                                      labelStyle: const TextStyle(color: Colors.black54, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      hintText: 'eg : CSM, SHRM',
                                      hintStyle: const TextStyle(color: Colors.black26, fontFamily: 'rowdies', fontWeight: FontWeight.bold),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          _vibrate();
                                          _addTag(_educationTrainingController.text.trim(), _educationTrainingController);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 95),
                                    child: Scrollbar(
                                      thickness: 8,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      child: ListView(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 0.0,
                                              children: _educationTrainingController_tags.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final tag = entry.value;
                                                return Chip(
                                                  backgroundColor: Colors.deepPurple,
                                                  label: Text(tag,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                                  onDeleted: () => _deleteTag(index, _educationTrainingController),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //////////////////// Tag Widget
                                  const SizedBox(height: 7),
                                  TextFormField(
                                    controller: professionalAffiliationsController,
                                    decoration: const InputDecoration(labelText: 'Professional Affiliations',
                                      labelStyle: TextStyle(fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                      prefixIcon: Icon(Icons.card_membership),
                                      hintText: ' List professional memberships',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    maxLines: null, // Allow multiline input
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: volunteerExperienceController,
                                    decoration: const InputDecoration(labelText: 'Volunteer Experience',
                                      labelStyle: TextStyle(fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                      prefixIcon: Icon(Icons.data_saver_on),
                                      hintText: ' Describe volunteer activities',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black, // Specify your border color here
                                          width: 2.0, // Specify your border width here
                                        ),
                                      ),
                                    ),
                                    maxLines: null, // Allow multiline input
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    height: 150,
                                    child: TextFormField(
                                      maxLines: null,
                                      expands: true,
                                      textAlign: TextAlign.start,
                                      controller: aboutController,
                                      onChanged: (value) {
                                        setState(() {
                                          aboutController.text = value;
                                        });
                                      },
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        filled: true,
                                        labelText: 'About Yourself',
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        errorText: aboutController.text.isEmpty
                                            ?
                                        'Please enter about yourself'
                                            : null,
                                        prefixIcon: const Icon(Icons.add_comment),
                                        hintText: 'Please enter about yourself',
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                            // Specify your border color here
                                            width: 2.0, // Specify your border width here
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            '*Your privacy matters to us. We collect and use '
                                'personal information solely for the purpose of providing our '
                                'services and improving your experience.',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: width * 0.4,
                            height: 50,
                            child: ElevatedButton(
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(color: Colors.black, width: 3),
                                backgroundColor: Colors.green[500],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ), onPressed: () async {
                              _vibrate();
                              _doesFileExist();
                              await allValidCheck();
                              if (validateFields_3()) {
                                setState(() {
                                  tab4_Color = Colors.green;
                                  tab4_validState = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Skills details submitted.',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                fetch_skills_details();
                                ////////////////////////
                                if (validateFields() &&
                                    validateFields_1() &&
                                    validateFields_2()) {
                                  fetch_personal_details();
                                  fetch_education_details();
                                  fetch_employment_details();
                                  _getallTabColor();
                                  _changeallTabColor();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'User details completed',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 20)),
                                        content: const Text(
                                            'Auto generated resume can be downloaded in the files',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        actions: <Widget>[
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                      Colors.black,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      _vibrate();
                                                      Navigator.of(context)
                                                          .pop(); // To close the dialog
                                                    },
                                                    child: const Text('Edit',
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .white)),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                      Colors.black,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      _vibrate();
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                          MaterialPageRoute(builder:
                                                              (BuildContext
                                                          context) {
                                                            return EmployeeMenuPage();
                                                          }));
                                                    },
                                                    child: const Text('Menu',
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .white)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                else {
                                  _verifyallTabColor();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Incomplete Fields',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontSize: 20)),
                                        content: Text(Allcheck(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        actions: <Widget>[
                                          Center(
                                            child: ElevatedButton(
                                              style:
                                              ElevatedButton.styleFrom(
                                                backgroundColor:
                                                Colors.black,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                                ),
                                              ),
                                              onPressed: () {
                                                _vibrate();
                                                Navigator.of(context)
                                                    .pop(); // To close the dialog
                                              },
                                              child: const Text('Close',
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                ////////////////////////
                              }
                              else {
                                _scrollToTop(_scrollController_4);
                                _verifyallTabColor();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill in all required fields.',
                                    textAlign: TextAlign.center),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                  }
                                }
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    ];
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: AppBar(
            leading: customBackButton(context),
            backgroundColor: Colors.white,
            title: GestureDetector(
              onTap: () async {
                _vibrate();
                _doesFileExist();
                /* Navigator.of(context)
                    .pushReplacement(
                    MaterialPageRoute(builder:
                        (BuildContext
                    context) {
                      return Permission_req();
                    })); */
              },
              child: const Text('Info',style: TextStyle(fontWeight: FontWeight.bold,
                  fontFamily: 'cour', fontSize: 28, color: Colors.teal)
              ),
            ), centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromWidth(0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.yellow,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      color: _getIndicatorColor(_currentIndex),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      )
                  ),
                  tabs: [
                    Container(width: 100, child: const Tab(icon: Icon(Icons.person))),
                    Container(width: 100, child: const Tab(icon: Icon(Icons.school))),
                    Container(width: 100, child: const Tab(icon: Icon(Icons.work))),
                    Container(width: 100, child: const Tab(icon: Icon(Icons.add_box))),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: tabViews,
        ),
      );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.errorText,
    this.icon,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final String? errorText;
  final IconData? icon;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    this.errorText,
    this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationInputForm extends StatefulWidget {
  TextEditingController institutionNameController;
  String selectedDegree;
  ValueChanged<String?> onDegreeChanged;
  String selectedMajor;
  ValueChanged<String?> onMajorChanged;
  TextEditingController gpaController;
  TextEditingController gradyearController;
  TextEditingController honorsAwardsController;
  TextEditingController thesisProjectsController;
  bool institutionNameInvalid;
  bool degreeInvalid;
  bool gpaInvalid;
  bool gradyearInvalid;
  bool majorInvalid;
  bool honorsAwardsInvalid;
  bool thesisProjectsInvalid;

  List<String> honorsAwardsControllerTags;
  List<String> thesisProjectsControllerTags;

  EducationInputForm({
    Key? key,
    required this.institutionNameController,
    required this.selectedDegree,
    required this.onDegreeChanged,
    required this.onMajorChanged,
    required this.gpaController,
    required this.gradyearController,
    required this.selectedMajor,
    required this.honorsAwardsController,
    required this.thesisProjectsController,
    required this.institutionNameInvalid,
    required this.degreeInvalid,
    required this.gpaInvalid,
    required this.gradyearInvalid,
    required this.majorInvalid,
    required this.honorsAwardsInvalid,
    required this.thesisProjectsInvalid,
    required this.honorsAwardsControllerTags,
    required this.thesisProjectsControllerTags,
  }) : super(key: key);

  @override
  _EducationInputFormState createState() => _EducationInputFormState();
}

class _EducationInputFormState extends State<EducationInputForm> {
  final List<String> _degreeOptions = [
    "Associate's Degree",
    "Bachelor's Degree",
    "Master's Degree",
    "Doctoral Degree",
    "Professional Degrees",];
  final List<String> _majorOptions = [
    'Other',
    'Computer Science',
    'Information Science',
    'Data Science',
    'Business Administration',
    'Marketing Management',
    'Human Resources',
    'Accounting',
    'Finance (General)',
    'Business Economics',
    'Management Info',
    'Economics',
    'Psychology (General)',
    'Sociology',
    'Criminal Justice',
    'Registered Nursing',
    'General Mathematics',
    'Statistics',
    'General Biology',
    'Chemistry',
    'Physics',
    'Environmental Science',
    'General Communications',
    'Public Relations',
    'Print Journalism',
    'English Literature',
    'History',
    'Political Science',
    'Anthropology',
    'Philosophy',
    'Religion',
    'Fine/Studio Arts',
    'General Music',
    'Theatre Arts/Drama',
    'General Architecture',
    'Interior Design',
    'Forestry',
    'Animal Sciences',
    'Wildlife Management',
    'Horticulture Science',
    'Food Sciences',
    'Mathematics Education',
    'Physical Education',
    'General Teacher',
    'Childhood Education',
    'Elementary Education',
    'Secondary Education',
    'Special Education',
    'Vocational Nursing',
    'Public Health',
    'Medical Technology',
    'Respiratory Therapy',
    'Veterinary Medicine',
    'Medicine',
    'Dentistry',
    'Pharmacy',
    'Physical Therapy',
    'Occupational Therapy',
    'Nutrition Sciences',
    'Public Administration',
    'Business Management',
    'Hotel Management',
    'Tourism & Travel',
    'Graphic Design',
    'Fashion/Apparel',
    'Film/Cinema Studies',
    'Dance',
    'Urban Planning',
    'Geography',
    'Environmental Studies',
    'Geology',
    'Astronomy',
    'Linguistics',
    'Education',
    'Marketing',
    'Finance',
    'Information Technology',
    'Psychology',
    'Religious Studies',
    'Fine Arts',
    'Music',
    'Theatre Arts',
    'Architecture',
    'Journalism',
    'Nursing',
    'Mathematics',
    'Biology',
    'Communications'
  ];

  void _addTag(String tag, TextEditingController controller) {
    if (tag.trim().isNotEmpty) {
      String lowercaseTag = tag.toLowerCase();
      List<String> tagsList;
      if (controller == widget.honorsAwardsController) {
        tagsList = widget.honorsAwardsControllerTags;
      } else if (controller == widget.thesisProjectsController) {
        tagsList = widget.thesisProjectsControllerTags;
      } else {
        return;
      }
      if (!tagsList.map((t) => t.toLowerCase()).contains(lowercaseTag)) {
        setState(() {
          tagsList.add(tag);
          controller.clear();
        });
      }
    }
  }

  void _deleteTag(int index, TextEditingController controller) {
    List<String> tagsList;
    if (controller == widget.honorsAwardsController) {
      tagsList = widget.honorsAwardsControllerTags;
    } else if (controller == widget.thesisProjectsController) {
      tagsList = widget.thesisProjectsControllerTags;
    } else {
      return;
    }
    setState(() {
      tagsList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        CustomDropdownField(
          label: 'Degree',
          icon: Icons.school,
          value: widget.selectedDegree,
          items: _degreeOptions,
          errorText: widget.selectedDegree.isEmpty ? 'Please select a degree' : null,
          onChanged: widget.onDegreeChanged,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Institution Name',
          icon: Icons.account_balance,
          controller: widget.institutionNameController,
          errorText: widget.institutionNameController.text.isEmpty ? 'This field cannot be empty' : null,
          onChanged: (value) {
            setState(() {
              widget.institutionNameController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.gradyearController,
          readOnly: true,
          onTap: () async {
            DateTime? _picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));
            if (_picked != null) {
              setState(() {
                final formattedDate = DateFormat('dd-MM-yyyy').format(_picked);
                widget.gradyearController.text = formattedDate;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Graduation Year',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            filled: false,
            errorText: widget.gradyearController.text.isEmpty ? 'This field cannot be empty' : null,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors
                    .black, // Specify your border color here
                width:
                2.0, // Specify your border width here
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        CustomDropdownField(
          label: 'Major',
          icon: Icons.school,
          value: widget.selectedMajor,
          items: _majorOptions,
          errorText: widget.selectedMajor.isEmpty ? 'Please select a degree' : null,
          onChanged: widget.onMajorChanged,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.gpaController,
          keyboardType: TextInputType.number, // Set the keyboard type here
          decoration: InputDecoration(
            labelText: 'GPA',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: const Icon(Icons.star),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorText: widget.gpaController.text.contains(RegExp(r'[^0-9.]'))
                ? 'Invalid format'
                : widget.gpaController.text.isEmpty
                ? 'This field cannot be empty'
                : null,
          ),
          onChanged: (value) {
            setState(() {
              widget.gpaController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.honorsAwardsController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.bookmark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: 'Honors & Awards (Optional)',
            hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _vibrate();
                _addTag(widget.honorsAwardsController.text.trim(), widget.honorsAwardsController);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 95),
          child: Scrollbar(
            thickness: 8,
            trackVisibility: true,
            thumbVisibility: true,
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0.0,
                    children: widget.honorsAwardsControllerTags.map((tag) {
                      final index = widget.honorsAwardsControllerTags.indexOf(tag);
                      return Chip(
                        backgroundColor: Colors.deepPurple,
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onDeleted: () => _deleteTag(index, widget.honorsAwardsController),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.thesisProjectsController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.book_sharp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: 'Research & Projects (Optional)',
            hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _vibrate();
                _addTag(widget.thesisProjectsController.text.trim(), widget.thesisProjectsController);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 95),
          child: Scrollbar(
            thickness: 8,
            trackVisibility: true,
            thumbVisibility: true,
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0.0,
                    children: widget.thesisProjectsControllerTags.map((tag) {
                      final index = widget.thesisProjectsControllerTags.indexOf(tag);
                      return Chip(
                        backgroundColor: Colors.deepPurple,
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onDeleted: () => _deleteTag(index, widget.thesisProjectsController),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WorkInputForm extends StatefulWidget {
  TextEditingController companyNameController;
  TextEditingController positionController;
  TextEditingController jdDateController;
  TextEditingController lwDateController;
  TextEditingController locationController;
  TextEditingController rflController;
  TextEditingController askillsController;

  List<String> askillsControllerTags;

  WorkInputForm({
    Key? key,
    required this.companyNameController,
    required this.positionController,
    required this.jdDateController,
    required this.lwDateController,
    required this.locationController,
    required this.rflController,
    required this.askillsController,
    required this.askillsControllerTags,
  }) : super(key: key);

  @override
  _WorkInputFormState createState() => _WorkInputFormState();
}

class _WorkInputFormState extends State<WorkInputForm> {

  void _addTag(String tag, TextEditingController controller) {
    if (tag.trim().isNotEmpty) {
      String lowercaseTag = tag.toLowerCase();
      List<String> tagsList;
      if (controller == widget.askillsController) {
        tagsList = widget.askillsControllerTags;
      }
      else {
        return;
      }

      if (!tagsList.map((t) => t.toLowerCase()).contains(lowercaseTag)) {
        setState(() {
          tagsList.add(tag);
          controller.clear();
        });
      }
    }
  }

  void _deleteTag(int index, TextEditingController controller) {
    List<String> tagsList;
    if (controller == widget.askillsController) {
      tagsList = widget.askillsControllerTags;
    }
    else {
      return;
    }

    setState(() {
      tagsList.removeAt(index);
    });
  }

  bool isNotLessThanjdDate(String lwDateText) {
    if (lwDateText.isEmpty || widget.jdDateController.text.isEmpty) {
      return false; // Or handle empty dates as per your logic
    }
    DateTime lwDate = DateFormat('dd-MM-yyyy').parse(lwDateText);
    DateTime jdDate = DateFormat('dd-MM-yyyy').parse(widget.jdDateController.text);
    return lwDate.isAtSameMomentAs(jdDate) || lwDate.isAfter(jdDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Company Name',
          icon: Icons.add_business,
          controller: widget.companyNameController,
          errorText: widget.companyNameController.text.isEmpty ? 'This field cannot be empty' : null,
          onChanged: (value) {
            setState(() {
              widget.companyNameController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Position/Job Title',
          icon: Icons.person_pin_rounded,
          controller: widget.positionController,
          errorText: widget.positionController.text.isEmpty ? 'This field cannot be empty' : null,
          onChanged: (value) {
            setState(() {
              widget.positionController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.jdDateController,
          readOnly: true,
          onTap: () async {
            DateTime? _picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));
            if (_picked != null) {
              setState(() {
                final formattedDate = DateFormat('dd-MM-yyyy').format(_picked);
                widget.jdDateController.text = formattedDate;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Joining Date',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            filled: false,
            errorText: widget.jdDateController.text.isEmpty ? 'This field cannot be empty' : null,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors
                    .black, // Specify your border color here
                width:
                2.0, // Specify your border width here
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.lwDateController,
          readOnly: true,
          onTap: () async {
            DateTime? _picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100));
            if (_picked != null) {
              setState(() {
                final formattedDate = DateFormat('dd-MM-yyyy').format(_picked);
                widget.lwDateController.text = formattedDate;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Last Working Date',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            filled: false,
            errorText: widget.lwDateController.text.isEmpty
                ? 'This field cannot be empty'
                : !isNotLessThanjdDate(widget.lwDateController.text)
                ? 'LWD cannot be lesser than joining date.'
                : null,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black, // Specify your border color here
                width: 2.0, // Specify your border width here
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Work Location',
          icon: Icons.location_on_rounded,
          controller: widget.locationController,
          errorText: widget.locationController.text.isEmpty ? 'This field cannot be empty' : null,
          onChanged: (value) {
            setState(() {
              widget.locationController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Reason for Leaving',
          icon: Icons.exit_to_app_rounded,
          controller: widget.rflController,
          errorText: widget.rflController.text.isEmpty ? 'This field cannot be empty' : null,
          onChanged: (value) {
            setState(() {
              widget.rflController.text = value;
            });
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: widget.askillsController,
          decoration: InputDecoration(
            // errorText: tab3_subState & widget.askillsControllerTags.isEmpty ? 'This field cannot be empty' : null,
            prefixIcon: const Icon(Icons.multiline_chart),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: 'Acquired Skills (Optional)',
            hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _vibrate();
                _addTag(widget.askillsController.text.trim(), widget.askillsController);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 95),
          child: Scrollbar(
            thickness: 8,
            trackVisibility: true,
            thumbVisibility: true,
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0.0,
                    children: widget.askillsControllerTags.map((tag) {
                      final index = widget.askillsControllerTags.indexOf(tag);
                      return Chip(
                        backgroundColor: Colors.deepPurple,
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onDeleted: () => _deleteTag(index, widget.askillsController),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Permission_req extends StatefulWidget {
  const Permission_req({Key? key}) : super(key: key);
  @override
  _Permission_req createState() => _Permission_req();
  Future<bool> request_per(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        print("re.isGranted - Yes");
        return true;
      }
      else {
        print("re.isGranted - No");
        return false;
      }
    }
    else {
      var result = await permission.request();
      if (result.isGranted) {
        print("result.isGranted - Yes");
        return true;
      }
      else {
        return false;
      }
    }
  }
}

class _Permission_req extends State<Permission_req> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text('Storage Permission in Android(11, 12, 13')),
        body: Center(
            child: ElevatedButton(
            onPressed: () async {
              if (await widget.request_per(Permission.storage)) {
                print('Permission is granted');
              }
              else {
                print("permission is not granted");
              }
            },
            child: Text('Click'),
        )),
    );
  }
}

/* class CalendarDialog {
  final BuildContext context;

  CalendarDialog(this.context);

  void show() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 300, // Adjust the height as per your requirement
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // Example start date
              lastDay: DateTime.utc(2030, 12, 31), // Example end date
              focusedDay: DateTime.now(), // Example initial focused day
              onDaySelected: (date, events) {
                // Handle the selected date
                print('Selected date: $date');
                Navigator.pop(context); // Close the calendar dialog
              },
            ),
          ),
        );
      },
    );
  }
} */
