import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';

class SendVerificationCode extends StatefulWidget {
  final String type;
  final String? mobile;
  final String? email;
  const SendVerificationCode(
      {super.key,
      required this.type,
      required this.mobile,
      required this.email});

  @override
  State<SendVerificationCode> createState() => _SendVerificationCodeState();
}

class _SendVerificationCodeState extends State<SendVerificationCode> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey otpKey = GlobalKey();
  String otpFieldKey = UniqueKey().toString();

  bool isLoading = false;
  UserData? retrievedUserData;

  bool inValidOTP = false;
  String enteredOTP = '';
  String otpErrorMsg = '';

  Future<void> validateOTP(String receivedOTP) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VALIDATE_VERIFY_OTP);

    final bodyParams = {"type": widget.type, "verificationCode": receivedOTP};

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

      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': retrievedUserData!.token
          },
          body: jsonEncode(bodyParams));

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      var resOBJ = jsonDecode(response.body);
      String statusMessage = resOBJ['message'];

      if (response.statusCode == 200 || response.statusCode == 200) {
        Navigator.pop(context);
      } else if (response.statusCode >= 400) {
        setState(() {
          inValidOTP = true;
          otpErrorMsg = 'Incorrect OTP';
        });
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
          backgroundColor: Color(0xFFBA1A1A),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMobileVerificationCode(String mobile) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VERIFY_EMAIL_PHONE);
    final bodyParams = {
      "type": "phone",
      "mobile": mobile,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print('${response.statusCode} :: ${response.body}');
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

  Future<void> sendEmailVerificationCode() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VERIFY_EMAIL_PHONE);
    final bodyParams = {
      "type": "email",
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print('${response.statusCode} :: ${response.body}');
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

  @override
  Widget build(BuildContext context) {
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
            top: 120,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/otp_img.png'),
                  Center(
                      child: Text(
                    'Enter OTP',
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),

                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    //child: Text('Please enter the OTP send to your mobile number and email address', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14, fontFamily: 'Lato'),),
                    child: Text(
                      'Please enter the OTP send to your ${widget.type == 'phone' ? 'mobile number' : 'email address'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          fontFamily: 'Lato'),
                    ),
                  ),

                  SizedBox(
                    height: 40,
                  ),

                  OtpPinField(
                    cursorColor: AppColors.primaryColor,
                    autoFillEnable: false,
                    maxLength: 6,
                    onSubmit: (otp) {},
                    onChange: (txt) {
                      setState(() {
                        ValueKey(enteredOTP);
                        enteredOTP = txt;
                        inValidOTP = false;
                        otpFieldKey = UniqueKey().toString();
                        otpController.clear();
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
                              padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                              child: Text(
                                otpErrorMsg,
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 12,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        )
                      : Container(),

                  //Loading
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Visibility(
                        visible: isLoading,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            LoadingAnimationWidget.fourRotatingDots(
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 50),
                  InkWell(
                    onTap: () {
                      //validateOTP(finOTP);
                      if (kDebugMode) print('length ${enteredOTP.length}');
                      if (enteredOTP.length < 6) {
                        setState(() {
                          inValidOTP = true;
                          otpErrorMsg =
                              'Enter valid OTP before clicking verify';
                        });
                      } else {
                        validateOTP(enteredOTP);
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
                        child: Text(
                          'Verify',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          // Reset OTP field and clear states
                          setState(() {
                            enteredOTP = "";
                            inValidOTP = false;
                            otpController.clear();
                            otpFieldKey =
                                UniqueKey().toString(); // Clear text controller
                          });

                          // Recreate the OtpPinField widget
                          setState(() {
                            otpKey.currentState
                                ?.dispose(); // Dispose the old widget
                          });

                          // Resend logic
                          if (widget.type == 'phone') {
                            String? m_mobile = widget.mobile;
                            if (m_mobile != null) {
                              sendMobileVerificationCode(m_mobile);
                            }
                          } else if (widget.type == 'email') {
                            sendEmailVerificationCode();
                          }
                        },
                        child: Text(
                          'Click to resend',
                          style: TextStyle(
                            color: Color(0xff004C99),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 30,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      retrievedUserData = _retrievedUserData;

      if (widget.type == 'phone') {
        if (kDebugMode) {
          print(widget.mobile);
        }
        String? m_mobile = widget.mobile;
        if (m_mobile != null) {
          sendMobileVerificationCode(m_mobile);
        }
        //sendMobileVerificationCode("+918056709318");
      }

      if (widget.type == "email") {
        sendEmailVerificationCode();
      }
    });
  }
}
