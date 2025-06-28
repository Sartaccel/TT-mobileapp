import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:http/http.dart' as http;
import '../../../Utils.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';

class MobileVerificationScreen extends StatefulWidget {
  final String countryCode;
  final String mobileNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const MobileVerificationScreen({
    super.key,
    required this.countryCode,
    required this.mobileNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  State<MobileVerificationScreen> createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  bool isLoading = false;
  bool clearOTP = false;
  bool inValidOTP = false;
  String enteredOTP = '';
  String otpErrorMsg = '';
  bool isResendAvailable = false;
  int resendSeconds = 30;
  Timer? _resendTimer;
  String? verificationToken;

  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _startResendTimer() {
    setState(() {
      resendSeconds = 30;
      isResendAvailable = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        resendSeconds--;
        if (resendSeconds <= 0) {
          isResendAvailable = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!await _hasInternet()) {
      IconSnackBar.show(
        context,
        label: "No internet connection, try again",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      return;
    }

    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.VERIFY_EMAIL_PHONE);
    setState(() => isLoading = true);

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "type": "phone",
              "mobile": widget.mobileNumber,
              "countryCode": widget.countryCode,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        IconSnackBar.show(
          context,
          label: responseBody['message'] ?? "OTP sent successfully",
          snackBarType: SnackBarType.success,
        );
        verificationToken = responseBody['token'];
        print('Received verification token: $verificationToken');
        // optional if needed
        _startResendTimer();
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: e.toString().replaceAll('Exception: ', ''),
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyAndRegister(String otp, String token) async {
    if (!await _hasInternet()) {
      IconSnackBar.show(
        context,
        label: "No internet connection, try again",
        snackBarType: SnackBarType.alert,
      );
      return;
    }

    setState(() {
      isLoading = true;
      inValidOTP = false;
    });

    try {
      // 1. Verify OTP first
      final verifyResponse = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.VALIDATE_VERIFY_OTP),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({
          "type": "phone",
          "verificationCode": otp,
          "countryCode": widget.countryCode,
          "phoneNumber": widget.mobileNumber,
        }),
      );

      final verifyResponseBody = jsonDecode(verifyResponse.body);

      if (verifyResponse.statusCode != 200) {
        throw Exception(verifyResponseBody['message'] ?? 'Invalid OTP');
      }

      // 2. Register User after OTP verification
      final registerResponse = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.REGISTER),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": widget.firstName,
          "lastName": widget.lastName,
          "email": widget.email,
          "password": widget.password,
          "countryCode": widget.countryCode,
          "phoneNumber": widget.mobileNumber,
          "priAccUserType": "candidate"
        }),
      );

      final registerResponseBody = jsonDecode(registerResponse.body);

      if (registerResponse.statusCode == 200) {
        // Success case
        IconSnackBar.show(
          context,
          label: registerResponseBody['message'] ?? 'Registration successful!',
          snackBarType: SnackBarType.success,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeContainer()),
          (route) => false,
        );
      } else {
        // Handle specific registration errors
        String errorMessage =
            registerResponseBody['message'] ?? 'Registration failed';

        // Check for common error cases
        if (registerResponseBody.containsKey('errors')) {
          final errors = registerResponseBody['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first.join(', ');
          } else if (errors is List) {
            errorMessage = errors.join(', ');
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      setState(() {
        inValidOTP = true;
        otpErrorMsg = e.toString().replaceAll('Exception: ', '');
      });

      // Show detailed error message
      IconSnackBar.show(
        context,
        label: otpErrorMsg,
        snackBarType: SnackBarType.fail,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0x04FCFCFC),
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Back', style: TextStyle(fontSize: 16))
                ],
              ),
            ),
          ),
          Positioned(
            top: 150,
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
                        child: SvgPicture.asset('assets/images/otp_img.svg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Enter OTP',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 40),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xff545454), Color(0xff004C99)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'We have sent an OTP to your mobile number',
                        style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${widget.countryCode}${widget.mobileNumber}',
                                style: TextStyle(
                                    color: Color(0xff333333), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double availableWidth = constraints.maxWidth - 40;
                        double fieldWidth =
                            (availableWidth / 6).clamp(40.0, 45.0);

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
                            filledFieldBorderColor: Color(0xff333333),
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
                    isResendAvailable
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn\'t receive OTP?',
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: _sendOTP,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                      color: Color(0xff2979FF),
                                      fontFamily: 'Lato',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )
                        : Text(
                            'Resend OTP in 00:$resendSeconds',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              color: Color(0xff333333),
                            ),
                          ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        if (kDebugMode) print('length ${enteredOTP.length}');
                        if (enteredOTP.length < 6) {
                          setState(() {
                            inValidOTP = true;
                            otpErrorMsg = 'Enter OTP';
                          });
                        } else {
                          if (verificationToken == null) {
                            IconSnackBar.show(
                              context,
                              label: 'OTP token not received yet. Please wait!',
                              snackBarType: SnackBarType.alert,
                            );
                            return;
                          }
                          _verifyAndRegister(enteredOTP, verificationToken!);
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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
