import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
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
  final VoidCallback? onOTPSent;
  const SendVerificationCode(
      {super.key,
      required this.type,
      required this.mobile,
      required this.email,
      this.onOTPSent});

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
        /* IconSnackBar.show(
          context,
          label: statusMessage,
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xFFBA1A1A),
          iconColor: Colors.white,
        );*/
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

    print("📤 Sending mobile verification code...");
    print("🔗 URL: $url");
    print("📦 Body: $bodyParams");
    print("🔐 Token: ${retrievedUserData?.token}");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token,
        },
        body: jsonEncode(bodyParams),
      );

      print("✅ Response Status: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error while sending verification code: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
      print("📴 Done sending request. isLoading = false");
    }
  }

  Future<void> sendEmailVerificationCode() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VERIFY_EMAIL_PHONE);

    // Updated body with assumed correct key: "userEmail" instead of "email"
    final bodyParams = {
      "type": "email",
      "userEmail": retrievedUserData
          ?.email, // Change key if backend expects different name
    };

    print("📤 Sending email verification code...");
    print("🔗 URL: $url");
    print("📦 Body: $bodyParams");
    print("🔐 Token: ${retrievedUserData?.token}");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token,
        },
        body: jsonEncode(bodyParams),
      );

      print("✅ Response Status: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("🎉 Email verification code sent successfully.");
      } else {
        final error = jsonDecode(response.body);
        print("⚠️ Error Response Details: $error");
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
      print("📴 Done sending email request. isLoading = false");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),
      body: Stack(
        children: [
          Positioned(
            top: 200,
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
                      child: SvgPicture.asset('assets/images/otp_img.svg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: Text(
                    'Enter OTP',
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  )),
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
                      'We have sent an OTP to your ${widget.type == 'phone' ? 'mobile' : 'email'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xff545454),
                          fontSize: 14,
                          fontFamily: 'Lato'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double availableWidth = constraints.maxWidth - 40;
                      double fieldWidth = (availableWidth / 6).clamp(
                          0.12 * constraints.maxWidth,
                          0.13 * constraints.maxWidth);
                      return OtpPinField(
                        cursorColor: Color(0xff333333),
                        autoFillEnable: false,
                        maxLength: 6,
                        fieldWidth: fieldWidth,
                        fieldHeight: 55,
                        onSubmit: (otp) {
                          FocusScope.of(context).unfocus();
                        },
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
                      );
                    },
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
                        'Didn\'t receive OTP?',
                        style: TextStyle(
                            color: Color(0xff333333),
                            fontSize: 14,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400),
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
                          'Resend',
                          style: TextStyle(
                            color: Color(0xff2979FF),
                            fontSize: 14,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
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
          Positioned(
            top: 40,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xff001B3E),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                      alignment: Alignment.center,
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    });

    if (widget.type == 'phone') {
      if (kDebugMode) {
        print(widget.mobile);
      }
      String? m_mobile = widget.mobile;
      if (m_mobile != null) {
        await sendMobileVerificationCode(m_mobile);
      }
    } else if (widget.type == "email") {
      await sendEmailVerificationCode();
    }

    if (widget.onOTPSent != null) {
      widget.onOTPSent!();
    }
  }
}
