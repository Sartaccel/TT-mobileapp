import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_apply.dart';
import 'package:http/http.dart' as http;

class Jobdetails extends StatefulWidget {
  final dynamic jobData;
  final bool isFromSaved;
  const Jobdetails(
      {super.key, required this.jobData, required this.isFromSaved});

  @override
  State<Jobdetails> createState() => _JobdetailsState();
}

class _JobdetailsState extends State<Jobdetails> {
  bool isLoading = true;
  ReferralData? referralData;
  UserData? retrievedUserData;

  bool isSaved = false;

  List<dynamic> eligibilityList = [];
  List<dynamic> technologyList = [];

  void _shareApp(String refCode) {
    //final String appUrl = "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";
    final String appUrl =
        "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo&referrer=$refCode";
    Share.share(
      "💼 ${rawJobData['data']['jobTitle'] ?? 'N/A'} position available at ${widget.jobData['companyName'] ?? 'N/A'}! \n\nDon’t miss this chance—apply today: Download now at $appUrl. \n\nUse my referral code $refCode while signing up. \n\n#GetHired #Jobs #TalentTurbo",
      subject: 'Try this awesome app!',
    );
  }

  bool isConnectionAvailable = true;

  var rawJobData = null;

  Future<void> getJobData() async {
    final url = widget.isFromSaved
        ? Uri.parse(AppConstants.BASE_URL +
            AppConstants.VIEW_JOB +
            (widget.jobData['jobId'] ?? widget.jobData['id']).toString())
        : Uri.parse(AppConstants.BASE_URL +
            AppConstants.VIEW_JOB +
            widget.jobData['id'].toString());

    print(widget.jobData['id'].toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        /*if (kDebugMode) {
          print('Response code inside ${response.statusCode} :: Response => ${resOBJ}');
        }*/

        setState(() {
          rawJobData = resOBJ;
          eligibilityList = resOBJ['data']['eligibilityData'];
          technologyList = resOBJ['data']['technologyList'];
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
          label: 'No internet connection',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );

        setState(() {
          isConnectionAvailable = false;
        });

        //return;  // Exit the function if no internet
      } else {
        setState(() {
          isConnectionAvailable = true;
        });
      }
      print(e.toString());
    }
  }

  Future<void> saveJob(int jobId, int status) async {
    print('status : ${status}');
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV);
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV_NEW);

    final bodyParams = {"jobId": jobId, "isFavorite": status};

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 202) {
        // Fluttertoast.showToast(
        //     msg: 'Updated successfully',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Color(0xff2D2D2D),
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: 'Updated successfully',
          snackBarType: SnackBarType.success,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        setState(() {
          isSaved = !isSaved;
          isLoading = false;
          //jobSearchTerm ="";
          //fetchAllJobs();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

 

bool checkExpiry(String dateString) {
  // Parse the date string
  DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);

  // Get the current date at midnight
  DateTime currentDate = DateTime.now();
  currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

  // Reset providedDate to midnight as well
  providedDate = DateTime(providedDate.year, providedDate.month, providedDate.day);

  // Compare the dates
  return providedDate.isBefore(currentDate);
}


  Future<void> getRefCode(int jobId) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.GET_REF_CODE_SHARE);

    final bodyParams = {
      "jobId": jobId,
    };

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resObj = jsonDecode(response.body);

        _shareApp(resObj['referralCode'].toString());
      } else {
        // Fluttertoast.showToast(
        //   msg: 'Failed to share JOB.',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: 'Failed to share JOB.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xFFBA1A1A),
          iconColor: Colors.white,
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
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
                  'Job Details',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
                SizedBox(
                  width: 80,
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Visibility(
                        visible: isLoading,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            LoadingAnimationWidget.fourRotatingDots(
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : rawJobData != null
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          //Image.asset('assets/images/bmw_logo.png', height: 41, width: 41, ),
                                          Image(
                                            image: widget.jobData['logo'] !=
                                                        null &&
                                                    widget.jobData['logo']
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    widget.jobData['logo'],
                                                  ) as ImageProvider<Object>
                                                : const AssetImage(
                                                    'assets/images/tt_logo_resized.png'),
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // Fallback to asset if network image fails
                                              return Image.asset(
                                                  'assets/images/tt_logo_resized.png',
                                                  height: 40,
                                                  width: 40);
                                            },
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      150,
                                                  child: Text(
                                                    rawJobData['data']
                                                            ['jobTitle'] ??
                                                        '',
                                                    //'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: 'Lato',
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xff333333)),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                widget.jobData['companyName'] ==
                                                        null
                                                    ? ''
                                                    : widget
                                                        .jobData['companyName'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Lato',
                                                    fontSize: 14,
                                                    color: Color(0xff545454)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      //Icon( rawJobData['data']['isFavorite'] ==1? Icons.bookmark : Icons.bookmark_border_rounded, size: 25,)
                                      InkWell(
                                          onTap: () {
                                            //saveJob(jobList[index]['id'], jobList[index]['isSaved'] ? 0 : 1);
                                            if (kDebugMode) {
                                              print('Status: ${isSaved}');
                                              print(
                                                  'id: ${widget.jobData['id']}');
                                              print(
                                                  'jobId: ${widget.jobData['jobId']}');
                                            }
                                            saveJob(
                                                widget.jobData['id'] ??
                                                    widget.jobData['jobId'],
                                                isSaved ? 0 : 1);
                                            /* saveJob(
                                      jobList[index]['id'],
                                      (jobList[index]['isSaved'] ?? 0) == 1 ? 0 : 1
                                  );*/
                                          },
                                          child: Icon(
                                            //(widget.jobData['isFavorite'] == "1")
                                            isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border_rounded,
                                            size: 25,
                                          ))
                                    ],
                                  ),

                                  Container(
                                    margin: EdgeInsets.fromLTRB(60, 15, 0, 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            widget.jobData['jobCode'] ??
                                                'TT-JB-9571',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff545454),
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Text(
                                            'Posted ${processDate(widget.jobData['dueDate'])}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff545454)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: 157,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/images/ic_worktype.svg'),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  'Employment type',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  widget.jobData['workType'],
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 157,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/images/ic_experience.svg'),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  'Experience',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                               Text(
  '${(rawJobData['data']['experience'] ?? 1).toInt()}+ years',
  style: TextStyle(
    fontFamily: 'Lato',
    color: Color(0xff333333),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
),


                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: 157,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/images/ic_onsite.svg'),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  'Work type',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  rawJobData['data']
                                                      ['workType'],
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 157,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/images/ic_job_location.svg'),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  'Location',
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  widget.jobData['location'] ??
                                                      'N/A',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Skills required:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        fontSize: 18,
                                        fontFamily: 'Lato'),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Wrap(
                                      spacing:
                                          8.0, // Horizontal space between boxes
                                      runSpacing:
                                          12.0, // Vertical space between rows
                                      children: List.generate(
                                          technologyList.length, (i) {
                                        return technologyList[i]
                                                    ['technologyName'] ==
                                                null
                                            ? Container()
                                            : Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                    color: Color(0xffF0F6FF)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/ic_tick.png',
                                                      height: 8,
                                                      width: 12,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      technologyList[i]
                                                          ['technologyName'],
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'Lato',
                                                          color: Color(
                                                              0xff004C99)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                      }),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Job description',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        fontSize: 18,
                                        fontFamily: 'Lato'),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  //Job Description
                                  /* Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                      children: [
                                        TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff333333), // Make sure to set color when using TextSpan
                                        ),),
                                        TextSpan(
                                          text:
                                          'Identify and research potential clients and market opportunities to generate new business leads.',
                                          style: TextStyle(
                                            height: 1.5,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),
                                        ),
                                      ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),


                            ],
                          ),
                        ),*/

                                  widget.jobData['jobDescription']
                                          .toString()
                                          .trim()
                                          .isEmpty
                                      ? Text("No description available")
                                      : Html(
                                          data: widget.jobData['jobDescription']
                                                  ?.toString()
                                                  .trim() ??
                                              'No description available',
                                          style: {
                                            "p": Style(
                                              fontSize: FontSize(18.0),
                                              textAlign: TextAlign.justify,
                                              color: Color(0xff333333),
                                            ),
                                          },
                                        ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Qualifications: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        fontSize: 18,
                                        fontFamily: 'Lato'),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top:
                                                      10.0), // Adjust padding if needed
                                              child: Icon(
                                                Icons
                                                    .brightness_1, // You can use any icon you prefer for the bullet
                                                size:
                                                    8, // Small size for the bullet
                                                color: Colors
                                                    .black, // Adjust color if necessary
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                  text: 'Experience: ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(
                                                        0xff333333), // Make sure to set color when using TextSpan
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${rawJobData['data']['experience']} ${rawJobData['data']['expType']}',
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(
                                                        0xff333333), // Make sure to set color when using TextSpan
                                                  ),
                                                ),
                                              ])),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top:
                                                      10.0), // Adjust padding if needed
                                              child: Icon(
                                                Icons
                                                    .brightness_1, // You can use any icon you prefer for the bullet
                                                size:
                                                    8, // Small size for the bullet
                                                color: Colors
                                                    .black, // Adjust color if necessary
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                  text: 'Education: ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(
                                                        0xff333333), // Make sure to set color when using TextSpan
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      eligibilityList.length > 0
                                                          ? eligibilityList[0]
                                                              ['dataName']
                                                          : ' - ',
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(
                                                        0xff333333), // Make sure to set color when using TextSpan
                                                  ),
                                                ),
                                              ])),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  Text(
                                    'Salary: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        fontSize: 18,
                                        fontFamily: 'Lato'),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top:
                                                10.0), // Adjust padding if needed
                                        child: Icon(
                                          Icons
                                              .brightness_1, // You can use any icon you prefer for the bullet
                                          size: 8, // Small size for the bullet
                                          color: Colors
                                              .black, // Adjust color if necessary
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'EST. ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' ${rawJobData['data']['currency']} ${widget.jobData['salary']} ${rawJobData['data']['payFrequency']}',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(
                                                  0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ])),
                                      )
                                    ],
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Valid till: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        fontSize: 18,
                                        fontFamily: 'Lato'),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top:
                                                8.0), // Adjust padding if needed
                                        child: Icon(
                                          Icons
                                              .calendar_month, // You can use any icon you prefer for the bullet
                                          size: 12, // Small size for the bullet
                                          color: Colors
                                              .black, // Adjust color if necessary
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
  child: RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: checkExpiry(widget.jobData['dueDate'] ?? '1990-01-01') 
              ? 'Expired' 
              : formatDate(widget.jobData['dueDate'] ?? '1990-01-01'),
          style: TextStyle(
            height: 1.5,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff333333), // Ensure color is set
          ),
        ),
      ],
    ),
  ),
)

                                    ],
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),

                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (!checkExpiry(
                                                widget.jobData['dueDate'])) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          JobApply(
                                                            jobData:
                                                                widget.jobData,
                                                          )));
                                            }
                                          },
                                          child: Container(
                                            width: ((MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                    2) -
                                                30,
                                            height: 44,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                color: checkExpiry(
                                                        widget.jobData[
                                                                'dueDate'] ??
                                                            '01-01-1990')
                                                    ? Colors.redAccent
                                                    : AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Text(
                                                checkExpiry(widget.jobData[
                                                            'dueDate'] ??
                                                        '01-01-1990')
                                                    ? 'Expired'
                                                    : 'Apply',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            //_shareApp();
                                            checkExpiry(
                                                    widget.jobData['dueDate'] ??
                                                        '1990-01-01')
                                                ?

                                                // Fluttertoast.showToast(
                                                //     msg: 'Cannot share an expired job !!!',
                                                //     toastLength: Toast.LENGTH_SHORT,
                                                //     gravity: ToastGravity.BOTTOM,
                                                //     timeInSecForIosWeb: 1,
                                                //     backgroundColor: Color(0xff2D2D2D),
                                                //     textColor: Colors.white,
                                                //     fontSize: 16.0)
                                                IconSnackBar.show(
                                                    context,
                                                    label:
                                                        'Cannot share an expired job !!!',
                                                    snackBarType:
                                                        SnackBarType.alert,
                                                    backgroundColor:
                                                        Color(0xff2D2D2D),
                                                    iconColor: Colors.white,
                                                  )
                                                : getRefCode(widget.isFromSaved
                                                    ? widget.jobData['jobId']
                                                    : widget.jobData['id']);
                                          },
                                          child: Container(
                                            width: ((MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                    2) -
                                                30,
                                            height: 44,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        AppColors.primaryColor),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                              child: Text(
                                                'Refer',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('no_internet_ic.svg'),
                          Text(
                            'No Internet connection',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Connect to Wi-Fi or cellular data and try again.',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff545454)),
                          ),
                          SizedBox(height: 30),
                          InkWell(
                            onTap: () {
                              getJobData();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 50,
                              height: 44,
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    print(widget.jobData);

    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;

      if (widget.isFromSaved) {
        isSaved = true;
      } else {
        isSaved = widget.jobData['isFavorite'] == "1" ?? false;
      }

      getJobData();
    });
  }
}
String formatDate(String dateString) {
  try {
    DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(dateString);
    return DateFormat("dd-MM-yyyy").format(parsedDate);
  } catch (e) {
    return 'Invalid Date'; // Handle invalid input gracefully
  }
}
