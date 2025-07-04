import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/intermediate/send_verification_code.dart';

class EditPersonalDetails extends StatefulWidget {
  const EditPersonalDetails({super.key});

  @override
  State<EditPersonalDetails> createState() => _EditPersonalDetailsState();
}

class _EditPersonalDetailsState extends State<EditPersonalDetails> {
  bool isLoading = false;
  bool _hasChanges = false;
  bool isStartDateValid = true;
  bool _startDateSelected = false;
  String emailErrorMessage = '';
  String mobileErrorMessage = '';
  String selectedExpType = '';
  String selectedMonType = '';
  String? experience;
  String? expMonth;

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController currentPositionController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController experienceYearController = TextEditingController();
  TextEditingController experienceMonthController = TextEditingController();

  String? startDateErrorMsg = 'Date of Birth is required';
  final TextEditingController _startDateController = TextEditingController();

  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;
  bool _isEmailValid = true;
  bool _isMobileNumberValid = true;
  bool _isLocationValid = true;
  bool _isDobValid = true;
  bool _isPositionValid = true;
  bool _isExperienceValid = true;

  int? selectedYear;
  int? selectedMonth;

  CandidateProfileModel? candidateProfileModel;
  UserData? retrievedUserData;

  String getFinalExperience() {
    return (selectedExpType == "0 Years" || selectedExpType == "Fresher") &&
            selectedMonType == "0 Months"
        ? "Fresher"
        : "$selectedExpType $selectedMonType";
  }

  String? _selectedCountryCode = '+91';
  final List<String> countryOptions = [
    '+1',
    '+7',
    '+20',
    '+27',
    '+30',
    '+31',
    '+32',
    '+33',
    '+34',
    '+36',
    '+39',
    '+40',
    '+41',
    '+43',
    '+44',
    '+45',
    '+46',
    '+47',
    '+48',
    '+49',
    '+51',
    '+52',
    '+53',
    '+54',
    '+55',
    '+56',
    '+57',
    '+58',
    '+60',
    '+61',
    '+62',
    '+63',
    '+64',
    '+65',
    '+66',
    '+81',
    '+82',
    '+84',
    '+86',
    '+90',
    '+91',
    '+92',
    '+93',
    '+94',
    '+95',
    '+98',
    '+211',
    '+212',
    '+213',
    '+216',
    '+218',
    '+220',
    '+221',
    '+222',
    '+223',
    '+224',
    '+225',
    '+226',
    '+227',
    '+228',
    '+229',
    '+230',
    '+231',
    '+232',
    '+233',
    '+234',
    '+235',
    '+236',
    '+237',
    '+238',
    '+239',
    '+240',
    '+241',
    '+242',
    '+243',
    '+244',
    '+245',
    '+248',
    '+249',
    '+250',
    '+251',
    '+252',
    '+253',
    '+254',
    '+255',
    '+256',
    '+257',
    '+258',
    '+260',
    '+261',
    '+262',
    '+263',
    '+264',
    '+265',
    '+266',
    '+267',
    '+268',
    '+269',
    '+290',
    '+291',
    '+297',
    '+298',
    '+299',
    '+350',
    '+351',
    '+352',
    '+353',
    '+354',
    '+355',
    '+356',
    '+357',
    '+358',
    '+359',
    '+370',
    '+371',
    '+372',
    '+373',
    '+374',
    '+375',
    '+376',
    '+377',
    '+378',
    '+379',
    '+380',
    '+381',
    '+382',
    '+383',
    '+385',
    '+386',
    '+387',
    '+389',
    '+420',
    '+421',
    '+423',
    '+500',
    '+501',
    '+502',
    '+503',
    '+504',
    '+505',
    '+506',
    '+507',
    '+508',
    '+509',
    '+590',
    '+591',
    '+592',
    '+593',
    '+594',
    '+595',
    '+596',
    '+597',
    '+598',
    '+599',
    '+670',
    '+672',
    '+673',
    '+674',
    '+675',
    '+676',
    '+677',
    '+678',
    '+679',
    '+680',
    '+681',
    '+682',
    '+683',
    '+685',
    '+686',
    '+687',
    '+688',
    '+689',
    '+690',
    '+691',
    '+692',
    '+850',
    '+852',
    '+853',
    '+855',
    '+856',
    '+880',
    '+886',
    '+960',
    '+961',
    '+962',
    '+963',
    '+964',
    '+965',
    '+966',
    '+967',
    '+968',
    '+970',
    '+971',
    '+972',
    '+973',
    '+974',
    '+975',
    '+976',
    '+977',
    '+992',
    '+993',
    '+994',
    '+995',
    '+996',
    '+998'
  ];

  String mobileErrorMsg = 'Enter a valid mobile number';

  void extractCountryCodeAndNumber(String fullMobile) {
    String countryCode = '';
    String mobileNumber = '';

    for (String code in countryOptions) {
      if (fullMobile.startsWith(code)) {
        countryCode = code;
        mobileNumber = fullMobile.substring(code.length);
        break;
      }
    }

    if (countryCode.isEmpty) {
      print('Invalid number, no matching country code found.');
    } else {
      print('Country Code: $countryCode');
      print('Mobile Number: $mobileNumber');

      setState(() {
        mobileController.text = mobileNumber;
        _selectedCountryCode = countryCode;
      });
    }
  }

  String extractDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate =
        "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
    return formattedDate;
  }

  Future<void> fetchProfileFromPref() async {
    try {
      CandidateProfileModel? _candidateProfileModel =
          await getCandidateProfileData();
      UserData? _retrievedUserData = await getUserData();

      if (_candidateProfileModel == null || _retrievedUserData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load profile data'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_candidateProfileModel.mobile != null) {
        extractCountryCodeAndNumber(_candidateProfileModel.mobile!);
      }

      setState(() {
        candidateProfileModel = _candidateProfileModel;
        retrievedUserData = _retrievedUserData;

        fNameController.text = _candidateProfileModel.firstName ?? '';
        lNameController.text = _candidateProfileModel.lastName ?? '';
        emailController.text = _candidateProfileModel.email ?? '';
        locationController.text = _candidateProfileModel.location ?? '';

        if (_candidateProfileModel.dateOfBirth != null) {
          _startDateController.text =
              extractDate(_candidateProfileModel.dateOfBirth!);
        } else {
          _startDateController.text = '';
        }

        currentPositionController.text = _candidateProfileModel.position ?? '';

        int years = (_candidateProfileModel.experience ?? 0).toInt();
        int months = (_candidateProfileModel.expMonth ?? 0).toInt();

        if (years == 0 && months == 0) {
          selectedExpType = "Fresher";
          selectedMonType = "0 Months";
        } else {
          selectedExpType =
              years > 0 ? "$years ${years == 1 ? 'Year' : 'Years'}" : "";
          selectedMonType = months > 0
              ? "$months ${months == 1 ? 'Month' : 'Months'}"
              : "0 Months";
        }

        experienceController.text = ((years * 12) + months).toString();
      });
    } catch (e) {
      print('Error in fetchProfileFromPref: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    final url = Uri.parse(
      "${AppConstants.BASE_URL}${AppConstants.CANDIDATE_PROFILE}/$profileId",
    );

    print("🔍 Fetching profile from: $url");

    try {
      setState(() => isLoading = true);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📦 Response Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final resObj = jsonDecode(response.body);

        if (resObj['message']?.toLowerCase().contains('success') ?? false) {
          if (resObj['data'] != null) {
            final Map<String, dynamic> data = resObj['data'];
            final candidateData = CandidateProfileModel.fromJson(data);

            // Save and update UI
            await saveCandidateProfileData(candidateData);

            setState(() {
              candidateProfileModel = candidateData; // ✅ This updates the UI
            });

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
                        'Personal details updated!',
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
          } else {
            print("⚠️ 'data' field is missing in the response.");
          }
        } else {
          IconSnackBar.show(
            context,
            label: resObj['message'] ?? 'Failed to fetch profile',
            snackBarType: SnackBarType.fail,
          );
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        IconSnackBar.show(
          context,
          label: errorResponse['message'] ??
              'Server error: ${response.statusCode}',
          snackBarType: SnackBarType.fail,
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      IconSnackBar.show(
        context,
        label: 'Something went wrong. Please try again.',
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    final url = Uri.parse(
        AppConstants.BASE_URL + AppConstants.UPDATE_CANDIDATE_PROFILE);

    // Format date from DD-MM-YYYY to YYYY-MM-DD
    final dobInput = _startDateController.text;
    String formattedDate;

    try {
      final parsedDate = DateFormat("dd-MM-yyyy").parse(dobInput);
      formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Invalid date format. Use DD-MM-YYYY',
        snackBarType: SnackBarType.fail,
      );
      return;
    }
    int totalExperienceInMonths = 0;
    if (selectedExpType != "Fresher") {
      final yearMatch = RegExp(r'(\d+)').firstMatch(selectedExpType ?? '');
      final monthMatch = RegExp(r'(\d+)').firstMatch(selectedMonType ?? '');

      int years =
          yearMatch != null ? int.tryParse(yearMatch.group(1)!) ?? 0 : 0;
      int months =
          monthMatch != null ? int.tryParse(monthMatch.group(1)!) ?? 0 : 0;

      totalExperienceInMonths = (years * 12) + months;
    }
    final bodyParams = {
      "id": retrievedUserData!.profileId,
      "firstName": fNameController.text,
      "lastName": lNameController.text,
      "email": emailController.text,
      "mobile": _selectedCountryCode! + mobileController.text,
      "experience": totalExperienceInMonths,
      "location": locationController.text,
      "gender": "M",
      "position": currentPositionController.text,
      "dateOfBirth": formattedDate
    };

    // Debug log
    print('Sending update request with body: ${jsonEncode(bodyParams)}');

    try {
      setState(() => isLoading = true);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      print(
          'Response code ${response.statusCode} :: Response => ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        fetchCandidateProfileData(
            retrievedUserData!.profileId, retrievedUserData!.token);
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
                    'Profile updated successfully!',
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
      } else {
        // Show error from server
        final errorResponse = jsonDecode(response.body);
        IconSnackBar.show(
          context,
          label: errorResponse['message'] ?? 'Failed to update profile',
          snackBarType: SnackBarType.fail,
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      IconSnackBar.show(
        context,
        label: 'Error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  int getValidLengthForCountry(String countryCode) {
    switch (countryCode) {
      case '+93':
        return 9; // Afghanistan
      case '+61':
        return 9; // Australia
      case '+43':
        return 11; // Austria
      case '+32':
        return 9; // Belgium
      case '+55':
        return 11; // Brazil
      case '+1':
        return 10; // Canada & USA
      case '+86':
        return 11; // China
      case '+33':
        return 10; // France
      case '+49':
        return 11; // Germany
      case '+91':
        return 10; // India
      case '+39':
        return 10; // Italy (average)
      case '+81':
        return 10; // Japan
      case '+52':
        return 10; // Mexico
      case '+31':
        return 9; // Netherlands
      case '+64':
        return 9; // New Zealand
      case '+47':
        return 8; // Norway
      case '+27':
        return 10; // South Africa
      case '+34':
        return 9; // Spain
      case '+46':
        return 10; // Sweden
      case '+41':
        return 9; // Switzerland
      case '+44':
        return 10; // United Kingdom
      default:
        return 10; // Fallback length
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
  }

  void _showVerificationDialog(String type, VoidCallback onContinue) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      'Verify Now',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      type == 'email'
                          ? 'A OTP will be sent to your email.'
                          : 'A OTP will be sent to your Mobile number.',
                      style: TextStyle(
                          height: 1.4,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
                                          width: 1,
                                          color: AppColors.primaryColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: AppColors.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await Future.delayed(
                                      Duration(milliseconds: 800));

                                  setState(() {
                                    isLoading = false;
                                  });

                                  Navigator.pop(context); // Close dialog
                                  onContinue(); // Proceed to next screen
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child:
                                                TweenAnimationBuilder<double>(
                                              tween: Tween<double>(
                                                  begin: 0, end: 5),
                                              duration: Duration(seconds: 2),
                                              curve: Curves.linear,
                                              builder: (context, value, child) {
                                                return Transform.rotate(
                                                  angle: value * 2 * 3.1416,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 4,
                                                    value: 0.20,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            142, 234, 232, 232),
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Text(
                                            'Verify',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
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
            );
          },
        );
      },
    );
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
      body: Stack(
        children: [
          Column(
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
                            icon: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white),
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
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: Color(0xffFCFCFC),
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        _buildFirstNameField(),
                        _buildLastNameField(),
                        _buildEmailField(),
                        _buildMobileNumberField(),
                        _buildLocationField(),
                        _buildDateOfBirthField(),
                        _buildCurrentPositionField(),
                        _buildExperienceField(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Save button positioned at the bottom
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'First Name',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: _isFirstNameValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          controller: fNameController,
          cursorColor: Color(0xff004C99),
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your first name',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    _isFirstNameValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    _isFirstNameValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z ]'),
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
          onChanged: (value) {
            setState(() {
              _isFirstNameValid = true;
              _hasChanges = true;
            });
          },
        ),
        if (!_isFirstNameValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'First name is required',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: _isFirstNameValid ? 20 : 7),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Last Name',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: _isLastNameValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z ]'),
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
          controller: lNameController,
          cursorColor: Color(0xff004C99),
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your last name',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isLastNameValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isLastNameValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            setState(() {
              _isLastNameValid = true;
              _hasChanges = true;
            });
          },
        ),
        if (!_isLastNameValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Last name is required',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: _isLastNameValid ? 20 : 7),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Email',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: _isEmailValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: emailController,
                cursorColor: Color(0xff004C99),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                  color: Color(0xff333333),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Color(0xff545454)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _isEmailValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _isEmailValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                      width: 1,
                    ),
                  ),
                  suffixIcon: candidateProfileModel?.isEmailVerified == 1
                      ? SvgPicture.asset('assets/images/verified_ic.svg')
                      : SvgPicture.asset('assets/images/pending_ic.svg'),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = true;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () async {
                if (emailController.text.trim().isEmpty) {
                  setState(() {
                    _isEmailValid = false;
                    emailErrorMessage = 'Email is required';
                  });
                  return;
                }

                if (candidateProfileModel?.isEmailVerified != 1) {
                  final result = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SendVerificationCode(
                        type: "email",
                        mobile: candidateProfileModel?.mobile,
                        email: candidateProfileModel?.email,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );

                  if (result == 'verified' && retrievedUserData != null) {
                    await fetchCandidateProfileData(
                      retrievedUserData!.profileId,
                      retrievedUserData!.token,
                    );
                  }
                }
              },
              child: Text(
                candidateProfileModel?.isEmailVerified == 1
                    ? 'Verified in Email'
                    : 'Verify',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xff004C99),
                ),
              ),
            ),
          ],
        ),
        if (!_isEmailValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Email is required',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: _isEmailValid ? 20 : 7),
      ],
    );
  }

  Widget _buildMobileNumberField() {
    int validLength = _selectedCountryCode != null
        ? getValidLengthForCountry(_selectedCountryCode!)
        : 10;

    String filteredMobileNumber = (() {
      if (candidateProfileModel?.mobile != null) {
        String cleanedMobile =
            candidateProfileModel!.mobile!.replaceAll(RegExp(r'[^\d+]'), '');
        return cleanedMobile.startsWith('+91') && cleanedMobile.length == 13
            ? cleanedMobile.substring(3)
            : cleanedMobile;
      }
      return '';
    })();

    if (mobileController.text.isEmpty && filteredMobileNumber.isNotEmpty) {
      mobileController.text = filteredMobileNumber;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color:
                  _isMobileNumberValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 49,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: _isMobileNumberValid
                      ? Color(0xffd9d9d9)
                      : Color(0xffBA1A1A),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(10),
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                underline: SizedBox(),
                icon: SvgPicture.asset('assets/icon/ArrowDown.svg',
                    height: 10, width: 10),
                style: TextStyle(
                    fontSize: 14, fontFamily: 'Lato', color: Color(0xFF333333)),
                items: countryOptions.map((code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(code,
                        style: TextStyle(fontSize: 14, fontFamily: 'Lato')),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCountryCode = val;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Expanded(
              child: TextField(
                maxLength: validLength,
                controller: mobileController,
                cursorColor: Color(0xff004C99),
                style: TextStyle(
                    fontSize: 14, fontFamily: 'Lato', color: Color(0xff333333)),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(color: Color(0xff545454)),
                  suffixIcon: candidateProfileModel?.isPhoneVerified == 1
                      ? SvgPicture.asset('assets/images/verified_ic.svg')
                      : SvgPicture.asset('assets/images/pending_ic.svg'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isMobileNumberValid
                          ? Color(0xffd9d9d9)
                          : Color(0xffBA1A1A),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isMobileNumberValid
                          ? Color(0xff004C99)
                          : Color(0xffBA1A1A),
                      width: 1,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _isMobileNumberValid = true;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: Center(
                child: InkWell(
                  onTap: () async {
                    if (mobileController.text.trim().isEmpty) {
                      setState(() {
                        _isMobileNumberValid = false;
                        mobileErrorMessage = 'Mobile number cannot be empty';
                      });
                      return;
                    }

                    if (mobileController.text.length != validLength) {
                      setState(() {
                        _isMobileNumberValid = false;
                        mobileErrorMessage =
                            'Enter a valid $validLength digit mobile number';
                      });
                      return;
                    }

                    if (candidateProfileModel?.isPhoneVerified != 1) {
                      final result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SendVerificationCode(
                            type: "phone",
                            mobile: candidateProfileModel?.mobile,
                            email: candidateProfileModel?.email,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );

                      if (result == 'verified' && retrievedUserData != null) {
                        await fetchCandidateProfileData(
                          retrievedUserData!.profileId,
                          retrievedUserData!.token,
                        );
                      }
                    }
                  },
                  child: Text(
                    candidateProfileModel?.isPhoneVerified == 1
                        ? 'Verified in Mobile Number'
                        : 'Verify',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xff004C99),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_isMobileNumberValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              mobileErrorMessage,
              style: TextStyle(
                  fontSize: 12, color: Color(0xffBA1A1A), fontFamily: 'Lato'),
            ),
          ),
        SizedBox(height: _isMobileNumberValid ? 20 : 7),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Location',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: _isLocationValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: locationController,
          cursorColor: Color(0xff004C99),
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your Location',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isLocationValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isLocationValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(40),
            FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-Z\s.,\-&']"),
            ),
            FilteringTextInputFormatter.deny(RegExp(r'^ ')),
            TextInputFormatter.withFunction(
              (oldValue, newValue) {
                if (newValue.text.contains('  ')) return oldValue;
                return newValue;
              },
            ),
          ],
          onChanged: (value) {
            setState(() {
              _isLocationValid = true;
              _hasChanges = true;
            });
          },
        ),
        if (!_isLocationValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Location is required',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: _isLocationValid ? 20 : 7),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Date of Birth',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: isStartDateValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          controller: _startDateController,
          cursorColor: Color(0xff004C99),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.all(7),
              child: SvgPicture.asset(
                'assets/icon/Calendar.svg',
                width: 24,
                height: 24,
              ),
            ),
            hintText: 'Date of Birth',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isStartDateValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isStartDateValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(Duration(days: 1)),
              firstDate: DateTime(1970),
              lastDate: DateTime.now().subtract(Duration(days: 1)),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (pickedDate != null) {
              setState(() {
                isStartDateValid = true;
                _startDateSelected = true;
                _startDateController.text =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
        ),
        if (!isStartDateValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              startDateErrorMsg ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: isStartDateValid ? 20 : 7),
      ],
    );
  }

  Widget _buildCurrentPositionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Current Position',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: _isPositionValid ? Color(0xff000000) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: currentPositionController,
          cursorColor: Color(0xff004C99),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your position',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isPositionValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _isPositionValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(40),
            FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-Z0-9\s.,\-&']"),
            ),
            FilteringTextInputFormatter.deny(RegExp(r'^ ')),
            TextInputFormatter.withFunction(
              (oldValue, newValue) {
                if (newValue.text.contains('  ')) return oldValue;
                return newValue;
              },
            ),
          ],
          onChanged: (value) {
            setState(() {
              _isPositionValid = true;
              _hasChanges = true;
            });
          },
        ),
        if (!_isPositionValid)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Position is required',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
        SizedBox(height: _isPositionValid ? 20 : 7),
      ],
    );
  }

  Widget _buildExperienceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            'Work Experience',
            style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
          ),
        ),
        SizedBox(height: 7),
        Row(
          children: [
            // Year Dropdown
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isDismissible: true,
                    context: context,
                    builder: (context) {
                      ScrollController scrollController = ScrollController();
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.365,
                        padding: EdgeInsets.only(top: 30, left: 10, right: 10),
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
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Color(0xff333333),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 20, right: 10),
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 5,
                                  radius: Radius.circular(10),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      scrollbarTheme: ScrollbarThemeData(
                                        thumbColor: WidgetStateProperty.all(
                                            Color(0xff545454)),
                                        trackColor: WidgetStateProperty.all(
                                            Color(0xffD9D9D9)),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        children: List.generate(21, (index) {
                                          String label = index == 0
                                              ? "0 Years"
                                              : index == 20
                                                  ? "20+ Years"
                                                  : "$index ${index > 1 ? 'Years' : 'Year'}";
                                          return ListTile(
                                              title: Text(label),
                                              onTap: () {
                                                setState(() {
                                                  selectedExpType = label;
                                                  saveStringToPreferences(
                                                      "searchExp", label);

                                                  if (label == "0 Years" &&
                                                      (selectedMonType ==
                                                              "0 Months" ||
                                                          selectedMonType
                                                              .isEmpty)) {
                                                    selectedExpType = "Fresher";
                                                    selectedMonType =
                                                        "0 Months";
                                                    saveStringToPreferences(
                                                        "searchExp", "Fresher");
                                                  }
                                                });
                                                Navigator.pop(context);
                                              });
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffd9d9d9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedExpType == null || selectedExpType!.isEmpty
                            ? 'Years'
                            : selectedExpType!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333333),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icon/ArrowDown.svg',
                        height: 10,
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            // Month Dropdown
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isDismissible: true,
                    context: context,
                    builder: (context) {
                      ScrollController scrollController = ScrollController();
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.365,
                        padding: EdgeInsets.only(top: 30, left: 10, right: 10),
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
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Color(0xff333333),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 20, right: 10),
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 5,
                                  radius: Radius.circular(10),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      scrollbarTheme: ScrollbarThemeData(
                                        thumbColor: WidgetStateProperty.all(
                                            Color(0xff545454)),
                                        trackColor: WidgetStateProperty.all(
                                            Color(0xffD9D9D9)),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        children: List.generate(12, (index) {
                                          String label = index == 0
                                              ? "0 Months"
                                              : index == 1
                                                  ? "1 Month"
                                                  : "$index Months";
                                          return ListTile(
                                              title: Text(label),
                                              onTap: () {
                                                setState(() {
                                                  selectedMonType = label;
                                                  saveStringToPreferences(
                                                      "searchMonth", label);

                                                  if ((selectedExpType ==
                                                              "0 Years" ||
                                                          selectedExpType
                                                              .isEmpty) &&
                                                      label == "0 Months") {
                                                    selectedExpType = "Fresher";
                                                    selectedMonType =
                                                        "0 Months";
                                                    saveStringToPreferences(
                                                        "searchExp", "Fresher");
                                                  }
                                                });
                                                Navigator.pop(context);
                                              });
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffd9d9d9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedMonType == null || selectedMonType!.isEmpty
                            ? 'Months'
                            : selectedMonType!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333333),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icon/ArrowDown.svg',
                        height: 10,
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: Color(0xFFFCFCFC).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              int validLength = _selectedCountryCode != null
                  ? getValidLengthForCountry(_selectedCountryCode!)
                  : 10;

              if (fNameController.text.isEmpty ||
                  lNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  mobileController.text.isEmpty ||
                  mobileController.text.length < validLength ||
                  mobileController.text.length > validLength ||
                  locationController.text.isEmpty ||
                  currentPositionController.text.isEmpty ||
                  experienceController.text.isEmpty ||
                  _startDateController.text.isEmpty) {
                setState(() {
                  _isFirstNameValid = fNameController.text.isNotEmpty;
                  _isLastNameValid = lNameController.text.isNotEmpty;
                  _isEmailValid = emailController.text.isNotEmpty;
                  _isMobileNumberValid = mobileController.text.isNotEmpty &&
                      mobileController.text.length == validLength;
                  _isLocationValid = locationController.text.isNotEmpty;
                  _isPositionValid = currentPositionController.text.isNotEmpty;
                  _isExperienceValid = experienceController.text.isNotEmpty;
                  isStartDateValid = _startDateController.text.isNotEmpty;

                  if (mobileController.text.isEmpty ||
                      mobileController.text.length != validLength) {
                    mobileErrorMsg =
                        'Enter a valid $validLength digits mobile number';
                  }
                });
              } else {
                if (kDebugMode) {
                  print('Processing........');
                }
                updateProfile().then((_) {
                  Navigator.pop(context);
                }).catchError((error) {
                  print('Error updating profile: $error');
                });
              }
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
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
                                backgroundColor:
                                    const Color.fromARGB(142, 234, 232, 232),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          },
                          onEnd: () {},
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
      ),
    );
  }
}
