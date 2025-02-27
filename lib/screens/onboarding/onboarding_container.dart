import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/auth/register/register_new_user.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_content_one.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_content_three.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_content_two.dart';

class OnboardingContainer extends StatefulWidget {
  const OnboardingContainer({super.key});

  @override
  State<OnboardingContainer> createState() => _OnboardingContainerState();
}

class _OnboardingContainerState extends State<OnboardingContainer> {

  final PageController _controller = PageController();
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/images/tt_logo_full.png', height: 205,)
        ],
      ),
    );*/

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Image.asset('assets/images/tt_logo_full_1.png', width: 200,),
            SizedBox(height: 40,),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _controller,
                children: [
                  OnboardingContentOne(),
                  OnboardingContentTwo(),
                  OnboardingContentThree(),
                ],
              ),
            ),
            Column(
              children: [
                SmoothPageIndicator(
        
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotHeight: 5,
                      activeDotColor: Color(0xff004C99)
        
                  ), // You can customize the indicator style
                ),
                SizedBox(height: 80),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> LoginScreen()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 44,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: AppColors.primaryColor,borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('Get Started', style: TextStyle(color: Colors.white),),),
                  ),
                ),
              ],
            ),
        
        
        
        
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Timer for auto-sliding
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      int nextPage = _controller.page!.round() + 1;
      if (nextPage == 3) {
        nextPage = 0;
      }
      _controller.animateToPage(nextPage,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
