import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:http/http.dart' as http;

import '../../../Utils.dart';

class LoginOTPScreen extends StatefulWidget {
  final countryCode, mobileNumber;

  const LoginOTPScreen(
      {super.key, required this.countryCode, required this.mobileNumber});

  @override
  State<LoginOTPScreen> createState() => _LoginOTPScreenState();
}

class _LoginOTPScreenState extends State<LoginOTPScreen> {
  bool isLoading = false;
  bool _isOTPValid = false;

  bool clearOTP = false;
  bool inValidOTP = false;
  String enteredOTP = '';
  String otpErrorMsg = '';

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

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
        label: "No internet connection",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      return; // Exit the function if no internet
    }

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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeContainer()),
            (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );
        }
      } else {}

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> verifyOTP(String otp) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VERIFY_LOGIN_OTP);

    final bodyParams = {
      "token": otp,
      "countryCode": widget.countryCode,
      "phoneNumber": widget.mobileNumber
    };

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
        label: "No internet connection",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      return; // Exit the function if no internet
    }

    try {
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

      var resOBJ = jsonDecode(response.body);

      String statusMessage = resOBJ['message'] ?? '';

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (!resOBJ['result']) {
          if (statusMessage.toLowerCase().contains('exists')) {
          } else if (statusMessage.toLowerCase().contains('passwo')) {
          } else {
            // Fluttertoast.showToast(
            //     msg: statusMessage,
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.BOTTOM,
            //     timeInSecForIosWeb: 1,
            //     backgroundColor: Colors.red,
            //     textColor: Colors.white,
            //     fontSize: 16.0);
            IconSnackBar.show(
              context,
              label: statusMessage,
              snackBarType: SnackBarType.alert,
              backgroundColor: Color(0xffBA1A1A),
              iconColor: Colors.white,
            );
          }
        } else {
          print(resOBJ.toString());

          final Map<String, dynamic> data = resOBJ['data'];
          // Map the API response to UserData model
          UserData userData = UserData.fromJson(data);

          await saveUserData(userData);

          UserData? retrievedUserData = await getUserData();

          if (kDebugMode) {
            print('Saved Successfully');
            print('User Name: ${retrievedUserData!.name}');
          }

          //fetchProfileData(retrievedUserData!.profileId, retrievedUserData!.token);
          fetchCandidateProfileData(
              retrievedUserData!.profileId, retrievedUserData!.token);

          // In Screen 3
        }
      } else {
        setState(() {
          inValidOTP = true;
          otpErrorMsg = 'Incorrect OTP';
        });
        // Fluttertoast.showToast(
        //   msg: 'Invalid OTP',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: 'Invalid OTP',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );
        setState(() {
          clearOTP = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      setState(() {
        //clearOTP = false;
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
              top: 40,
              left: 0,
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Back',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ))),
          Positioned(
            top: 120,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/tt_logo_resized.png',
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Image.asset('assets/images/otp_img.png'),
                    Center(
                        child: InkWell(
                            onTap: () {
                              //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> HomeContainer()));
                            },
                            child: Text(
                              'Login with OTP',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ))),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'We have send an OTP on this number',
                      style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.countryCode}${widget.mobileNumber}',
                          style:
                              TextStyle(color: Color(0xff2979FF), fontSize: 14),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Image.asset('assets/images/basil_edit-outline.png'),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Enter OTP',
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 40,
                    ),

                    /*Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: OtpTextField(

                        keyboardType: TextInputType.number,
                        clearText: clearOTP,
                        numberOfFields: 6,
                        borderColor: Color(0xFF512DA8),
                        showFieldAsBox: false,
                        enabled: !isLoading,
                        onCodeChanged: (String code) {
                          setState(() {
                            clearOTP = false;
                          });
                        },
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode){
                          if(kDebugMode)
                            print('OTP is $verificationCode');
                          verifyOTP(verificationCode.length > 6 ? verificationCode.substring(0,6) : verificationCode);
                        }, // end onSubmit
                      ),
                    ),*/

                    OtpPinField(
                      cursorColor: AppColors.primaryColor,
                      autoFillEnable: false,
                      maxLength: 6,
                      onSubmit: (otp) {},
                      onChange: (txt) {
                        print('txt: ${txt} length: ${txt.length}');
                        setState(() {
                          enteredOTP = txt;
                          inValidOTP = false;
                        });
                      },
                      otpPinFieldStyle: OtpPinFieldStyle(
                        activeFieldBorderColor: AppColors.primaryColor,
                        defaultFieldBorderColor:
                            inValidOTP ? Colors.red : Color(0xff333333),
                      ),
                      otpPinFieldDecoration:
                          OtpPinFieldDecoration.underlinedPinBoxDecoration,
                    ),
                    inValidOTP
                        ? Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 20, 0, 0),
                                child: Text(
                                  otpErrorMsg,
                                  style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      color: Color(0xffBA1A1A)),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 50),
                    InkWell(
                      onTap: () {
                        if (kDebugMode) print('length ${enteredOTP.length}');
                        if (enteredOTP.length < 6) {
                          setState(() {
                            inValidOTP = true;
                            otpErrorMsg = 'Enter OTP';
                          });
                        } else {
                          verifyOTP(enteredOTP);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 10),
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
                                              142,
                                              234,
                                              232,
                                              232), // Grey stroke
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
                                  'Verify',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
