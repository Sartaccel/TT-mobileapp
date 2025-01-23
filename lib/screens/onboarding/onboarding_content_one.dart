import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_turbo_new/AppColors.dart';

class OnboardingContentOne extends StatefulWidget {
  const OnboardingContentOne({super.key});

  @override
  State<OnboardingContentOne> createState() => _OnboardingContentOneState();
}

class _OnboardingContentOneState extends State<OnboardingContentOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          //Image.asset('assets/images/onboarding_one_.png', height: 220),
          SvgPicture.asset('assets/images/slider1.svg', height: 220),
          SizedBox(height: 30,),
          Text('Your Path to Dream Jobs', style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lato'),),
          SizedBox(height: 20,),
          Center(child: Text('Find jobs that match your skills and experience\nwith our smart technology' ,textAlign: TextAlign.center,style: TextStyle(fontSize: 14,color: AppColors.textColor, height: 1.5 ,fontWeight: FontWeight.w400),)),
        ],
      ),
    );
  }
}
