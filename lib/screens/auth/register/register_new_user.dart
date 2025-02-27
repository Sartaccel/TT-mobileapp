import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterNewUser extends StatefulWidget {
  const RegisterNewUser({super.key});

  @override
  State<RegisterNewUser> createState() => _RegisterNewUserState();
}

class _RegisterNewUserState extends State<RegisterNewUser> {
  bool _isFirstNameValid = true;
  String? fNameErrorMsg = 'First name is required';
  TextEditingController fNameController = TextEditingController();

  bool _isLastNameValid = true;
  String? lNameErrorMsg = 'Last name is required';
  TextEditingController lNameController = TextEditingController();

  bool _isEmailValid = true;
  String? emailErrorMsg = 'Email ID is required';
  TextEditingController emailController = TextEditingController();

  bool _isMobileNumberValid = true;
  String? mobileErrorMsg = 'Mobile number is required';
  TextEditingController mobileController = TextEditingController();

  TextEditingController referralController = TextEditingController();

  bool _isPasswordValid = true;
  TextEditingController passwordController = TextEditingController();

  bool _isConfirmPasswordValid = true;
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool referralCodeEnabled = true;

  bool agreementAccepted = false;
  bool _isAgreementError = false;
  bool isHovered = false;
  bool confirmPasswordHide = true, passwordHide = true;

  String passwordErrorMSG = "Password is required";
  String confirm_passwordErrorMSG = "Password is required";

  String? _selectedCountryCode = '+91';
  //final List<String> countryOptions = ['+91', '+1', '+2'];
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

  /*Future<void> _getReferralCode() async {
    try {
      // Fetch installation referrer data
      final InstallationApp app = await InstallReferrer.app;

      // Check if the referrer is available
      if (app.referrer != null) {
        print('Referrer String: ${app.referrer}');

        // Parse the referrer string to extract parameters (if any)
        final Uri uri = Uri.parse('https://dummyurl.com/?${app.referrer}');
        final String? referralCode = uri.queryParameters['referrer'];

        if (referralCode != null) {
          print('Referral Code: $referralCode');

          setState(() {
            referralController.text = referralCode;
            referralCodeEnabled = false;
          });

        } else {
          print('No referral code found.');
          setState(() {
            referralCodeEnabled = true;
          });
        }
      } else {
        print('Referrer data is null.');
      }
    } catch (e) {
      print('Error fetching referral code: $e');
    }
  }*/

  Future<void> _launchTermsURL() async {
    final String? filePath = 'https://main.talentturbo.us/terms-of-service';

    if (filePath != null && await canLaunchUrl(Uri.parse(filePath))) {
      //await launchUrlString(filePath, mode: LaunchMode.externalApplication);
      await launchUrl(Uri.parse(filePath));
      //await launch(filePath, forceSafariVC: false, forceWebView: false);
    } else {
      // Fluttertoast.showToast(
      //     msg: 'Could not launch ${filePath}',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0xff2D2D2D),
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      // throw 'Could not launch ${filePath}';
      IconSnackBar.show(
        context,
        label: 'Could not launch ${filePath}',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    }
  }

  Future<void> registerUser() async {
    if (kDebugMode) print('Registering...');

    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REGISTER);

    final bodyParams = {
      "firstName": fNameController.text,
      "lastName": lNameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "countryCode": _selectedCountryCode,
      "phoneNumber": mobileController.text,
      //"referralCode" : referralController.text,
      "priAccUserType": "candidate"
    };

    if (kDebugMode) print(jsonEncode(bodyParams));

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
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
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyParams));

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];
        //print(response.body);

        if (statusMessage.toLowerCase().contains('email')) {
          setState(() {
            _isEmailValid = false;
            emailErrorMsg = statusMessage;
          });
        } else if (statusMessage.toLowerCase().contains('phone') ||
            statusMessage.toLowerCase().contains('mobile')) {
          _isMobileNumberValid = false;
          mobileErrorMsg = statusMessage;
        } else if (statusMessage.toLowerCase().contains('successfully')) {
          // Fluttertoast.showToast(
          //     msg: statusMessage,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.green,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );

          Navigator.pop(context);
        } else {
          // Fluttertoast.showToast(
          //   msg: statusMessage,
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.green,
          //   textColor: Colors.white,
          //   fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );
        }
      } else {
        var resOBJ = jsonDecode(response.body);

        if (kDebugMode) print(resOBJ);

        String statusMessage = resOBJ['message'];
        if (statusMessage.toLowerCase().contains('email')) {
          setState(() {
            _isEmailValid = false;
            emailErrorMsg = statusMessage;
          });
        } else if (statusMessage.toLowerCase().contains('phone') ||
            statusMessage.toLowerCase().contains('mobile')) {
          _isMobileNumberValid = false;
          mobileErrorMsg = statusMessage;
        }

        print('Error. errorcode: ${response.statusCode} => ${response.body}');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0x04FCFCFC),
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            child: Image.asset('assets/images/Ellipse 1.png'),
          ),
          Positioned(
              top: 40,
              left: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
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
                            style: TextStyle(fontSize: 16),
                          ))))
                ],
              )),
          Positioned(
              top: 80,
              left: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen()));
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              textAlign: TextAlign.center,
                              'Register your profile',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text('First Name',
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Lato',
                                color: _isFirstNameValid
                                    ? Color(0xff333333)
                                    : Color(0xffBA1A1A))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
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
                                            : Color(
                                                0xffBA1A1A), // Default border color
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isFirstNameValid
                                            ? Color(0xff004C99)
                                            : Color(
                                                0xffBA1A1A), // Border color when focused
                                        width: 1),
                                  ),
                                  // Display error message if invalid
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),

                                  errorStyle: TextStyle(
                                      fontSize: 12, color: Color(0xffBA1A1A)),
                                ),
                                keyboardType: TextInputType.emailAddress,
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
                              if (!_isFirstNameValid)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    fNameErrorMsg ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xffBA1A1A),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                            ]),
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
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: _isLastNameValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: lNameController,
                              cursorColor: Color(0xff004C99),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  color: Color(0xff545454)),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'[a-zA-Z\s]')), // Allow only letters and spaces
                              ],
                              decoration: InputDecoration(
                                  hintText: 'Enter your last name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isLastNameValid
                                            ? Color(0xffd9d9d9)
                                            : Color(
                                                0xffBA1A1A), // Default border color
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isLastNameValid
                                            ? Color(0xff004C99)
                                            : Color(
                                                0xffBA1A1A), // Border color when focused
                                        width: 1),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                // Validate the email here and update _isEmailValid
                                setState(() {
                                  _isFirstNameValid = true;
                                });
                              },
                            ),
                            if (!_isLastNameValid)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  lNameErrorMsg ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffBA1A1A),
                                    fontFamily: 'Lato',
                                  ),
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
                          'Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: _isEmailValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              cursorColor: Color(0xff004C99),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  color: Color(0xff545454)),
                              decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isEmailValid
                                            ? Color(0xffd9d9d9)
                                            : Color(
                                                0xffBA1A1A), // Default border color
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isEmailValid
                                            ? Color(0xff004C99)
                                            : Color(
                                                0xffBA1A1A), // Border color when focused
                                        width: 1),
                                  ),
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
                            if (!_isEmailValid)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  emailErrorMsg ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffBA1A1A),
                                    fontFamily: 'Lato',
                                  ),
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
                          'Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: _isPasswordValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: (MediaQuery.of(context).size.width) - 20,
                          child: Column(children: [
                            TextField(
                              controller: passwordController,
                              obscureText: passwordHide,
                              cursorColor: Color(0xff004C99),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  color: Color(0xff545454)),
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passwordHide = !passwordHide;
                                        });
                                      },
                                      //icon: Icon( passwordHide?Icons.visibility :Icons.visibility_off)),
                                      icon: SvgPicture.asset(passwordHide
                                          ? 'assets/images/ic_hide_password.svg'
                                          : 'assets/images/ic_show_password.svg')),
                                  hintText: 'Enter your password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isPasswordValid
                                            ? Color(0xffd9d9d9)
                                            : Color(
                                                0xffBA1A1A), // Default border color
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isPasswordValid
                                            ? Color(0xff004C99)
                                            : Color(
                                                0xffBA1A1A), // Border color when focused
                                        width: 1),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\p{L}\p{N}\p{P}\p{S}]',
                                      unicode: true),
                                ),
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\s'),
                                ),
                                FilteringTextInputFormatter.deny(
                                  RegExp(
                                      r'[\u{1F300}-\u{1F6FF}|\u{1F900}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
                                      unicode: true),
                                ),
                              ],
                              onChanged: (value) {
                                // Validate the email here and update _isEmailValid
                                setState(() {
                                  _isPasswordValid = true;
                                  _isConfirmPasswordValid = true;
                                });
                              },
                            ),
                            if (!_isPasswordValid)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  passwordErrorMSG ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffBA1A1A),
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                          ])),

                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'Re-enter Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: _isConfirmPasswordValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: Column(
                          children: [
                            TextField(
                              controller: confirmPasswordController,
                              cursorColor: Color(0xff004C99),
                              obscureText: confirmPasswordHide,
                              style:
                                  TextStyle(fontSize: 14, fontFamily: 'Lato'),
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          confirmPasswordHide =
                                              !confirmPasswordHide;
                                        });
                                      },
                                      //icon: Icon( confirmPasswordHide?Icons.visibility :Icons.visibility_off)),
                                      icon: SvgPicture.asset(confirmPasswordHide
                                          ? 'assets/images/ic_hide_password.svg'
                                          : 'assets/images/ic_show_password.svg')),
                                  hintText: 'Re-enter your password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isConfirmPasswordValid
                                            ? Color(0xffd9d9d9)
                                            : Color(
                                                0xffBA1A1A), // Default border color
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: _isConfirmPasswordValid
                                            ? Color(0xff004C99)
                                            : Color(
                                                0xffBA1A1A), // Border color when focused
                                        width: 1),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\p{L}\p{N}\p{P}\p{S}]',
                                      unicode: true),
                                ),
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\s'),
                                ),
                                FilteringTextInputFormatter.deny(
                                  RegExp(
                                      r'[\u{1F300}-\u{1F6FF}|\u{1F900}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
                                      unicode: true),
                                ),
                              ],
                              onChanged: (value) {
                                // Validate the email here and update _isEmailValid
                                setState(() {
                                  _isConfirmPasswordValid = true;
                                  _isPasswordValid = true;
                                });
                              },
                            ),
                            if (!_isConfirmPasswordValid)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  confirm_passwordErrorMSG ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffBA1A1A),
                                    fontFamily: 'Lato',
                                  ),
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
                          'Mobile Number',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: _isMobileNumberValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A)),
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
                                              : Color(0xffBA1A1A)),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(9),
                                  child: DropdownButton(
                                      value: _selectedCountryCode,
                                      underline: Container(),
                                      icon: SvgPicture.asset(
                                        'assets/icon/ArrowDown.svg',
                                        height: 10,
                                        width: 10,
                                      ),
                                      items: countryOptions.map((countryCode) {
                                        return DropdownMenuItem(
                                            value: countryCode,
                                            child: Text(countryCode,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Lato',
                                                    color: const Color(
                                                        0xff545454))));
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
                                        120,
                                    child: TextField(
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter
                                            .digitsOnly, // This allows only digits
                                      ],
                                      maxLength: getValidLengthForCountry(
                                          _selectedCountryCode!),
                                      controller: mobileController,
                                      cursorColor: Color(0xff004C99),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Lato',
                                          color: _isMobileNumberValid
                                              ? Color(0xff545454)
                                              : Color(0xffBA1A1A)),
                                      decoration: InputDecoration(
                                          counterText: '',
                                          hintText: 'Enter mobile number',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: _isMobileNumberValid
                                                    ? Color(0xffd9d9d9)
                                                    : Color(
                                                        0xffBA1A1A), // Default border color
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: _isMobileNumberValid
                                                    ? Color(0xff004C99)
                                                    : Color(
                                                        0xffBA1A1A), // Border color when focused
                                                width: 1),
                                          ),
                                          // errorText: _isMobileNumberValid
                                          //     ? null
                                          //     : mobileErrorMsg, // Display error message if invalid
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10)),
                                      keyboardType: TextInputType.phone,
                                      onChanged: (value) {
                                        // Validate the email here and update _isEmailValid
                                        setState(() {
                                          _isMobileNumberValid = true;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!_isMobileNumberValid)
                              Padding(
                                padding: EdgeInsets.only(top: 4, left: 0),
                                child: Text(
                                  mobileErrorMsg ?? '',
                                  style: TextStyle(
                                    color: Color(0xFFBA1A1A),
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /* SizedBox(height: 20,),
                  Text('Having Referral Code? (Optional)', style: TextStyle(fontSize: 13, fontFamily: 'Lato'),),
                  SizedBox(height: 10,),
                  Container(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextField(
                      readOnly: !referralCodeEnabled,
                      controller: referralController,
                      style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                      decoration: InputDecoration(

                          hintText: 'Referral Code',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey , // Default border color
                                width: 1
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue, // Border color when focused
                                width: 1
                            ),
                          ),

                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                      ),
                    ),
                  ),*/

                      //CheckBox
                      SizedBox(height: 40),
                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  agreementAccepted =
                                      !agreementAccepted; // Toggle the checkbox state
                                });
                              },
                              child: Container(
                                width: 24, // Checkbox size
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: agreementAccepted
                                        ? AppColors
                                            .primaryColor // Default border color
                                        : _isAgreementError
                                            ? Color(
                                                0xFFBA1A1A) // Error border when button clicked
                                            : Color(0xffd9d9d9),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  color: agreementAccepted
                                      ? AppColors.primaryColor
                                      : const Color(
                                          0x00FFFFFF), // Fill when checked
                                ),
                                child: agreementAccepted
                                    ? Icon(Icons.check,
                                        size: 18,
                                        color: Colors.white) // Show checkmark
                                    : null, // Keep empty when unchecked
                              ),
                            ),
                            SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                _launchTermsURL();
                              },
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Lato',
                                  color:
                                      (!agreementAccepted && _isAgreementError)
                                          ? Color(0xFFBA1A1A)
                                          : Color(0xff004C99),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      //Button
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          int validLength =
                              getValidLengthForCountry(_selectedCountryCode!);

                          if (kDebugMode) {
                            print(
                                'Referral Code: ${referralController.text ?? ''}');
                          }
                          if (!agreementAccepted) {
                            setState(() {
                              _isAgreementError =
                                  true; // Show error when unchecked
                            });
                            // Fluttertoast.showToast(
                            //     msg:
                            //         "You must agree to our Terms of service & our privacy policy",
                            //     toastLength: Toast.LENGTH_SHORT,
                            //     gravity: ToastGravity.BOTTOM,
                            //     timeInSecForIosWeb: 1,
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.white,
                            //     fontSize: 16.0);
                            // IconSnackBar.show(
                            //   context,
                            //   label: 'Accept our Terms and Privacy Policy',
                            //   snackBarType: SnackBarType.alert,
                            //   backgroundColor: Color(0xFFBA1A1A),
                            //   iconColor: Colors.white,
                            // );
                          } else if (fNameController.text.trim().isEmpty ||
                              fNameController.text.trim().length < 3 ||
                              lNameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              !validateEmail(emailController.text) ||
                              passwordController.text.trim().isEmpty ||
                              confirmPasswordController.text.trim().isEmpty ||
                              mobileController.text.trim().isEmpty ||
                              mobileController.text.length < validLength ||
                              mobileController.text.length > validLength) {
                            if (fNameController.text.trim().isEmpty) {
                              setState(() {
                                _isFirstNameValid = false;
                                fNameErrorMsg = 'First name cannot be empty';
                              });
                            } else if (fNameController.text.trim().length < 3) {
                              setState(() {
                                fNameErrorMsg =
                                    'First name must at least be 3 characters';
                                _isFirstNameValid = false;
                              });
                            }

                            if (lNameController.text.trim().isEmpty) {
                              setState(() {
                                _isLastNameValid = false;
                              });
                            }

                            if (emailController.text.trim().isEmpty) {
                              setState(() {
                                _isEmailValid = false;
                                emailErrorMsg = 'Email cannot be empty';
                              });
                            } else if (!validateEmail(emailController.text)) {
                              setState(() {
                                _isEmailValid = false;
                                emailErrorMsg = 'Enter a valid email address';
                              });
                            }

                            if (passwordController.text.trim().isEmpty) {
                              setState(() {
                                _isPasswordValid = false;
                                passwordErrorMSG = 'Password cannot be empty';
                              });
                            }

                            if (confirmPasswordController.text.trim().isEmpty) {
                              setState(() {
                                _isConfirmPasswordValid = false;
                                confirm_passwordErrorMSG =
                                    'Please re-enter your password';
                              });
                            }

                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              setState(() {
                                _isPasswordValid = false;
                                _isConfirmPasswordValid = false;

                                confirm_passwordErrorMSG =
                                    'Passwords do not match';
                                passwordErrorMSG = 'Passwords do not match';
                              });
                            }

                            if (confirmPasswordController.text.trim().isEmpty) {
                              setState(() {
                                _isConfirmPasswordValid = false;
                                confirm_passwordErrorMSG =
                                    'Please re-enter your password';
                              });
                            }

                            if (mobileController.text.trim().isEmpty) {
                              setState(() {
                                _isMobileNumberValid = false;
                                mobileErrorMsg =
                                    'Mobile number cannot be empty';
                              });
                            } else if (mobileController.text.length <
                                    validLength ||
                                mobileController.text.length > validLength) {
                              setState(() {
                                _isMobileNumberValid = false;
                                mobileErrorMsg =
                                    'Please enter a valid $validLength digit mobile number';
                              });
                            } else {
                              setState(() {
                                _isMobileNumberValid = true;
                                mobileErrorMsg = '';
                              });
                            }
                          } else if (passwordController.text.length < 8) {
                            setState(() {
                              _isPasswordValid = false;
                              passwordErrorMSG =
                                  'Password must be at least 8 characters';
                            });
                          } else if (passwordController.text !=
                              confirmPasswordController.text) {
                            setState(() {
                              _isPasswordValid = false;
                              passwordErrorMSG = 'Passwords don\'t match';
                              _isConfirmPasswordValid = false;
                              confirm_passwordErrorMSG =
                                  'Passwords don\'t match';
                            });
                          } else {
                            registerUser();
                          }
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width) - 20,
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
                                          angle: value *
                                              2 *
                                              3.1416, // Full rotation effect
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                            value: 0.20, // 1/5 of the circle
                                            backgroundColor:
                                                const Color.fromARGB(142, 234,
                                                    232, 232), // Grey stroke
                                            valueColor: AlwaysStoppedAnimation<
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
                                    'Create Profile',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    fNameController.dispose();
    lNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
