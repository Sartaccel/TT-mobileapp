import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';

class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({super.key});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> {
   bool isLoading = false;

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
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keeps the column compact
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/Animation - 1722592346112.json',
                  width: 100, 
                  fit: BoxFit.contain,
                  repeat: false
                ),
                const SizedBox(height: 20),
               Text(
  "Password reset successful",
  style: GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xff004C99),
  ),
),
SizedBox(height: 50,),
               InkWell(
  onTap: () {
    Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
);
// Replace with actual route
  },
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(color: Colors.white),
              ),
      ),
    ),
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
