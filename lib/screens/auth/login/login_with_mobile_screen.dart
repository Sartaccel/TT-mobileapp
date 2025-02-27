import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/screens/auth/login_otp/login_otp_screen.dart';
import 'package:http/http.dart' as http;

class MobileNumberLogin extends StatefulWidget {
  const MobileNumberLogin({super.key});

  @override
  State<MobileNumberLogin> createState() => _MobileNumberLoginState();
}

class _MobileNumberLoginState extends State<MobileNumberLogin> {
  String? _selectedCountryCode = '+91';
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
  bool _isMobileNumberValid = true;
  String mobileErrorMsg =
      'Please enter your mobile number to receive an OTP for verification';
  TextEditingController mobileController = TextEditingController();

  bool isLoading = false;

  Future<void> otpSignIn() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN_BY_MOBILE);

    final bodyParams = {
      "countryCode": _selectedCountryCode,
      "phoneNumber": mobileController.text
    };

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
        return;
      }

      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if (resOBJ['result'] == true &&
            statusMessage.toLowerCase().contains('sent')) {
          // Fluttertoast.showToast(
          //     msg: statusMessage,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Color(0xff2D2D2D),
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff004C99),
            iconColor: Colors.white,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginOTPScreen(
                        countryCode: _selectedCountryCode,
                        mobileNumber: mobileController.text,
                      )));
        } else {
          // Fluttertoast.showToast(
          //   msg: 'Invalid user !',
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.red,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
          IconSnackBar.show(
            context,
            label: 'User not found!',
            snackBarType: SnackBarType.alert,
            backgroundColor: Color(0xFFBA1A1A),
            iconColor: Colors.white,
          );
        }
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0x04FCFCFC),
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            child: Image.asset('assets/images/Ellipse 1.png'),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset('assets/images/ellipse_bottom.png'),
          ),
          Positioned(
            top: 31,
            left: 0,
            right: 0,
            child: Center(
                child: Image.asset('assets/images/tt_logo_full_1.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.25,
                    fit: BoxFit.contain)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: InkWell(
                          onTap: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> LoginOTPScreen()));
                          },
                          child: Text(
                            'Login with OTP',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ))),
                  SizedBox(
                    height: 50,
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
                            ? const Color(0xFF333333)
                            : const Color(0xFFBA1A1A),
                      ),
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
                            // Country Code Dropdown
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: _isMobileNumberValid
                                      ? Color(0xffD9D9D9)
                                      : const Color(0xFFBA1A1A),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(9),
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                underline: SizedBox(),
                                icon: SvgPicture.asset(
                                  'assets/icon/ArrowDown.svg',
                                  height: 10,
                                  width: 10,
                                ),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    color: const Color(0xFF333333)),
                                items: countryOptions.map((countryCode) {
                                  return DropdownMenuItem(
                                    value: countryCode,
                                    child: Text(countryCode,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Lato',
                                            color: const Color(0xFF333333))),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCountryCode = val!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.01),
                            // Mobile Number TextField
                            Expanded(
                              child: Container(
                                height: 48,
                                width:
                                    (MediaQuery.of(context).size.width) - 120,
                                child: TextField(
                                  maxLength: 10,
                                  controller: mobileController,
                                  cursorColor: Color(0xff004C99),
                                  style: TextStyle(
                                      fontSize: 14, fontFamily: 'Lato'),
                                  decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Enter mobile number',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: _isMobileNumberValid
                                              ? Color(0xffD9D9D9)
                                              : const Color(0xFFBA1A1A),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: _isMobileNumberValid
                                              ? Color(0xff004C99)
                                              : const Color(0xFFBA1A1A),
                                          width: 1,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10)),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _isMobileNumberValid = true;
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),

                        // Single Error Message for Both Fields
                        if (!_isMobileNumberValid)
                          Padding(
                            padding: EdgeInsets.only(top: 4, left: 0),
                            child: Text(
                              mobileErrorMsg ?? '',
                              style: TextStyle(
                                  color: const Color(0xFFBA1A1A), fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                  InkWell(
                    onTap: () {
                      if (mobileController.text.isEmpty ||
                          mobileController.text.length < 10) {
                        setState(() {
                          _isMobileNumberValid = false;
                        });
                      } else {
                        setState(() {
                          isLoading =
                              true; // Start loader before calling otpSignIn
                        });

                        otpSignIn().then((_) {
                          setState(() {
                            isLoading = false; // Stop loader after API call
                          });
                        }).catchError((error) {
                          setState(() {
                            isLoading = false; // Ensure loading stops on error
                          });
                        });
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
                                      angle: value *
                                          2 *
                                          3.1416, // Full rotation effect
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        value: 0.20, // 1/5 of the circle
                                        backgroundColor: const Color.fromARGB(
                                            142, 234, 232, 232), // Grey stroke
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors
                                                .white), // White rotating stroke
                                      ),
                                    );
                                  },
                                  onEnd: () =>
                                      {}, // Ensures smooth infinite animation
                                ),
                              )
                            : Text(
                                'Get OTP',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        ],
      ),
    );
  }
}
