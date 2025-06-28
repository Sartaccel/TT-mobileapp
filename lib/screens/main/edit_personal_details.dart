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
  bool isStartDateValid = true;
  bool _startDateSelected = false;
  String emailErrorMessage = '';
  String mobileErrorMessage = '';

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController currentPositionController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

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

  CandidateProfileModel? candidateProfileModel;
  UserData? retrievedUserData;

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
        experienceController.text =
            _candidateProfileModel.experience?.toString() ?? '0';
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
          'Authorization': 'Bearer $token', // Use Bearer if backend requires it
        },
      );

      print('📦 Response Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final resObj = jsonDecode(response.body);

        if (resObj['message']?.toLowerCase().contains('success') ?? false) {
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
          if (resObj['data'] != null) {
            final Map<String, dynamic> data = resObj['data'];
            final candidateData = CandidateProfileModel.fromJson(data);
            await saveCandidateProfileData(candidateData);
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

    final bodyParams = {
      "id": retrievedUserData!.profileId,
      "firstName": fNameController.text,
      "lastName": lNameController.text,
      "email": emailController.text,
      "mobile": _selectedCountryCode! + mobileController.text,
      "experience": int.tryParse(experienceController.text) ?? 0,
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
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
                color: _isEmailValid ? Color(0xff000000) : Color(0xffBA1A1A)),
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
                  await Navigator.push(
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

                  if (retrievedUserData != null) {
                    fetchCandidateProfileData(
                      retrievedUserData!.profileId,
                      retrievedUserData!.token,
                    );
                  }
                }
              },
              child: Text(
                candidateProfileModel?.isEmailVerified == 1
                    ? 'Verified'
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
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: _isMobileNumberValid
                      ? Color(0xffd9d9d9)
                      : Color(0xffBA1A1A),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                underline: Container(),
                value: _selectedCountryCode,
                items: countryOptions.map((countryCode) {
                  return DropdownMenuItem<String>(
                    value: countryCode,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        countryCode,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          color: Color(0xff545454),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCountryCode = val;
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                maxLength: validLength,
                controller: mobileController,
                cursorColor: Color(0xff004C99),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                  color: Color(0xff333333),
                ),
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) {
                  setState(() {
                    _isMobileNumberValid = true;
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
                        mobileErrorMsg =
                            'Enter a valid $validLength digits mobile number';
                      });
                      return;
                    }

                    if (candidateProfileModel?.isPhoneVerified != 1) {
                      await Navigator.push(
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

                      if (retrievedUserData != null) {
                        fetchCandidateProfileData(
                          retrievedUserData!.profileId,
                          retrievedUserData!.token,
                        );
                      }
                    }
                  },
                  child: Text(
                    candidateProfileModel?.isPhoneVerified == 1
                        ? 'Verified'
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
              mobileErrorMsg,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
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
            'Total Experience in years',
            style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          controller: experienceController,
          cursorColor: Color(0xff004C99),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            hintText: 'Experience',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color(0xffd9d9d9),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color(0xff004C99),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty || value == '0') {
                experienceController.text = 'Fresher';
                experienceController.selection = TextSelection.fromPosition(
                  TextPosition(offset: experienceController.text.length),
                );
                _isExperienceValid = true;
              } else if (value != 'Fresher') {
                _isExperienceValid = true;
              }
            });
          },
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
