import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController currentPositionController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

  String? startDateErrorMsg = 'Date of Birth cannot be empty';
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
  //final List<String> countryOptions = ['+91', '+92', '+93'];
  final List<String> countryOptions = [
    '+1', // USA, Canada, etc.
    '+7', // Russia, Kazakhstan
    '+20', // Egypt
    '+27', // South Africa
    '+30', // Greece
    '+31', // Netherlands
    '+32', // Belgium
    '+33', // France
    '+34', // Spain
    '+36', // Hungary
    '+39', // Italy
    '+40', // Romania
    '+41', // Switzerland
    '+43', // Austria
    '+44', // UK
    '+45', // Denmark
    '+46', // Sweden
    '+47', // Norway
    '+48', // Poland
    '+49', // Germany
    '+51', // Peru
    '+52', // Mexico
    '+53', // Cuba
    '+54', // Argentina
    '+55', // Brazil
    '+56', // Chile
    '+57', // Colombia
    '+58', // Venezuela
    '+60', // Malaysia
    '+61', // Australia
    '+62', // Indonesia
    '+63', // Philippines
    '+64', // New Zealand
    '+65', // Singapore
    '+66', // Thailand
    '+81', // Japan
    '+82', // South Korea
    '+84', // Vietnam
    '+86', // China
    '+90', // Turkey
    '+91', // India
    '+92', // Pakistan
    '+93', // Afghanistan
    '+94', // Sri Lanka
    '+95', // Myanmar
    '+98', // Iran
    '+211', // South Sudan
    '+212', // Morocco
    '+213', // Algeria
    '+216', // Tunisia
    '+218', // Libya
    '+220', // Gambia
    '+221', // Senegal
    '+222', // Mauritania
    '+223', // Mali
    '+224', // Guinea
    '+225', // Ivory Coast
    '+226', // Burkina Faso
    '+227', // Niger
    '+228', // Togo
    '+229', // Benin
    '+230', // Mauritius
    '+231', // Liberia
    '+232', // Sierra Leone
    '+233', // Ghana
    '+234', // Nigeria
    '+235', // Chad
    '+236', // Central African Republic
    '+237', // Cameroon
    '+238', // Cape Verde
    '+239', // São Tomé and Príncipe
    '+240', // Equatorial Guinea
    '+241', // Gabon
    '+242', // Republic of the Congo
    '+243', // Democratic Republic of the Congo
    '+244', // Angola
    '+245', // Guinea-Bissau
    '+248', // Seychelles
    '+249', // Sudan
    '+250', // Rwanda
    '+251', // Ethiopia
    '+252', // Somalia
    '+253', // Djibouti
    '+254', // Kenya
    '+255', // Tanzania
    '+256', // Uganda
    '+257', // Burundi
    '+258', // Mozambique
    '+260', // Zambia
    '+261', // Madagascar
    '+262', // Réunion/Mayotte
    '+263', // Zimbabwe
    '+264', // Namibia
    '+265', // Malawi
    '+266', // Lesotho
    '+267', // Botswana
    '+268', // Eswatini (Swaziland)
    '+269', // Comoros
    '+290', // Saint Helena
    '+291', // Eritrea
    '+297', // Aruba
    '+298', // Faroe Islands
    '+299', // Greenland
    '+350', // Gibraltar
    '+351', // Portugal
    '+352', // Luxembourg
    '+353', // Ireland
    '+354', // Iceland
    '+355', // Albania
    '+356', // Malta
    '+357', // Cyprus
    '+358', // Finland
    '+359', // Bulgaria
    '+370', // Lithuania
    '+371', // Latvia
    '+372', // Estonia
    '+373', // Moldova
    '+374', // Armenia
    '+375', // Belarus
    '+376', // Andorra
    '+377', // Monaco
    '+378', // San Marino
    '+379', // Vatican City
    '+380', // Ukraine
    '+381', // Serbia
    '+382', // Montenegro
    '+383', // Kosovo
    '+385', // Croatia
    '+386', // Slovenia
    '+387', // Bosnia and Herzegovina
    '+389', // North Macedonia
    '+420', // Czech Republic
    '+421', // Slovakia
    '+423', // Liechtenstein
    '+500', // Falkland Islands
    '+501', // Belize
    '+502', // Guatemala
    '+503', // El Salvador
    '+504', // Honduras
    '+505', // Nicaragua
    '+506', // Costa Rica
    '+507', // Panama
    '+508', // Saint Pierre and Miquelon
    '+509', // Haiti
    '+590', // Guadeloupe/Martinique
    '+591', // Bolivia
    '+592', // Guyana
    '+593', // Ecuador
    '+594', // French Guiana
    '+595', // Paraguay
    '+596', // Martinique
    '+597', // Suriname
    '+598', // Uruguay
    '+599', // Curaçao/Bonaire
    '+670', // Timor-Leste
    '+672', // Norfolk Island
    '+673', // Brunei
    '+674', // Nauru
    '+675', // Papua New Guinea
    '+676', // Tonga
    '+677', // Solomon Islands
    '+678', // Vanuatu
    '+679', // Fiji
    '+680', // Palau
    '+681', // Wallis and Futuna
    '+682', // Cook Islands
    '+683', // Niue
    '+685', // Samoa
    '+686', // Kiribati
    '+687', // New Caledonia
    '+688', // Tuvalu
    '+689', // French Polynesia
    '+690', // Tokelau
    '+691', // Micronesia
    '+692', // Marshall Islands
    '+850', // North Korea
    '+852', // Hong Kong
    '+853', // Macau
    '+855', // Cambodia
    '+856', // Laos
    '+880', // Bangladesh
    '+886', // Taiwan
    '+960', // Maldives
    '+961', // Lebanon
    '+962', // Jordan
    '+963', // Syria
    '+964', // Iraq
    '+965', // Kuwait
    '+966', // Saudi Arabia
    '+967', // Yemen
    '+968', // Oman
    '+970', // Palestine
    '+971', // UAE
    '+972', // Israel
    '+973', // Bahrain
    '+974', // Qatar
    '+975', // Bhutan
    '+976', // Mongolia
    '+977', // Nepal
    '+992', // Tajikistan
    '+993', // Turkmenistan
    '+994', // Azerbaijan
    '+995', // Georgia
    '+996', // Kyrgyzstan
    '+998', // Uzbekistan
  ];

  String mobileErrorMsg = 'Enter a valid mobile number';

  void extractCountryCodeAndNumber(String fullMobile) {
    String countryCode = '';
    String mobileNumber = '';

    // Iterate through the country codes and find the matching prefix
    for (String code in countryOptions) {
      if (fullMobile.startsWith(code)) {
        countryCode = code;
        mobileNumber = fullMobile.substring(code.length);
        break; // Stop once a match is found
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
    // Parse the input datetime string
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Extract the date in "YYYY-MM-DD" format
    String formattedDate =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

    return formattedDate;
  }

  Future<void> fetchProfileFromPref() async {
    //ReferralData? _referralData = await getReferralProfileData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    UserData? _retrievedUserData = await getUserData();

    extractCountryCodeAndNumber(_candidateProfileModel!.mobile!);
    setState(() {
      //referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;

      fNameController.text = '${_candidateProfileModel!.firstName}';
      lNameController.text = '${_candidateProfileModel!.lastName}';
      emailController.text = '${_candidateProfileModel!.email}';
      locationController.text = '${_candidateProfileModel!.location ?? ''}';

      String dob = '${_candidateProfileModel!.dateOfBirth ?? ''}';
      if (dob.isEmpty) {
        _startDateController.text = '';
      } else {
        _startDateController.text = extractDate(dob);
      }

      currentPositionController.text = '${_candidateProfileModel!.position}';
      experienceController.text =
          '${_candidateProfileModel!.experience ?? '0'}';

      //mobileController.text = '${_candidateProfileModel!.mobile!.substring(3)}';
      //_selectedCountryCode = '${_candidateProfileModel!.mobile!.substring(0, 3)}';
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
          // Fluttertoast.showToast(
          //     msg: 'Personal details updated successfully',
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Color(0xff2D2D2D),
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: 'Personal details updated !',
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff2D2D2D),
            iconColor: Colors.white,
          );

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

          // ignore: use_build_context_synchronously

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

  Future<void> updateProfile() async {
    final url = Uri.parse(
        AppConstants.BASE_URL + AppConstants.UPDATE_CANDIDATE_PROFILE);

    final bodyParams = {
      "id": retrievedUserData!.profileId,
      "firstName": fNameController.text,
      "lastName": lNameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "countryCode": _selectedCountryCode,
      "experience": experienceController.text,
      "location": locationController.text,
      "gender": "M",
      "position": currentPositionController.text,
      "dateOfBirth": _startDateController.text
    };

    try {
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

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
                SizedBox(
                  width: 40,
                )
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
            color: Color(0xffFCFCFC),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text('First Name',
                      style: TextStyle(fontSize: 13, fontFamily: 'Lato')),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    controller: fNameController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff545454)),
                    decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isFirstNameValid
                                  ? Color(0xffd9d9d9)
                                  : Colors.red, // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isFirstNameValid
                                  ? Color(0xff004C99)
                                  : Colors.red, // Border color when focused
                              width: 1),
                        ),
                        errorText: _isFirstNameValid
                            ? null
                            : 'First name cannot be empty', // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[a-zA-Z\s]')), // Allow only letters and spaces
                    ],
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isFirstNameValid = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Last Name',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[a-zA-Z\s]')), // Allow only letters and spaces
                    ],
                    controller: lNameController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff545454)),
                    decoration: InputDecoration(
                        hintText: 'Enter your last name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isLastNameValid
                                  ? Color(0xffd9d9d9)
                                  : Colors.red, // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isLastNameValid
                                  ? Color(0xff004C99)
                                  : Colors.red, // Border color when focused
                              width: 1),
                        ),
                        errorText: _isLastNameValid
                            ? null
                            : 'Last name cannot be empty', // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isLastNameValid = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Email',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width) - 100,
                      child: TextField(
                        controller: emailController,
                        cursorColor: Color(0xff004C99),
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Lato',
                            color: Color(0xff545454)),
                        decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: _isEmailValid
                                      ? Color(0xffd9d9d9)
                                      : Colors.red, // Default border color
                                  width: 1),
                            ),
                            suffixIcon: SvgPicture.asset(
                                candidateProfileModel!.isEmailVerified == 1
                                    ? 'assets/images/verified_ic.svg'
                                    : 'assets/images/pending_ic.svg'),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: _isEmailValid
                                      ? Color(0xff004C99)
                                      : Colors.red, // Border color when focused
                                  width: 1),
                            ),
                            errorText: _isEmailValid
                                ? null
                                : 'Email cannot be empty', // Display error message if invalid
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10)),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // Validate the email here and update _isEmailValid
                          setState(() {
                            _isEmailValid = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                        width: 60,
                        child: InkWell(
                            onTap: () async {
                              if (candidateProfileModel!.isEmailVerified != 1) {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SendVerificationCode(
                                                type: "email",
                                                mobile: candidateProfileModel!
                                                    .mobile,
                                                email: candidateProfileModel!
                                                    .email)));
                                fetchCandidateProfileData(
                                    retrievedUserData!.profileId,
                                    retrievedUserData!.token);
                              }
                            },
                            child: Center(
                                child: Text(
                              candidateProfileModel!.isEmailVerified == 1
                                  ? 'Verified'
                                  : 'Verify',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff004C99)),
                            ))))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Mobile Number',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: _isMobileNumberValid
                                              ? Color(0xffd9d9d9)
                                              : Colors.red),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(9),
                                  child: DropdownButton(
                                      underline: Container(),
                                      value: _selectedCountryCode,
                                      items: countryOptions.map((countryCode) {
                                        return DropdownMenuItem(
                                            value: countryCode,
                                            child: Text(countryCode,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Lato',
                                                    color: Color(0xff545454))));
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCountryCode = val;
                                        });
                                      }),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Expanded(
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width) -
                                        200,
                                    child: TextField(
                                      maxLength: getValidLengthForCountry(
                                          _selectedCountryCode!),
                                      controller: mobileController,
                                      cursorColor: Color(0xff004C99),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Lato',
                                          color: Color(0xff545454)),
                                      decoration: InputDecoration(
                                          counterText: '',
                                          hintText: 'Enter mobile number',
                                          suffixIcon: SvgPicture.asset(
                                              candidateProfileModel!
                                                          .isPhoneVerified ==
                                                      1
                                                  ? 'assets/images/verified_ic.svg'
                                                  : 'assets/images/pending_ic.svg'),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: _isMobileNumberValid
                                                    ? Color(0xffd9d9d9)
                                                    : Colors
                                                        .red, // Default border color
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: _isMobileNumberValid
                                                    ? Color(0xff004C99)
                                                    : Colors
                                                        .red, // Border color when focused
                                                width: 1),
                                          ),
                                          // errorText: _isMobileNumberValid
                                          //     ? null
                                          //     : mobileErrorMsg, // Display error message if invalid
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10)),
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                      ],
                                      onChanged: (value) {
                                        // Validate the email here and update _isEmailValid
                                        setState(() {
                                          _isMobileNumberValid = true;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                              width: 60,
                              child: Center(
                                  child: InkWell(
                                      onTap: () async {
                                        if (candidateProfileModel!
                                                .isPhoneVerified !=
                                            1) {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      SendVerificationCode(
                                                          type: "phone",
                                                          mobile:
                                                              candidateProfileModel!
                                                                  .mobile,
                                                          email:
                                                              candidateProfileModel!
                                                                  .email)));
                                          fetchCandidateProfileData(
                                              retrievedUserData!.profileId,
                                              retrievedUserData!.token);
                                        }
                                      },
                                      child: Text(
                                        candidateProfileModel!
                                                    .isPhoneVerified ==
                                                1
                                            ? 'Verified'
                                            : 'Verify',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff004C99)),
                                      ))))
                        ],
                      ),
                      if (!_isMobileNumberValid)
                        Padding(
                          padding: EdgeInsets.only(top: 4, left: 10),
                          child: Text(
                            mobileErrorMsg ?? '',
                            style: TextStyle(
                                color: Color(0xFFBA1A1A), fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Location',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    controller: locationController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff545454)),
                    decoration: InputDecoration(
                        hintText: 'Enter your Location',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isLocationValid
                                  ? Color(0xffd9d9d9)
                                  : Colors.red, // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isLocationValid
                                  ? Color(0xff004C99)
                                  : Colors.red, // Border color when focused
                              width: 1),
                        ),
                        errorText: _isLocationValid
                            ? null
                            : 'Location cannot be empty', // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\s]')),
                    ],
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isLocationValid = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Date of Birth',
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  alignment: Alignment.center,
                  child: SizedBox(
                    child: TextField(
                      controller: _startDateController,
                      cursorColor: Color(0xff004C99),
                      style: TextStyle(fontSize: 14, color: Color(0xff545454)),
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
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: isStartDateValid
                                    ? Color(0xffd9d9d9)
                                    : Colors.red, // Default border color
                                width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: isStartDateValid
                                    ? Color(0xff004C99)
                                    : Colors.red, // Border color when focused
                                width: 1),
                          ),
                          errorText: isStartDateValid
                              ? null
                              : startDateErrorMsg, // Display error message if invalid
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().subtract(Duration(days: 1)),
                            firstDate: DateTime(1970),
                            //lastDate: DateTime(2101),
                            lastDate:
                                DateTime.now().subtract(Duration(days: 1)),
                            initialDatePickerMode: DatePickerMode.year);
                        if (pickedDate != null) {
                          setState(() {
                            isStartDateValid = true;
                            _startDateSelected = true;
                            //_startDateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            // _startDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                            _startDateController.text =
                                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                          });
                        }
                      },
                    ),
                  ),
                ),
                /*SizedBox(height: 20,),
                Text('Date of Birth', style: TextStyle(fontSize: 13, fontFamily: 'Lato'),),
                SizedBox(height: 10,),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    controller: dobController,
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        hintText: 'Enter your last name',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _isDobValid ? Colors.grey : Colors.red, // Default border color
                              width: 1
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _isDobValid ? Colors.blue : Colors.red, // Border color when focused
                              width: 1
                          ),
                        ),

                        errorText: _isDobValid ? null : 'DOB cannot be empty', // Display error message if invalid
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isDobValid = true;
                      });
                    },
                  ),
                ),*/

                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Current Position',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    controller: currentPositionController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff545454)),
                    decoration: InputDecoration(
                        hintText: 'Enter your position',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isPositionValid
                                  ? Color(0xffd9d9d9)
                                  : Colors.red, // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isPositionValid
                                  ? Color(0xff004C99)
                                  : Colors.red, // Border color when focused
                              width: 1),
                        ),
                        errorText: _isPositionValid
                            ? null
                            : 'Position cannot be empty', // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\s]')),
                    ],
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isPositionValid = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.015,
                  ),
                  child: Text(
                    'Total Experience in years',
                    style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    controller: experienceController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff545454)),
                    decoration: InputDecoration(
                        hintText: 'Experience',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isExperienceValid
                                  ? Color(0xffd9d9d9)
                                  : Colors.red, // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isExperienceValid
                                  ? Color(0xff004C99)
                                  : Colors.red, // Border color when focused
                              width: 1),
                        ),
                        errorText: _isExperienceValid
                            ? null
                            : 'Experience cannot be empty', // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isExperienceValid = true;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    int validLength =
                        getValidLengthForCountry(_selectedCountryCode!);
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
                      if (fNameController.text.isEmpty) {
                        setState(() {
                          _isFirstNameValid = false;
                        });
                      }

                      if (_startDateController.text.isEmpty) {
                        setState(() {
                          isStartDateValid = false;
                        });
                      }

                      if (lNameController.text.isEmpty) {
                        setState(() {
                          _isLastNameValid = false;
                        });
                      }

                      if (emailController.text.isEmpty) {
                        setState(() {
                          _isEmailValid = false;
                        });
                      }

                      if (locationController.text.isEmpty) {
                        setState(() {
                          _isLocationValid = false;
                        });
                      }

                      if (mobileController.text.isEmpty ||
                          mobileController.text.length < validLength ||
                          mobileController.text.length > validLength) {
                        setState(() {
                          _isMobileNumberValid = false;
                          mobileErrorMsg =
                              'Enter a valid $validLength digits mobile number';
                        });
                      }

                      if (currentPositionController.text.isEmpty) {
                        setState(() {
                          _isPositionValid = false;
                        });
                      }

                      if (experienceController.text.isEmpty) {
                        setState(() {
                          _isExperienceValid = false;
                        });
                      }
                    } else {
                      if (kDebugMode) {
                        print('Processing........');
                      }

                      // Call your updateProfile function
                      updateProfile().then((_) {
                        // On successful profile update, navigate back to the previous screen
                        Navigator.pop(context);
                      }).catchError((error) {
                        // Handle any errors that occur during the update
                        print('Error updating profile: $error');
                      });
                    }
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width) - 20,
                    height: 44,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                                    angle: value *
                                        2 *
                                        3.1416, // Full rotation effect
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      value: 0.20, // 1/5 of the circle
                                      backgroundColor: const Color.fromARGB(
                                          142, 234, 232, 232), // Grey stroke
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
              ],
            ),
          )))
        ],
      ),
    );
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
  }
}
