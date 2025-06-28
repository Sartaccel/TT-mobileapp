import 'package:flutter/material.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:talent_turbo_new/AppColors.dart';

class OTP_TestScreen extends StatefulWidget {
  const OTP_TestScreen({super.key});

  @override
  State<OTP_TestScreen> createState() => _OTP_TestScreenState();
}

class _OTP_TestScreenState extends State<OTP_TestScreen> {

  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OtpPinField(
            cursorColor: AppColors.primaryColor,
            autoFillEnable: false,
            maxLength: 6,
            onSubmit: (pin){
              print(pin);
            },
            onChange: (txt){},

          otpPinFieldStyle: OtpPinFieldStyle(
            activeFieldBorderColor: AppColors.primaryColor,
            defaultFieldBorderColor: Color(0xff333333),
          ),
          otpPinFieldDecoration: OtpPinFieldDecoration.underlinedPinBoxDecoration,
        ),
      ),
    );
  }
}
