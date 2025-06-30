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
import '../../../data/preference.dart';
import '../../../models/candidate_profile_model.dart';
import '../../../models/user_data_model.dart';

class MobileVerificationScreen extends StatefulWidget {
  final String countryCode;
  final String mobileNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final int userId; // ADD THIS

  const MobileVerificationScreen({
    super.key,
    required this.countryCode,
    required this.mobileNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.userId, // ADD THIS
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
    _startResendTimer(); // Start the timer as soon as the screen loads
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyAndRegister(String otp) async {
    print("🟡 Starting user activation process...");

    if (!await _hasInternet()) {
      print("❌ No internet connection.");
      IconSnackBar.show(
        context,
        label: "No internet connection",
        snackBarType: SnackBarType.alert,
      );
      return;
    }

    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.API_NEW_VERIFY_OTP);

    setState(() => isLoading = true);

    final activationBody = {
      "activationKey": otp,
      "phoneNumber": "${widget.countryCode}${widget.mobileNumber}",
    };

    print("📦 Activation Body Details:");
    print("🔑 activationKey: ${activationBody['activationKey']}");
    print("📱 phoneNumber: ${activationBody['phoneNumber']}");

    print("📩 Activate API URL: $url");
    print("📨 Activate Request Body: $activationBody");

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(activationBody),
          )
          .timeout(const Duration(seconds: 30));

      print("📥 Raw Response: ${response.body}");
      print("📡 Status Code: ${response.statusCode}");

      final responseBody = jsonDecode(response.body);
      print("📩 Activate Response JSON: $responseBody");

      if (response.statusCode == 200 && responseBody['result'] == true) {
        print(responseBody.toString());

        final Map<String, dynamic> data = responseBody['data'];
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

        print("✅ User activated successfully.");
        IconSnackBar.show(
          context,
          label: responseBody['message'] ?? "User activated successfully",
          snackBarType: SnackBarType.success,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeContainer()),
          (route) => false,
        );
      } else {
        print("❌ Activation failed: ${responseBody['message']}");
        throw Exception(responseBody['message'] ?? 'Activation failed');
      }
    } catch (e) {
      print("🔥 Exception during activation: $e");
      IconSnackBar.show(
        context,
        label: e.toString().replaceAll('Exception: ', ''),
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => isLoading = false);
      print("🔚 Activation process finished. isLoading = false");
    }
  }

  Future<void> _resendOtp(String userId) async {
    print("🟡 Starting resend OTP process...");

    if (!await _hasInternet()) {
      print("❌ No internet connection.");
      IconSnackBar.show(
        context,
        label: "No internet connection",
        snackBarType: SnackBarType.alert,
      );
      return;
    }
    final url =
        Uri.parse("${AppConstants.BASE_URL.replaceAll(RegExp(r'/$'), '')}"
            "/api/v1/userresource/resend/otp/$userId");

    print("📩 Resend OTP API URL: $url");
    print("📩 userid: $userId");

    try {
      setState(() => isLoading = true);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print("📥 Raw Response: ${response.body}");
      print("📡 Status Code: ${response.statusCode}");

      if (response.body.isNotEmpty) {
        final responseBody = jsonDecode(response.body);
        print("📩 Resend OTP Response JSON: $responseBody");

        if (response.statusCode == 200 && responseBody['status'] == "OK") {
          IconSnackBar.show(
            context,
            label: responseBody['message'] ?? "OTP resent successfully",
            snackBarType: SnackBarType.success,
          );
          print("✅ OTP resent successfully.");

          _startResendTimer(); // ✅ Restart timer here
        } else {
          print("❌ Resend OTP failed: ${responseBody['message']}");
          throw Exception(responseBody['message'] ?? 'Resend OTP failed');
        }
      } else {
        throw Exception('Empty response from server');
      }
    } catch (e) {
      print("🔥 Exception during resend OTP: $e");
      IconSnackBar.show(
        context,
        label: e.toString().replaceAll('Exception: ', ''),
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() => isLoading = false);
      print("🔚 Resend OTP process finished. isLoading = false");
    }
  }

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

  // Future<void> _verifyAndRegister(String otp, String token) async {
  //   if (!await _hasInternet()) {
  //     IconSnackBar.show(
  //       context,
  //       label: "No internet connection",
  //       snackBarType: SnackBarType.alert,
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isLoading = true;
  //     inValidOTP = false;
  //   });

  //   try {
  //     // 1. Verify OTP first
  //     final verifyResponse = await http.post(
  //       Uri.parse(AppConstants.BASE_URL + AppConstants.OTPNewAPI),
  //       headers: {'Content-Type': 'application/json', 'Authorization': token},
  //       body: jsonEncode({
  //         "type": "phone",
  //         "verificationCode": otp,
  //         "countryCode": widget.countryCode,
  //         "phoneNumber": widget.mobileNumber,
  //       }),
  //     );

  //     final verifyResponseBody = jsonDecode(verifyResponse.body);

  //     if (verifyResponse.statusCode != 200) {
  //       throw Exception(verifyResponseBody['message'] ?? 'Invalid OTP');
  //     }

  //     // 2. Register User after OTP verification
  //     final registerResponse = await http.post(
  //       Uri.parse(AppConstants.BASE_URL + AppConstants.REGISTER),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "firstName": widget.firstName,
  //         "lastName": widget.lastName,
  //         "email": widget.email,
  //         "password": widget.password,
  //         "countryCode": widget.countryCode,
  //         "phoneNumber": widget.mobileNumber,
  //         "priAccUserType": "candidate"
  //       }),
  //     );

  //     final registerResponseBody = jsonDecode(registerResponse.body);

  //     if (registerResponse.statusCode == 200) {
  //       // Success case
  //       IconSnackBar.show(
  //         context,
  //         label: registerResponseBody['message'] ?? 'Registration successful!',
  //         snackBarType: SnackBarType.success,
  //       );
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (_) => HomeContainer()),
  //         (route) => false,
  //       );
  //     } else {
  //       // Handle specific registration errors
  //       String errorMessage =
  //           registerResponseBody['message'] ?? 'Registration failed';

  //       // Check for common error cases
  //       if (registerResponseBody.containsKey('errors')) {
  //         final errors = registerResponseBody['errors'];
  //         if (errors is Map) {
  //           errorMessage = errors.values.first.join(', ');
  //         } else if (errors is List) {
  //           errorMessage = errors.join(', ');
  //         }
  //       }

  //       throw Exception(errorMessage);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       inValidOTP = true;
  //       otpErrorMsg = e.toString().replaceAll('Exception: ', '');
  //     });

  //     // Show detailed error message
  //     IconSnackBar.show(
  //       context,
  //       label: otpErrorMsg,
  //       snackBarType: SnackBarType.fail,
  //       duration: const Duration(seconds: 3),
  //     );
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double totalSpacing = 5 *
                              12; // Assuming 6 fields with 12px spacing between them
                          double availableWidth =
                              constraints.maxWidth - totalSpacing;

                          double fieldWidth = (availableWidth / 6)
                              .clamp(40.0, 55.0); // Slightly smaller max

                          return OtpPinField(
                            cursorColor: const Color(0xff333333),
                            autoFillEnable: false,
                            maxLength: 6,
                            fieldWidth: fieldWidth,
                            fieldHeight: 55,
                            onSubmit: (otp) => FocusScope.of(context).unfocus(),
                            onChange: (txt) {
                              print('txt: $txt length: ${txt.length}');
                              setState(() {
                                enteredOTP = txt;
                                inValidOTP = false;
                              });
                            },
                            otpPinFieldStyle: OtpPinFieldStyle(
                              activeFieldBorderColor: const Color(0xff333333),
                              defaultFieldBorderColor: inValidOTP
                                  ? Colors.red
                                  : const Color(0xffA9A9A9),
                              fieldBorderWidth: 2,
                              filledFieldBackgroundColor: Colors.transparent,
                              filledFieldBorderColor: const Color(0xff333333),
                            ),
                            otpPinFieldDecoration: OtpPinFieldDecoration
                                .underlinedPinBoxDecoration,
                            showCursor: true,
                            cursorWidth: 2,
                          );
                        },
                      ),
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
                                onTap: () => _resendOtp(widget.userId
                                    .toString()), // <-- Wrapped in closure with userId
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: Color(0xff2979FF),
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                          if (kDebugMode)
                            print('comestoiffcontition ${verificationToken}');
                          print("Entered OTP: $enteredOTP");
                          _verifyAndRegister(enteredOTP);
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
