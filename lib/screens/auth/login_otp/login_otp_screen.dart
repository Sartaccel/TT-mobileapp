import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool _isOTPValid = false;

  bool clearOTP = false;
  bool inValidOTP = false;
  String enteredOTP = '';
  String otpErrorMsg = '';
  final GlobalKey otpKey = GlobalKey();
  String otpFieldKey = UniqueKey().toString();

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
        label: "No internet connection, try again",
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
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeContainer(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (Route<dynamic> route) => route.isFirst,
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

  Future<void> resendOTP() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN_BY_MOBILE);
    final bodyParams = {
      "countryCode": widget.countryCode,
      "phoneNumber": widget.mobileNumber
    };

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      IconSnackBar.show(
        context,
        label: "No internet connection, try again",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      return;
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
        print('${response.statusCode} :: ${response.body}');
      }

      var resOBJ = jsonDecode(response.body);
      String statusMessage = resOBJ['message'];

      if (response.statusCode == 200) {
        // Reset OTP field and clear states
        setState(() {
          enteredOTP = "";
          inValidOTP = false;
          otpFieldKey = UniqueKey().toString();
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
                SvgPicture.asset('assets/icon/send.svg'),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'OTP resent successfully',
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
        IconSnackBar.show(
          context,
          label: statusMessage,
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
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
        label: "No internet connection, try again",
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
        /*IconSnackBar.show(
          context,
          label: 'Invalid OTP',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );*/
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SvgPicture.asset('assets/images/otp_img.svg'),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: InkWell(
                            onTap: () {
                              //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> HomeContainer()));
                            },
                            child: Text(
                              'Login with OTP',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ))),
                    SizedBox(
                      height: 20,
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xff545454), Color(0xff004C99)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'We have sent an OTP to this number',
                        style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8), // Increase touch area
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  8), // Optional rounded effect
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${widget.countryCode}${widget.mobileNumber}',
                                  style: TextStyle(
                                      color: Color(0xff2979FF), fontSize: 14),
                                ),
                                SizedBox(width: 10),
                                SvgPicture.asset(
                                  'assets/icon/OTPedit.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
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

                    LayoutBuilder(
                      builder: (context, constraints) {
                        double availableWidth = constraints.maxWidth - 40;
                        double fieldWidth = (availableWidth / 6).clamp(
                            0.12 * constraints.maxWidth,
                            0.13 * constraints.maxWidth);
                        return OtpPinField(
                          key: ValueKey(otpFieldKey),
                          cursorColor: Color(0xff333333),
                          autoFillEnable: false,
                          maxLength: 6,
                          fieldWidth: fieldWidth,
                          fieldHeight: 55,
                          onSubmit: (otp) {
                            FocusScope.of(context).unfocus();
                          },
                          onChange: (txt) {
                            print('txt: $txt length: ${txt.length}');
                            setState(() {
                              enteredOTP = txt;
                              inValidOTP = false;
                            });
                          },
                          otpPinFieldStyle: OtpPinFieldStyle(
                            activeFieldBorderColor: Color(0xff333333),
                            defaultFieldBorderColor:
                                inValidOTP ? Colors.red : Color(0xffA9A9A9),
                            fieldBorderWidth: 2,
                            filledFieldBackgroundColor: Colors.transparent,
                            filledFieldBorderColor:
                                inValidOTP ? Colors.red : Color(0xff333333),
                          ),
                          otpPinFieldDecoration:
                              OtpPinFieldDecoration.underlinedPinBoxDecoration,
                          showCursor: true,
                          cursorWidth: 2,
                        );
                      },
                    ),
                    inValidOTP
                        ? Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 10, 0, 0),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code?',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                resendOTP();
                                enteredOTP = "";
                                inValidOTP = false;
                                otpController.clear();
                                otpFieldKey = UniqueKey()
                                    .toString(); // Clear text controller
                              });

                              // Recreate the OtpPinField widget
                              setState(() {
                                otpKey.currentState
                                    ?.dispose(); // Dispose the old widget
                              });
                            },
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                  color: Color(0xff2979FF),
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
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
                                        angle: value * 2 * 3.1416,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          value: 0.20,
                                          backgroundColor: const Color.fromARGB(
                                              142, 234, 232, 232),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      );
                                    },
                                    onEnd: () => {},
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
