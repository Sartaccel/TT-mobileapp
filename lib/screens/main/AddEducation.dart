import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
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

class Addeducation extends StatefulWidget {
  final educationDetail;
  const Addeducation({super.key, required this.educationDetail});

  @override
  State<Addeducation> createState() => _AddeducationState();
}

class _AddeducationState extends State<Addeducation> {
  bool isEdit = false;
  bool _hasChanges = false;

  DateTime startDatems = DateTime.now();

  ReferralData? referralData;
  UserData? retrievedUserData;

  String? graduatedFrom;
  String? graduatedTo;

  String? _selectedOption = 'No';
  String startYear = '', endYear = '';
  String? dateErrorMsg = 'Start date and end date are required';

  String selectedEducationType = '';
  bool isEducationTypeValid = true;

  bool isStartDateValid = true;
  bool _startDateSelected = false;
  String? startDateErrorMsg = 'Start date is required';
  final TextEditingController _startDateController = TextEditingController();

  bool isEndDateValid = true;
  String? endDateErrorMsg = 'End date is required';
  final TextEditingController _endDateController = TextEditingController();

  bool isQualificationValid = true;
  String? qualificationErrorMsg = 'Qualification is required';
  final TextEditingController txtQualificationController =
      TextEditingController();

  bool isSpecializationValid = true;
  String? specializationErrorMsg = 'Specialization is required';
  final TextEditingController txtSpecializationController =
      TextEditingController();

  bool isInstituteValid = true;
  String? instituteErrorMsg = 'Institute is required';
  final TextEditingController txtInstituteController = TextEditingController();

  bool isLoading = false;

  DateTime parseDate(String dateString) {
    try {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        return DateTime.parse(dateString);
      }

      List<String> parts = dateString.split('-');
      if (parts.length != 3) {
        throw FormatException('Invalid date format');
      }

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      if (year < 100) {
        year += (year < 70) ? 2000 : 1900;
      }

      return DateTime(year, month, day);
    } catch (e) {
      print('Date parse error: $e');
      return DateTime.now();
    }
  }

  String formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '1970-01-01') {
      return '';
    }

    try {
      DateTime date = DateTime.parse(dateString);
      return "${_twoDigit(date.day)}-${_twoDigit(date.month)}-${date.year}";
    } catch (e) {
      return '';
    }
  }

  String _twoDigit(int value) => value.toString().padLeft(2, '0');

  Future<void> updateEducation() async {
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.ADD_UPDATE_EDUCATION +
        retrievedUserData!.profileId.toString() +
        '/education');

    String finalGraduatedFrom =
        graduatedFrom ?? widget.educationDetail?['graduatedFrom'] ?? '';
    String finalGraduatedTo = _selectedOption == 'No'
        ? (graduatedTo ?? widget.educationDetail?['graduatedTo'] ?? '')
        : '1970-01-01';

    final bodyParams = isEdit
        ? {
            "candidateEducation": [
              {
                "id": widget.educationDetail['id'],
                "schoolName": txtInstituteController.text,
                "degree": txtQualificationController.text,
                "city": selectedEducationType,
                "stateName": "TN",
                "year": endYear,
                "countryId": "IN",
                "percentage": 78,
                "specialization": txtSpecializationController.text,
                "graduatedFrom": finalGraduatedFrom,
                "graduatedTo": finalGraduatedTo
              }
            ]
          }
        : {
            "candidateEducation": [
              {
                //"id" : 2064,
                "schoolName": txtInstituteController.text,
                "degree": txtQualificationController.text,
                "city": selectedEducationType,
                "stateName": "TN",
                "year": endYear,
                "countryId": "IN",
                "percentage": 78,
                "specialization": txtSpecializationController.text,
                "graduatedFrom": finalGraduatedFrom,
                "graduatedTo": finalGraduatedTo
              }
            ]
          };

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
          label: 'No internet connection, try again',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xff2D2D2D),
          elevation: 10,
          margin: EdgeInsets.only(bottom: 30, left: 15, right: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              SvgPicture.asset('assets/icon/success.svg'),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Educational Details updated !',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: Icon(Icons.close_rounded, color: Colors.white),
              )
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
      /*setState(() {
        isLoading = false;
      });*/
    } catch (e) {
      setState(() {
        if (kDebugMode) {
          print(e);
        }
        isLoading = false;
      });
    }
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
          setState(() {
            isLoading = false;
          });
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

  void showDiscardConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width - 35,
            padding: EdgeInsets.fromLTRB(22, 15, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discard changes?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to discard all changes?',
                  style: TextStyle(
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: 'lato'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    'Discard',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'lato'),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: SafeArea(
        child: Column(
          children: [
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
                            if (_hasChanges) {
                              showDiscardConfirmationDialog(context);
                            } else {
                              Navigator.pop(context);
                            }
                          }),
                      InkWell(
                          onTap: () {
                            if (_hasChanges) {
                              showDiscardConfirmationDialog(context);
                            } else {
                              Navigator.pop(context);
                            }
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
                    'Education',
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
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.only(left: 15, right: 15),
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
                          'Qualification',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: isQualificationValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                textCapitalization: TextCapitalization.none,
                                autocorrect: false,
                                enableSuggestions: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z0-9.\-'\s]"),
                                  ),
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'^ '),
                                  ),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      final text = newValue.text;
                                      if (text.contains('  ')) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    },
                                  ),
                                ],
                                controller: txtQualificationController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff333333)),
                                decoration: InputDecoration(
                                    hintText: 'Qualification',
                                    hintStyle:
                                        TextStyle(color: Color(0xff545454)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: isQualificationValid
                                              ? Color(0xffd9d9d9)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isQualificationValid
                                              ? Color(0xff004C99)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    isQualificationValid = true;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              SizedBox(height: 4),
                              if (!isQualificationValid)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    qualificationErrorMsg ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xffBA1A1A),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              SizedBox(height: isQualificationValid ? 20 : 7),
                            ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'Specialization',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Lato',
                              color: isSpecializationValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                textCapitalization: TextCapitalization.none,
                                autocorrect: false,
                                enableSuggestions: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s.,\-&']"),
                                  ),
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'^ '),
                                  ),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      final text = newValue.text;
                                      if (text.contains('  ')) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    },
                                  ),
                                ],
                                controller: txtSpecializationController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff333333)),
                                decoration: InputDecoration(
                                    hintText: 'Specialization',
                                    hintStyle:
                                        TextStyle(color: Color(0xff545454)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: isSpecializationValid
                                              ? Color(0xffd9d9d9)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: isSpecializationValid
                                              ? Color(0xff004C99)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    isSpecializationValid = true;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              SizedBox(height: 4),
                              if (!isSpecializationValid)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    specializationErrorMsg ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xffBA1A1A),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              SizedBox(height: isSpecializationValid ? 20 : 7),
                            ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'Institute name',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Lato',
                              color: isInstituteValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                textCapitalization: TextCapitalization.none,
                                autocorrect: false,
                                enableSuggestions: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s.,\-&']"),
                                  ),
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'^ '),
                                  ),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      final text = newValue.text;

                                      if (text.contains('  ')) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    },
                                  ),
                                ],
                                controller: txtInstituteController,
                                cursorColor: Color(0xff004C99),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: Color(0xff333333)),
                                decoration: InputDecoration(
                                    hintText: 'Institute',
                                    hintStyle:
                                        TextStyle(color: Color(0xff545454)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: isInstituteValid
                                              ? Color(0xffd9d9d9)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: isInstituteValid
                                              ? Color(0xff004C99)
                                              : Color(0xffBA1A1A),
                                          width: 1),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)),
                                onChanged: (value) {
                                  // Validate the email here and update _isEmailValid
                                  setState(() {
                                    isInstituteValid = true;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              SizedBox(height: 4),
                              if (!isInstituteValid)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    instituteErrorMsg ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xffBA1A1A),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              SizedBox(height: isInstituteValid ? 20 : 7),
                            ]),
                      ),
                      Text(
                        'Are you currently studying here?',
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
                                    fillColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Color(0xff004C99);
                                      }
                                      return Color(0xffD1D1D6);
                                    }),
                                    overlayColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (states) => Colors.transparent,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption = value;
                                        _endDateController.text = '';
                                        isEndDateValid = true;
                                        _hasChanges = true;
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
                                    fillColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return Color(0xff004C99);
                                      }
                                      return Color(0xffD1D1D6);
                                    }),
                                    overlayColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (states) => Colors.transparent,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        isEndDateValid = true;
                                        _selectedOption = value;
                                        _hasChanges = true;
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
                        height: 20,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                              color: isStartDateValid
                                                  ? Color(0xff333333)
                                                  : Color(0xffBA1A1A)),
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      TextField(
                                        controller: _startDateController,
                                        cursorColor: Color(0xff004C99),
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
                                                      : Color(0xffBA1A1A),
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: isStartDateValid
                                                      ? Color(0xff004C99)
                                                      : Color(0xffBA1A1A),
                                                  width: 1),
                                            ),
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
                                                  lastDate: DateTime.now()
                                                      .subtract(
                                                          Duration(days: 1)),
                                                  initialDatePickerMode:
                                                      DatePickerMode.year);
                                          if (pickedDate != null) {
                                            setState(() {
                                              startDatems = pickedDate;
                                              isStartDateValid = true;
                                              _startDateSelected = true;

                                              // For UI (DD-MM-YYYY)
                                              _startDateController.text =
                                                  "${_twoDigit(pickedDate.day)}-${_twoDigit(pickedDate.month)}-${pickedDate.year}";

                                              // For backend (YYYY-MM-DD)
                                              graduatedFrom =
                                                  "${pickedDate.year}-${_twoDigit(pickedDate.month)}-${_twoDigit(pickedDate.day)}";

                                              startYear =
                                                  pickedDate.year.toString();
                                              _hasChanges = true;
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
                                              color: isEndDateValid
                                                  ? Color(0xff333333)
                                                  : Color(0xffBA1A1A)),
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      TextField(
                                        controller: _endDateController,
                                        cursorColor: Color(0xff004C99),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF505050)),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          hintText: 'To',
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
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: isEndDateValid
                                                  ? Color(0xff004C99)
                                                  : Color(0xffBA1A1A),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        readOnly: true,
                                        onChanged: (text) {
                                          // Validate input as user types
                                          setState(() {
                                            isEndDateValid = text.isNotEmpty;
                                            _hasChanges = true;
                                          });
                                        },
                                        onTap: () async {
                                          // Allow date picking regardless of option
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: startDatems,
                                            firstDate: startDatems,
                                            lastDate: DateTime.now(),
                                            initialDatePickerMode:
                                                DatePickerMode.year,
                                          );
                                          if (pickedDate != null) {
                                            setState(() {
                                              isEndDateValid = true;

                                              // For UI (DD-MM-YYYY)
                                              _endDateController.text =
                                                  "${_twoDigit(pickedDate.day)}-${_twoDigit(pickedDate.month)}-${pickedDate.year}";

                                              // For backend (YYYY-MM-DD)
                                              graduatedTo =
                                                  "${pickedDate.year}-${_twoDigit(pickedDate.month)}-${_twoDigit(pickedDate.day)}";

                                              endYear =
                                                  pickedDate.year.toString();
                                              _hasChanges = true;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            if (!isStartDateValid || !isEndDateValid)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  dateErrorMsg ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffBA1A1A),
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                            SizedBox(
                                height: !isStartDateValid || !isEndDateValid
                                    ? 7
                                    : 20),
                          ]),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'Education type',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Lato',
                              color: isEducationTypeValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: isEducationTypeValid
                                    ? Color(0xffd9d9d9)
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
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.black, // Adjust color
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    ListTile(
                                      //leading: Icon(Icons.visibility_outlined),
                                      title: Text('Full time'),
                                      onTap: () {
                                        setState(() {
                                          selectedEducationType = 'Full time';
                                          isEducationTypeValid = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      //leading: Icon(Icons.refresh),
                                      title: Text('Part time'),
                                      onTap: () {
                                        setState(() {
                                          selectedEducationType = 'Part time';
                                          isEducationTypeValid = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      //leading: Icon(Icons.download),
                                      title: Text('Correspondence'),
                                      onTap: () {
                                        setState(() {
                                          selectedEducationType =
                                              'Correspondence';
                                          isEducationTypeValid = true;
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
                              selectedEducationType.isEmpty
                                  ? 'Select your education type'
                                  : selectedEducationType,
                              style: TextStyle(color: Color(0xFF505050)),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: !isEducationTypeValid,
                          child: Column(
                            children: [
                              SizedBox(height: 4),
                              Text(
                                'Education type cannot be empty',
                                style: TextStyle(
                                    color: Color(0xffBA1A1A), fontSize: 12),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: InkWell(
                onTap: () {
                  if ((_selectedOption == 'No' &&
                          _endDateController.text.isEmpty) ||
                      txtQualificationController.text.isEmpty ||
                      txtSpecializationController.text.isEmpty ||
                      txtInstituteController.text.isEmpty ||
                      _startDateController.text.isEmpty) {
                    if (txtQualificationController.text.isEmpty) {
                      setState(() {
                        isQualificationValid = false;
                      });
                    }

                    if (txtSpecializationController.text.isEmpty) {
                      setState(() {
                        isSpecializationValid = false;
                      });
                    }

                    if (txtInstituteController.text.isEmpty) {
                      setState(() {
                        isInstituteValid = false;
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

                    if (selectedEducationType.isEmpty) {
                      setState(() {
                        isEducationTypeValid = false;
                      });
                    }
                  } else {
                    if (kDebugMode) {
                      print('Performing operation................');
                    }

                    if (isLoading == false) {
                      updateEducation();
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
                              tween: Tween<double>(begin: 0, end: 5),
                              duration: Duration(seconds: 2),
                              curve: Curves.linear,
                              builder: (context, value, child) {
                                return Transform.rotate(
                                  angle: value * 2 * 3.1416,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    value: 0.20,
                                    backgroundColor: const Color.fromARGB(
                                        142, 234, 232, 232),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                );
                              },
                              onEnd: () => {},
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();

    if (widget.educationDetail != null) {
      setState(() {
        isEdit = true;
        txtQualificationController.text = widget.educationDetail['degree'];
        txtSpecializationController.text =
            widget.educationDetail['specialization'];
        txtInstituteController.text = widget.educationDetail['schoolName'];

        // Convert YYYY-MM-DD to DD-MM-YYYY for display
        if (widget.educationDetail['graduatedFrom'] != null) {
          DateTime fromDate =
              parseDate(widget.educationDetail['graduatedFrom']);
          _startDateController.text =
              "${_twoDigit(fromDate.day)}-${_twoDigit(fromDate.month)}-${fromDate.year}";
          graduatedFrom = widget.educationDetail['graduatedFrom'];
          startYear = fromDate.year.toString();
        }

        _selectedOption = widget.educationDetail['graduatedTo'] == '1970-01-01'
            ? 'Yes'
            : 'No';

        if (widget.educationDetail['graduatedTo'] != null &&
            widget.educationDetail['graduatedTo'] != '1970-01-01') {
          DateTime toDate = parseDate(widget.educationDetail['graduatedTo']);
          _endDateController.text =
              "${_twoDigit(toDate.day)}-${_twoDigit(toDate.month)}-${toDate.year}";
          graduatedTo = widget.educationDetail['graduatedTo'];
          endYear = toDate.year.toString();
        }

        isStartDateValid = true;
        isEndDateValid = true;
        _startDateSelected = true;
        startDatems =
            parseDate(widget.educationDetail['graduatedFrom'] ?? '1970-01-01');
        selectedEducationType = widget.educationDetail['city'];
      });
    }
  }

  Future<void> fetchProfileFromPref() async {
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;
    });
  }
}
