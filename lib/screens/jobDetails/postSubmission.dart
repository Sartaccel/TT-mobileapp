import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/JobDetails.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_status.dart';
import 'package:http/http.dart' as http;

class PostJobApplicationSubmission extends StatefulWidget {
  final dynamic jobData;
  const PostJobApplicationSubmission({super.key, required this.jobData});

  @override
  State<PostJobApplicationSubmission> createState() =>
      _PostJobApplicationSubmissionState();
}

class _PostJobApplicationSubmissionState
    extends State<PostJobApplicationSubmission> {
  UserData? retrievedUserData;
  //ReferralData? referralData;
  CandidateProfileModel? candidateProfileModel;

  String jobSearchTerm = '';
  bool isLoading = true;
  List<dynamic> jobList = [];
  bool isConnectionAvailable = true;

  bool checkExpiry(String dateString) {
    // Parse the date string
    DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Compare the dates
    return (providedDate.isBefore(currentDate));
  }

  Future<void> fetchAllJobs() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.ALL_JOBS_LIST);

    final bodyParams = {
      "jobTitle": jobSearchTerm,
      "jobCode": "",
      "companyName": "",
      "experience": "0"
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
        var resOBJ = jsonDecode(response.body);
        bool status = resOBJ['status'];
        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success') && status == true) {
          final List<dynamic> jsonResponse = (resOBJ['jobList']);
          setState(() {
            jobList = jsonResponse;
          });
        }

        if (kDebugMode) {
          print(jobList.length);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveJob(int jobId, int status) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV);
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV_NEW);

    final bodyParams = {"jobId": jobId, "isSaved": status};

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
        //     msg: status == 1? 'Saved successfully' : 'Removed Successfully',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Color(0xff2D2D2D),
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: status == 1 ? 'Saved successfully' : 'Removed Successfully',
          snackBarType: SnackBarType.success,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        setState(() {
          jobSearchTerm = "";
          fetchAllJobs();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Application',
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
          InkWell(
            onTap: () {
              //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> JobStatus()));
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Image.asset('assets/images/img_tic_success.png'),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application submitted',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                            color: Color(0xff333333)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Your application was sent to the recruiter',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                            color: Color(0xff333333)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'Similar jobs',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff333333)),
              )),
          isLoading
              ? Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!, // Base color for the shimmer
                    highlightColor:
                        Colors.grey[100]!, // Highlight color for the shimmer
                    child: ListView.builder(
                      itemCount: 5, // Number of skeleton items to show
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.2, color: Colors.grey),
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Shimmer placeholder for job title
                                  Container(
                                    width: 200,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  // Shimmer placeholder for company name
                                  Container(
                                    width: 150,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  // Shimmer placeholder for location
                                  Container(
                                    width: 100,
                                    height: 15,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              // Shimmer placeholder for other widgets (e.g., icons)
                              Container(
                                width: 40,
                                height: 40,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              : jobList.length > 0
                  ? Expanded(
                      child: RefreshIndicator(
                        onRefresh: fetchAllJobs,
                        child: ListView.builder(
                            itemCount: jobList.length,
                            itemBuilder: (context, index) {
                              return jobList[index]['id'] ==
                                      widget.jobData['id']
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.2, color: Colors.grey),
                                          color: Colors.white),
                                      width: MediaQuery.of(context).size.width,
                                      height: 160,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Jobdetails(jobData: jobList[index])));

                                              await Navigator
                                                  .pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Jobdetails(
                                                          jobData:
                                                              jobList[index],
                                                          isFromSaved: false,
                                                        )),
                                                (Route<dynamic> route) => route
                                                    .isFirst, // This will keep Screen 1
                                              );

                                              fetchAllJobs();
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //Image.asset('assets/images/bmw_logo.png', height: 32, width: 32, ),
                                                //jobList[index]['logo'] ? Image.network(jobList[index]['logo'], height: 32, width: 32, ) : Image.asset('assets/images/tt_logo_resized.png', height: 32, width: 32, ),
                                                Image(
                                                  image: jobList[index]
                                                                  ['logo'] !=
                                                              null &&
                                                          jobList[index]['logo']
                                                              .isNotEmpty
                                                      ? NetworkImage(
                                                          jobList[index]
                                                              ['logo'],
                                                        ) as ImageProvider<
                                                          Object>
                                                      : const AssetImage(
                                                          'assets/images/tt_logo_resized.png'),
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    // Fallback to asset if network image fails
                                                    return Image.asset(
                                                        'assets/images/tt_logo_resized.png',
                                                        height: 32,
                                                        width: 32);
                                                  },
                                                ),

                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            180,
                                                        child: Flexible(
                                                            fit: FlexFit.loose,
                                                            child: Text(
                                                              jobList[index]
                                                                  ['jobTitle'],
                                                              //"dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddjobList[index]['jobTitle']",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      'Lato',
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff333333)),
                                                            ))),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              155,
                                                      child: Flexible(
                                                        fit: FlexFit.loose,
                                                        child: Text(
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          jobList[index][
                                                                  'companyName']
                                                              .toString()
                                                              .trim(),
                                                          //"jobList[index]['companyName'].toString().trim()jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj" ,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'Lato',
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xff545454)),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              155,
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/images/ic_idea.svg',
                                                            height: 14,
                                                            width: 14,
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          //Text('Skills : Interaction Design · User Research +5', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xff545454)),),
                                                          Flexible(
                                                              fit:
                                                                  FlexFit.loose,
                                                              child: Text(
                                                                'Skills : ${jobList[index]['skillSet']}',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xff545454)),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              'assets/images/ic_suitcase.svg',
                                                              height: 14,
                                                              width: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              jobList[index]
                                                                  ['workType'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xff545454)),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              255,
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/ic_location.svg',
                                                                height: 14,
                                                                width: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              //Text(jobList[index]['location'], overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xff545454)),),
                                                              Flexible(
                                                                fit: FlexFit
                                                                    .loose,
                                                                child: Text(
                                                                  jobList[index]
                                                                          [
                                                                          'location'] ??
                                                                      'N/A',
                                                                  //"kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xff545454),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      checkExpiry(jobList[index]
                                                                  ['dueDate'] ??
                                                              '1990-01-01')
                                                          ? 'Expired'
                                                          : processDate(jobList[
                                                                      index][
                                                                  'createdDate'] ??
                                                              '2024-10-27'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: checkExpiry(jobList[
                                                                          index]
                                                                      [
                                                                      'dueDate'] ??
                                                                  '1990-01-01')
                                                              ? const Color(
                                                                  0xffBA1A1A)
                                                              : Color(
                                                                  0xff545454)),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                              onTap: () {
                                                //saveJob(jobList[index]['id'], jobList[index]['isSaved'] ? 0 : 1);

                                                bool isSaved = jobList[index]
                                                        ['isSaved'] ??
                                                    false;

                                                if (kDebugMode) {
                                                  print('Status: ${isSaved}');
                                                }
                                                saveJob(jobList[index]['id'],
                                                    isSaved ? 0 : 1);
                                                /* saveJob(
                                        jobList[index]['id'],
                                        (jobList[index]['isSaved'] ?? 0) == 1 ? 0 : 1
                                    );*/
                                                      },
                                              child: Icon(
                                                (jobList[index]['isFavorite'] ??
                                                            "0") ==
                                                        "1"
                                                    ? Icons.bookmark
                                                    : Icons
                                                        .bookmark_border_rounded,
                                                size: 25,
                                              ))
                                        ],
                                      ),
                                    );
                            }),
                      ),
                    )
                  : isConnectionAvailable
                      ? SizedBox(
                          height: 500,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Text(
                                'No results found for ${jobSearchTerm}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
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
                                  fetchAllJobs();
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
    fetchUserDataFromPref();
    if (kDebugMode) {
      print(retrievedUserData?.email);
    }
  }

  Future<void> fetchUserDataFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    //ReferralData? _referralData = await getReferralProfileData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();

    setState(() {
      retrievedUserData = _retrievedUserData;
      candidateProfileModel = _candidateProfileModel;
      //referralData = _referralData;
      //print(retrievedUserData?.email);
      jobSearchTerm =
          (widget.jobData['jobTitle'] ?? '').toString().split(' ')[0];

      fetchAllJobs();
    });
  }
}
