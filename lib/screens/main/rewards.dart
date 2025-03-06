import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_turbo_new/AppColors.dart';

class MyRewards extends StatefulWidget {
  const MyRewards({super.key});

  @override
  State<MyRewards> createState() => _MyRewardsState();
}

class _MyRewardsState extends State<MyRewards> {
  bool rewardsAvailable = true;

  var rewardHistory = [];

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
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
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  color: Colors.white),
                            ))))
                  ],
                ),
                //SizedBox(width: 80,)
                Text(
                  'My Rewards',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '       ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          rewardsAvailable
              ? Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 125,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Reward points',
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Color(0xff333333),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '0',
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            color: Color(0xff333333),
                                            fontSize: 46,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Points History',
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        color: Color(0xff333333),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset('assets/images/rewards_ic.svg')
                          ],
                        ),
                      ),
                      Divider(),
                      rewardHistory.length > 0
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: 2,
                                  itemBuilder: (context, i) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/user_.webp',
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Ajay',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xff333333),
                                                            fontSize: 16,
                                                            fontFamily: 'Lato'),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        'Placed in SART ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                                0xff545454),
                                                            fontSize: 12,
                                                            fontFamily: 'Lato'),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Text(
                                                '+35',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xff333333),
                                                    fontSize: 14,
                                                    fontFamily: 'Lato'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  }),
                            )
                          : Expanded(
                              child: Center(
                              child: Text('No rewards yet'),
                            )),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: rewardHistory.length > 0
                                ? AppColors.primaryColor
                                : AppColors.disabledColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            'Redeem',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Expanded(
                  child: Center(
                  child: Text('No rewards yet!'),
                ))
        ],
      ),
    );
  }
}
