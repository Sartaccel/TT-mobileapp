import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_turbo_new/AppColors.dart';

class OnboardingContentThree extends StatefulWidget {
  const OnboardingContentThree({super.key});

  @override
  State<OnboardingContentThree> createState() => _OnboardingContentThreeState();
}

class _OnboardingContentThreeState extends State<OnboardingContentThree> {
  @override
  Widget build(BuildContext context) {
    return Container(

      child: Column(
        children: [
          //Image.asset('assets/images/onboarding_three.png', height: 220,),
          SvgPicture.asset('assets/images/slider3.svg', height: 220,),
          SizedBox(height: 30,),
          Text('Grow Your Network', style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lato'),),
          SizedBox(height: 20,),
          Center(child: Text('Connect, share jobs, and grow your professional \n network.' ,textAlign: TextAlign.center,style: TextStyle(fontSize: 14,color: AppColors.textColor, height: 1.5 ,fontWeight: FontWeight.w400),)),
        ],
      ),
    );
  }
}
