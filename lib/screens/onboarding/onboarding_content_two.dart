import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_turbo_new/AppColors.dart';

class OnboardingContentTwo extends StatefulWidget {
  const OnboardingContentTwo({super.key});

  @override
  State<OnboardingContentTwo> createState() => _OnboardingContentTwoState();
}

class _OnboardingContentTwoState extends State<OnboardingContentTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(

      child: Column(
        children: [
          SvgPicture.asset('assets/images/slider2.svg', height: 220,),
          SizedBox(height: 30,),
          Text('Refer & Earn', style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lato'),),
          SizedBox(height: 20,),
          Center(child: Text('Help friends land dream jobs and earn referral\nbonuses!' ,textAlign: TextAlign.center,style: TextStyle(fontSize: 14,color: AppColors.textColor, height: 1.5 ,fontWeight: FontWeight.w400),)),
        ],
      ),
    );
  }
}
