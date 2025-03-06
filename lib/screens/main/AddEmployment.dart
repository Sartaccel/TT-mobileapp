import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;

import '../../models/login_data_model.dart';

class Addemployment extends StatefulWidget {
  final emplomentData;
  const Addemployment({super.key, required this.emplomentData});

  @override
  State<Addemployment> createState() => _AddemploymentState();
}

class _AddemploymentState extends State<Addemployment> {
  final databaseRef =
      FirebaseDatabase.instance.ref().child(AppConstants.APP_NAME);

  final int maxLength = 50;

  bool isLoading = false;
  bool isEdit = false;

  DateTime startDatems = DateTime.now();

  ReferralData? referralData;
  UserData? retrievedUserData;

  String? _selectedOption = 'No';
  String startYear = '', endYear = '';

  bool _isDesignationValid = true;
  TextEditingController txtDesignationController = TextEditingController();
  String designationErrorMsg = 'Designation is required';

  bool _isCompanyNameValid = true;
  TextEditingController txtComanyNameController = TextEditingController();
  String companyNameErrorMsg = 'Company name is required';

  bool isStartDateValid = true;
  bool _startDateSelected = false;

  String? startDateErrorMsg = 'Start date is required';
  final TextEditingController _startDateController = TextEditingController();

  bool isEndDateValid = true;
  String? endDateErrorMsg = 'End date is required';
  final TextEditingController _endDateController = TextEditingController();

  bool _isDescriptionValid = true;
  String? descriptionErrorMsg = 'Description is required';
  final TextEditingController txtDescriptionController =
      TextEditingController();

  bool isWorkTypeValid = true;
  String selectedWorkType = '';

  bool isEmploymentTypeValid = true;
  String selectedEmploymentType = '';

  String email = '';

  Future<void> updateinRTDB(String id, String bodyParams) async {
    final sanitizedEmail = email.replaceAll('.', ',');
    //final snapshot = await databaseRef.child('$sanitizedEmail/notificationSettings').get();
    databaseRef.child('${sanitizedEmail}/employmentData').set({
      'bodyParams': bodyParams,
    });
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          //ReferralData referralData = ReferralData.fromJson(data);
          CandidateProfileModel candidateData =
              CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);

          /*Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PersonalDetails()),
                (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );*/

          Navigator.pop(context);
        }
      } else {
        print(response);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateEmployment() async {
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.ADD_EMPLOYMENT +
        retrievedUserData!.profileId.toString() +
        '/employment');

    final bodyParams = isEdit
        ? {
            "candidateEmployment": [
              {
                "id": widget.emplomentData['id'].toString(),
                "companyName": txtComanyNameController.text,
                "jobTitle": txtDesignationController.text,
                "skillSet": selectedEmploymentType,
                "city": "Nagercoil",
                "stateName": "",
                "employedFrom": _startDateController.text,
                "employedTo": _selectedOption == 'No'
                    ? _endDateController.text
                    : '1970-01-01',
                "leavingReason": txtDescriptionController.text,
                "referenceName": "",
                "referencePhone": "",
                "referenceEmail": "",
                "referenceRelationship": "",
                "is_current": _selectedOption == 'No' ? false : true,
                "countryId": "US",
                "workType": selectedWorkType
                /*"employedFrom1": startYear,
          "employedTo1": endYear*/
              }
            ]
          }
        : {
            "candidateEmployment": [
              {
                "companyName": txtComanyNameController.text,
                "jobTitle": txtDesignationController.text,
                "skillSet": selectedEmploymentType,
                "city": "Nagercoil",
                "stateName": "",
                "employedFrom": _startDateController.text,
                "employedTo": _selectedOption == 'No'
                    ? _endDateController.text
                    : '1970-01-01',
                "leavingReason": txtDescriptionController.text,
                "referenceName": "",
                "referencePhone": "",
                "referenceEmail": "",
                "referenceRelationship": "",
                "is_current": _selectedOption == 'No' ? false : true,
                "countryId": "US",
                "workType": selectedWorkType
                /*"employedFrom1": startYear,
          "employedTo1": endYear*/
              }
            ]
          };

    if (kDebugMode) {
      print('Body Params : ${(bodyParams)}');
    }

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Fluttertoast.showToast(
        //   msg: "No internet connection",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Color(0xff2D2D2D),
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: 'No internet connection',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return; // Exit the function if no internet
      }
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 202) {
        fetchCandidateProfileData(
            retrievedUserData!.profileId, retrievedUserData!.token);
      }
    } catch (e) {
      setState(() {
        if (kDebugMode) {
          print(e);
        }
        isLoading = false;
      });
    }
  }

  DateTime parseDate(String dateString) {
    // Split the date string into its components
    List<String> parts = dateString.split('-');

    // Check if the format is valid
    if (parts.length != 3) {
      throw FormatException('Invalid date format. Use YY-MM-DD.');
    }

    // Parse the year, month, and day
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    // If the year is in 2 digits, adjust it to a 4-digit year
    if (year < 100) {
      year += (year < 70)
          ? 2000
          : 1900; // Assuming 00-69 is 21st century and 70-99 is 20th century
    }

    // Return the DateTime object
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 50,
                            child: Center(
                                child: Text(
                              'Back',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color: Colors.white),
                            ))))
                  ],
                ),
                //SizedBox(width: 80,)
                Text(
                  'Work Experience',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '       ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.all(16),
                      color: Color(0xffFCFCFC),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.015,
                              ),
                              child: Text(
                                'Current Designation',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff333333)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width) - 20,
                              child: TextField(
                                controller: txtDesignationController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff7D7C7C)),
                                decoration: InputDecoration(
                                    hintText: 'Designation',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: _isDesignationValid
                                              ? Color(0xffd9d9d9d9)
                                              : Color(
                                                  0xffBA1A1A), // Default border color
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: _isDesignationValid
                                              ? Color(0xff004C99)
                                              : Color(
                                                  0xffBA1A1A), // Border color when focused
                                          width: 1),
                                    ),
                                    errorText: _isDesignationValid
                                        ? null
                                        : designationErrorMsg,
                                    // Display error message if invalid
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9\s]')),
                                ],
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    _isDesignationValid = true;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.015,
                              ),
                              child: Text(
                                'Company Name',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff333333)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width) - 20,
                              child: TextField(
                                controller: txtComanyNameController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff7D7C7C)),
                                decoration: InputDecoration(
                                    hintText: 'Company',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: _isCompanyNameValid
                                              ? Color(0xffd9d9d9)
                                              : Color(
                                                  0xffBA1A1A), // Default border color
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: _isCompanyNameValid
                                              ? Color(0xff004C99)
                                              : Color(
                                                  0xffBA1A1A), // Border color when focused
                                          width: 1),
                                    ),
                                    errorText: _isCompanyNameValid
                                        ? null
                                        : companyNameErrorMsg,
                                    // Display error message if invalid
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9\s]')),
                                ],
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    _isCompanyNameValid = true;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Is this your current company?',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Lato',
                                  color: Color(0xff333333)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Radio<String>(
                                          value: 'Yes',
                                          groupValue: _selectedOption,
                                          activeColor: Color(0xff415F91),
                                          visualDensity: VisualDensity.compact,
                                          fillColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.selected)) {
                                              return Color(0xff004C99);
                                            }
                                            return Color(0xffD1D1D6);
                                          }),
                                          overlayColor: WidgetStateProperty
                                              .resolveWith<Color>(
                                            (states) => Colors.transparent,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedOption = value;
                                              _endDateController.text = '';
                                              isEndDateValid = true;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 5), // Space between Yes and No
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Radio<String>(
                                          value: 'No',
                                          groupValue: _selectedOption,
                                          activeColor: Color(0xff415F91),
                                          visualDensity: VisualDensity.compact,
                                          fillColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (states.contains(
                                                WidgetState.selected)) {
                                              return Color(0xff004C99);
                                            }
                                            return Color(0xffD1D1D6);
                                          }),
                                          overlayColor: WidgetStateProperty
                                              .resolveWith<Color>(
                                            (states) => Colors.transparent,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              isEndDateValid = true;
                                              _selectedOption = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'No',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),
                                        child: Text(
                                          'Start Date',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Lato',
                                              color: Color(0xff333333)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextField(
                                        controller: _startDateController,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF505050)),
                                        decoration: InputDecoration(
                                            suffixIcon: Padding(
                                              padding: EdgeInsets.all(7),
                                              child: SvgPicture.asset(
                                                'assets/icon/Calendar.svg',
                                                width: 24,
                                                height: 24,
                                              ),
                                            ),
                                            hintText: 'From',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: isStartDateValid
                                                      ? Color(0xffd9d9d9)
                                                      : Color(
                                                          0xffBA1A1A), // Default border color
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: isStartDateValid
                                                      ? Color(0xff004C99)
                                                      : Color(
                                                          0xffBA1A1A), // Border color when focused
                                                  width: 1),
                                            ),
                                            errorText: isStartDateValid
                                                ? null
                                                : startDateErrorMsg, // Display error message if invalid
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10)),
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now()
                                                      .subtract(
                                                          Duration(days: 1)),
                                                  firstDate: DateTime(2000),
                                                  //lastDate: DateTime(2101),
                                                  lastDate: DateTime.now()
                                                      .subtract(
                                                          Duration(days: 1)),
                                                  initialDatePickerMode:
                                                      DatePickerMode.year);
                                          if (pickedDate != null) {
                                            setState(() {
                                              isStartDateValid = true;
                                              _startDateSelected = true;
                                              startDatems = pickedDate;
                                              //_startDateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                              _startDateController.text =
                                                  "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                              startYear =
                                                  '${pickedDate.month}-${pickedDate.year}';
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),
                                        child: Text(
                                          'End Date',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Lato',
                                              color: Color(0xff333333)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextField(
                                        controller: _endDateController,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF505050)),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          hintText: _selectedOption == 'No'
                                              ? 'To'
                                              : 'Present',
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.all(7),
                                            child: SvgPicture.asset(
                                              'assets/icon/Calendar.svg',
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: isEndDateValid
                                                    ? Color(0xffd9d9d9)
                                                    : Color(0xffBA1A1A),
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: isEndDateValid
                                                    ? Color(0xff004C99)
                                                    : Color(0xffBA1A1A),
                                                width: 1),
                                          ),
                                          errorText: isEndDateValid
                                              ? null
                                              : endDateErrorMsg,
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          if (_selectedOption == 'No' &&
                                              _startDateSelected == true) {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: startDatems,
                                                    firstDate: startDatems,
                                                    lastDate: DateTime.now(),
                                                    initialDatePickerMode:
                                                        DatePickerMode.year);
                                            if (pickedDate != null) {
                                              setState(() {
                                                isEndDateValid = true;
                                                //_endDateController.text ="${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                _endDateController.text =
                                                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                                //_endDateController.text ="${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                endYear =
                                                    '${pickedDate.month}-${pickedDate.year}';
                                              });
                                            }
                                          } else if (_selectedOption == 'No' &&
                                              _startDateSelected == false) {
                                            // Fluttertoast.showToast(
                                            //   msg: 'Please select start date first',
                                            //   toastLength: Toast.LENGTH_SHORT,
                                            //   gravity: ToastGravity.BOTTOM,
                                            //   timeInSecForIosWeb: 1,
                                            //   backgroundColor: Color(0xff2D2D2D),
                                            //   textColor: Colors.white,
                                            //   fontSize: 16.0,
                                            // );
                                            IconSnackBar.show(
                                              context,
                                              label:
                                                  'Please select start date first',
                                              snackBarType: SnackBarType.alert,
                                              backgroundColor:
                                                  Color(0xff2D2D2D),
                                              iconColor: Colors.white,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.015,
                              ),
                              child: Text(
                                'Work type',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    color: Color(0xff333333)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: isWorkTypeValid
                                          ? Color(0xffD9D9D9)
                                          : Color(0xffBA1A1A)),
                                  borderRadius: BorderRadius.circular(10)),
                              width: (MediaQuery.of(context).size.width) - 20,
                              child: InkWell(
                                onTap: () {
                                  showMaterialModalBottomSheet(
                                    backgroundColor: Color(0x00000000),
                                    isDismissible: true,
                                    context: context,
                                    builder: (context) => Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 10),
                                      color: Color(0xffFCFCFC),
                                      decoration: BoxDecoration(
                                        color: Color(0xffFCFCFC),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        ),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black, // Adjust color
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          ListTile(
                                            //leading: Icon(Icons.visibility_outlined),
                                            title: Text('On Site'),
                                            onTap: () {
                                              setState(() {
                                                selectedWorkType = 'On Site';
                                                isWorkTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            //leading: Icon(Icons.refresh),
                                            title: Text('Hybrid'),
                                            onTap: () {
                                              setState(() {
                                                selectedWorkType = 'Hybrid';
                                                isWorkTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            //leading: Icon(Icons.download),
                                            title: Text('Work from home'),
                                            onTap: () {
                                              setState(() {
                                                selectedWorkType =
                                                    'Work from home';
                                                isWorkTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    selectedWorkType.isEmpty
                                        ? 'Select your work type'
                                        : selectedWorkType,
                                    style: TextStyle(color: Color(0xFF505050)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.015,
                              ),
                              child: Text(
                                'Employment Type',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    color: Color(0xff333333)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: isWorkTypeValid
                                          ? Color(0xffD9D9D9)
                                          : Color(0xffBA1A1A)),
                                  borderRadius: BorderRadius.circular(10)),
                              width: (MediaQuery.of(context).size.width) - 20,
                              child: InkWell(
                                onTap: () {
                                  showMaterialModalBottomSheet(
                                    isDismissible: true,
                                    context: context,
                                    backgroundColor: Colors
                                        .transparent, // Fix: Removes default background
                                    builder: (context) => Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffFCFCFC),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              20), // Top-left corner
                                          topRight: Radius.circular(
                                              20), // Top-right corner
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 10),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          ListTile(
                                            title: Text('Full time'),
                                            onTap: () {
                                              setState(() {
                                                selectedEmploymentType =
                                                    'Full time';
                                                isEmploymentTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Part time'),
                                            onTap: () {
                                              setState(() {
                                                selectedEmploymentType =
                                                    'Part time';
                                                isEmploymentTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Internship'),
                                            onTap: () {
                                              setState(() {
                                                selectedEmploymentType =
                                                    'Internship';
                                                isEmploymentTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Freelance'),
                                            onTap: () {
                                              setState(() {
                                                selectedEmploymentType =
                                                    'Freelance';
                                                isEmploymentTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Self-employed'),
                                            onTap: () {
                                              setState(() {
                                                selectedEmploymentType =
                                                    'Self-employed';
                                                isEmploymentTypeValid = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    selectedEmploymentType.isEmpty
                                        ? 'Select your employment type'
                                        : selectedEmploymentType,
                                    style: TextStyle(color: Color(0xFF505050)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.015,
                              ),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff333333)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width) - 20,
                              child: TextField(
                                maxLines: 4,
                                maxLength: maxLength,
                                controller: txtDescriptionController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff7D7C7C)),
                                decoration: InputDecoration(
                                    hintText: 'Your work experience',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: _isDescriptionValid
                                              ? Color(0xffd9d9d9)
                                              : Color(
                                                  0xffBA1A1A), // Default border color
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: _isDescriptionValid
                                              ? Color(0xff004C99)
                                              : Color(
                                                  0xffBA1A1A), // Border color when focused
                                          width: 1),
                                    ),
                                    errorText: _isDescriptionValid
                                        ? null
                                        : descriptionErrorMsg,
                                    // Display error message if invalid
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9\s]')),
                                ],
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    _isDescriptionValid = true;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            InkWell(
                              onTap: () {
                                if ((_selectedOption == 'No' &&
                                        _endDateController.text.isEmpty) ||
                                    txtDesignationController.text.isEmpty ||
                                    txtComanyNameController.text.isEmpty ||
                                    txtDescriptionController.text.isEmpty ||
                                    _startDateController.text.isEmpty ||
                                    selectedWorkType.isEmpty ||
                                    selectedEmploymentType.isEmpty) {
                                  if (txtDesignationController.text.isEmpty) {
                                    setState(() {
                                      _isDesignationValid = false;
                                    });
                                  }

                                  if (txtComanyNameController.text.isEmpty) {
                                    setState(() {
                                      _isCompanyNameValid = false;
                                    });
                                  }

                                  if (_startDateController.text.isEmpty) {
                                    setState(() {
                                      isStartDateValid = false;
                                    });
                                  }

                                  if (_selectedOption == 'No' &&
                                      _endDateController.text.isEmpty) {
                                    setState(() {
                                      isEndDateValid = false;
                                    });
                                  }

                                  if (selectedWorkType.isEmpty) {
                                    setState(() {
                                      isWorkTypeValid = false;
                                    });
                                  }

                                  if (selectedEmploymentType.isEmpty) {
                                    setState(() {
                                      isEmploymentTypeValid = false;
                                    });
                                  }

                                  if (txtDescriptionController.text.isEmpty) {
                                    setState(() {
                                      _isDescriptionValid = false;
                                    });
                                  }
                                } else {
                                  if (kDebugMode) {
                                    print(
                                        'Performing operation................');
                                  }

                                  if (isLoading == false) {
                                    updateEmployment();
                                  }
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 44,
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: isLoading
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: TweenAnimationBuilder<double>(
                                            tween:
                                                Tween<double>(begin: 0, end: 5),
                                            duration: Duration(seconds: 2),
                                            curve: Curves.linear,
                                            builder: (context, value, child) {
                                              return Transform.rotate(
                                                angle: value *
                                                    2 *
                                                    3.1416, // Full rotation effect
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 4,
                                                  value:
                                                      0.20, // 1/5 of the circle
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          142,
                                                          234,
                                                          232,
                                                          232), // Grey stroke
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .white), // White rotating stroke
                                                ),
                                              );
                                            },
                                            onEnd: () =>
                                                {}, // Ensures smooth infinite animation
                                          ),
                                        )
                                      : Text(
                                          'Save',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                            )
                          ]))))
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();

    if (widget.emplomentData != null) {
      setState(() {
        isEdit = true;
        txtDesignationController.text = widget.emplomentData['jobTitle'];
        txtComanyNameController.text = widget.emplomentData['companyName'];
        _startDateController.text = widget.emplomentData['employedFrom'];
        _endDateController.text =
            widget.emplomentData['employedTo'] == '1970-01-01'
                ? ''
                : widget.emplomentData['employedTo'];
        isStartDateValid = true;
        isEndDateValid = true;
        _startDateSelected = true;
        startDatems = parseDate(widget.emplomentData['employedFrom']);
        _selectedOption =
            widget.emplomentData['employedTo'] == '1970-01-01' ? 'Yes' : 'No';

        selectedWorkType =
            (widget.emplomentData['workType'] ?? '').toString().isEmpty
                ? 'On Site'
                : widget.emplomentData['workType'] ?? '';
        selectedEmploymentType =
            (widget.emplomentData['skillSet'] ?? '').toString().isEmpty
                ? 'Full time'
                : widget.emplomentData['skillSet'] ?? '';
        txtDescriptionController.text =
            (widget.emplomentData['leavingReason'] ?? '').toString().isEmpty
                ? 'test'
                : widget.emplomentData['leavingReason'] ?? '';

        if (selectedEmploymentType.toLowerCase().contains('boot')) {
          selectedEmploymentType = '';
        }
      });
    }
  }

  Future<void> fetchProfileFromPref() async {
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    UserCredentials? loadedCredentials =
        await UserCredentials.loadCredentials();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;
      if (loadedCredentials != null) {
        email = loadedCredentials.username;
      }
    });
  }
}
