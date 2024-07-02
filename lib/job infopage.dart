import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jopple/services.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';

ScrollController _scrollController_1 = ScrollController();
FirestoreService firestoreService = FirestoreService();

// For Personal Details
TextEditingController companyNameController = TextEditingController();
TextEditingController deadlineDateController = TextEditingController();
var workType;
var requiredQualification;
var workModes;
TextEditingController addressController = TextEditingController();
TextEditingController phoneNumberController = TextEditingController();
TextEditingController emailAddressController = TextEditingController();
TextEditingController hiringJobController = TextEditingController();
TextEditingController siteController = TextEditingController();
TextEditingController jdController = TextEditingController();
var selectedLanguage;

bool companyNameInvalid = false;
bool deadlineDateControllerInvalid = false;
bool workTypeInvalid = false;
bool requiredQualificationInvalid = false;
bool workModesInvalid = false;
bool addressInvalid = false;
bool phoneNumberInvalid = false;
bool emailAddressInvalid = false;
bool hiringJobInvalid = false;
bool jdInvalid = false;
bool languageInvalid = false;

final RegExp phoneRegex =
RegExp(r'^\+?\d{1,3}[-\s]?\d{3}[-\s]?\d{3}[-\s]?\d{4}$|^\d{10}$');
final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
final RegExp nameRegex = RegExp(r'^[a-zA-Z\s.]+$');

Future<void> _vibrate() async {
  bool hasVibrator = await Vibration.hasVibrator() ?? false;
  if (hasVibrator) {
    Vibration.vibrate(duration: 50); // Vibrate for 50 milliseconds
  }
}

void _scrollToTop(ScrollController scrollController) {
  scrollController.jumpTo(0.0);
  /* scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ); */
}

bool validateFields() {
  bool allValid = true;
  bool invalid = false;

  if (companyNameController.text.isEmpty) {
    // Assuming you have a variable called companyNameInvalid
    companyNameInvalid = true;
    invalid = true;
  } else {
    companyNameInvalid = false;
  }

  if (deadlineDateController.text.isEmpty) {
    deadlineDateControllerInvalid = true; // Assuming you have a variable called deadlineDateControllerInvalid
    invalid = true;
  } else {
    deadlineDateControllerInvalid = false;
  }

  if (workType == null) {
    workTypeInvalid = true; // Assuming you have a variable called workTypeInvalid
    invalid = true;
  } else {
    workTypeInvalid = false;
  }

  if (requiredQualification == null) {
    requiredQualificationInvalid = true; // Assuming you have a variable called requiredQualificationInvalid
    invalid = true;
  } else {
    requiredQualificationInvalid = false;
  }

  if (workModes == null) {
    workModesInvalid = true; // Assuming you have a variable called workModesInvalid
    invalid = true;
  } else {
    workModesInvalid = false;
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

  if (hiringJobController.text.isEmpty) {
    hiringJobInvalid = true; // Assuming you have a variable called hiringJobInvalid
    invalid = true;
  } else {
    hiringJobInvalid = false;
  }

  if (jdController.text.isEmpty) {
    jdInvalid = true; // Assuming you have a variable called hiringJobInvalid
    invalid = true;
  } else {
    jdInvalid = false;
  }

  if (selectedLanguage == null) {
    languageInvalid = true; // Assuming you have a variable called languageInvalid
    invalid = true;
  } else {
    languageInvalid = false;
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

void fetch_company_details() {
  print("********* fetch_company_details *********");
  firestoreService.addCompanyDetails(companyNameController.text,
      deadlineDateController.text,
      workType,
      requiredQualification,
      workModes,
      addressController.text,
      phoneNumberController.text,
      emailAddressController.text,
      hiringJobController.text,
      siteController.text,
      jdController.text,
      selectedLanguage);
}

Future<void> allValidCheck() async {
  print("1 - ${validateFields()}");
  if (validateFields()) {
    await firestoreService.updateField_User_Employer(fieldName: 'FetchValid', newValue: true);
    await firestoreService.updateField_User_Employer(fieldName: 'title', newValue: hiringJobController.text);
    await firestoreService.updateField_User_Employer(fieldName: 'company', newValue: companyNameController.text);
    await firestoreService.updateField_User_Employer(fieldName: 'location', newValue: addressController.text);
  }
  else {
    await firestoreService.updateField_User_Employer(fieldName: 'FetchValid', newValue: false);
  }
}

class JobInfo extends StatefulWidget {
  @override
  _JobInfoState createState() => _JobInfoState();
}

class _JobInfoState extends State<JobInfo> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            _vibrate();
          },
          child: const Text('Info',style: TextStyle(fontWeight: FontWeight.bold,
              fontFamily: 'cour', fontSize: 28, color: Colors.teal)
          ),
        ), centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController_1,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 5.0, left: 15, right: 15, bottom: 0),
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
                          ' Company Information :',
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
                      controller: companyNameController,
                      onChanged: (value) {
                        setState(() {
                          companyNameController.text = value;
                        });
                      },
                      decoration: InputDecoration(
                        errorText: /* tab1_subState && */companyNameController
                            .text.isEmpty ?
                        'Company name is required'
                            : null,
                        labelText: 'Company Name',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        hintText: 'Enter company name',
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
                      controller: deadlineDateController,
                      // Controller for handling text input
                      onChanged: (value) { // Update the controller's text when input changes
                        setState(() {
                          deadlineDateController.text = value;
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
                            deadlineDateController.text = formattedDate;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        // Label for the text field
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: deadlineDateController.text.isEmpty
                            ? 'Last date for application'
                            : (() {
                          try {
                            // Attempt to parse the date from text
                            DateTime dob = DateFormat('dd-MM-yyyy')
                                .parse(deadlineDateController.text);
                            DateTime now = DateTime.now();
                            int age = now.year - dob.year;
                            if (now.month < dob.month ||
                                (now.month == dob.month &&
                                    now.day < dob.day)) {
                              age--;
                            }
                            return age > 1
                                ? 'It should not be a past date'
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
                      value: workType,
                      items: [
                        'Permanent (Full-Time)',
                        'Permanent (Part-Time)',
                        'Temporary',
                        'Contract',
                        'Freelance',
                        'Internship',
                        'Apprenticeship',
                        'Seasonal',
                        'Consultant'
                      ]
                          .map<DropdownMenuItem<String>>((
                          String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Work Type',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: workType == null
                            ? 'Work type is required'
                            : null,
                        prefixIcon: const Icon(Icons.animation_sharp),
                        hintText: 'Choose the work type',
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
                          workType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField(
                      value: requiredQualification,
                      items: [
                        "Associate's Degree",
                        "Bachelor's Degree",
                        "Master's Degree",
                        "Doctoral Degree",
                        "Professional Degrees"]
                          .map<DropdownMenuItem<String>>((
                          String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Required Degree',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: requiredQualification == null
                            ? 'Degree is required'
                            : null,
                        prefixIcon: const Icon(Icons.school),
                        hintText: 'Select minimal degree required',
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
                          requiredQualification = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField(
                      value: workModes,
                      items: [
                        'WFO (Work From Office)',
                        'WFH (Work From Home)',
                        'Hybrid',
                        'Remote',
                        'On-Site',
                        'Flexible',
                        'Telecommuting',
                        'Distributed Workforce',
                        'Mobile Work'
                      ]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Work Mode',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: workModes == null
                            ? 'Work mode is required'
                            : null,
                        prefixIcon: const Icon(Icons.add_home_work_sharp),
                        hintText: 'Choose work mode',
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
                          workModes = value;
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
                      controller: hiringJobController,
                      onChanged: (value) {
                        setState(() {
                          hiringJobController.text = value;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Job hiring for?',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: hiringJobController.text.isEmpty
                            ?
                        'Candidate domain is required'
                            : null,
                        prefixIcon: const Icon(Icons.app_registration),
                        hintText: 'Enter your interested candidate domain',
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
                      controller: siteController,
                      onChanged: (value) {
                        setState(() {
                          siteController.text = value;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Website (Optional)',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold),
                        errorText: siteController.text.isEmpty
                            ?
                        'Please enter website'
                            : null,
                        prefixIcon: const Icon(Icons.web),
                        hintText: 'Please enter your website',
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
                    Container(
                      height: 150,
                      child: TextFormField(
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.start,
                        controller: jdController,
                        onChanged: (value) {
                          setState(() {
                            jdController.text = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          filled: true,
                          labelText: 'Job Description',
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold),
                          errorText: jdController.text.isEmpty
                              ?
                          'Job Description is required'
                              : null,
                          prefixIcon: const Icon(Icons.add_comment),
                          hintText: 'Please enter Job Description',
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
                _vibrate();
                allValidCheck();
                if (validateFields()) {
                  fetch_company_details();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Company details submitted.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ));
                }
                else {
                  _scrollToTop(_scrollController_1);
                }
              },
                child: const Text(
                  "Submit",
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
    );
  }
}