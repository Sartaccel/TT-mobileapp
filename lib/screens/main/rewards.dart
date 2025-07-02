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
  int totalPoints = 0;

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
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F7F7),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFD9D9D9),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 35.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 160,
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
                                          'Reward ${totalPoints == 0 || totalPoints == 1 ? "point" : "points"}',
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              color: Color(0xff333333),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '$totalPoints',
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              color: Color(0xff333333),
                                              fontSize: 46,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/images/rewards_ic.svg',
                                width: MediaQuery.of(context).size.width * 0.55,
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 20.0, bottom: 5.0),
                          child: Text(
                            'Points History',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Color(0xff333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      rewardHistory.length > 0
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: 6,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15.0, 0, 15.0, 0),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15.0, 0, 15.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xFFD9D9D9),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
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
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Ajay',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff333333),
                                                      fontSize: 16,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Placed in ZOhO ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff545454),
                                                      fontSize: 12,
                                                      fontFamily: 'Lato',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '+35',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff333333),
                                              fontSize: 14,
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/no_rewards.svg',
                                      width: MediaQuery.of(context).size.width *
                                          0.29,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      'No points yet',
                                      style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xff333333)),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'It looks like you haven\'t referred anyone, \nso there are no points to display.\nStart referring now to begin earning!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xff545454),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: rewardHistory.length > 0
                                ? AppColors.primaryColor
                                : Color(0xFFE1E1E2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            'Redeem',
                            style: TextStyle(
                              color: rewardHistory.length > 0
                                  ? Color(0xffFFFFFF)
                                  : Color(0xff717070),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                            ),
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
