import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:shimmer/shimmer.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;

import '../../jobDetails/job_status.dart';

class AppliedJobsFragment extends StatefulWidget {
  const AppliedJobsFragment({super.key});

  @override
  State<AppliedJobsFragment> createState() => _AppliedJobsFragmentState();
}

class _AppliedJobsFragmentState extends State<AppliedJobsFragment> {
  bool isLoading = false;
  ReferralData? referralData;
  CandidateProfileModel? candidateProfileModel;

  UserData? retrievedUserData;

  List<dynamic> jobList = [];
  bool isConnectionAvailable = true;

  Future<void> getAppliedJobsList() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.APPLIED_JOBS_LIST);
    final bodyParams = {
      "jobTitle": '',
      "candidateId": candidateProfileModel!.id.toString(),
      "companyName": ''
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

        setState(() {
          jobList = resOBJ['jobList'];
        });

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return isLoading
        ? SizedBox(
          height: MediaQuery.of(context).size.height,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!, // Base color for the shimmer
              highlightColor:
                  Colors.grey[100]!, // Highlight color for the shimmer
              child: ListView.builder(
                itemCount: 5, // Number of skeleton items to show
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
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
                            const SizedBox(height: 10),
                            // Shimmer placeholder for company name
                            Container(
                              width: 150,
                              height: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
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
        : (jobList.length > 0
            ? RefreshIndicator(
                onRefresh: getAppliedJobsList,
                child: ListView.builder(
                    itemCount: jobList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => JobStatus(
                                        jobData: jobList[index],
                                      )));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.2, color: Colors.grey),
                              color: Colors.white),
                          width: MediaQuery.of(context).size.width,
                          height: 170,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image(
                                image: jobList[index]['logo'] != null &&
                                        jobList[index]['logo'].isNotEmpty
                                    ? NetworkImage(
                                        jobList[index]['logo'],
                                      ) as ImageProvider<Object>
                                    : const AssetImage(
                                        'assets/images/tt_logo_resized.png'),
                                height: 38,
                                width: 38,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          150,
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        jobList[index]['jobTitle'] ?? 'Unknown',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Color(0xff333333)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    jobList[index]['companyName'] ?? 'Unknown',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Lato',
                                        fontSize: 13,
                                        color: Color(0xff545454)),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 110,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_skills.png',
                                          height: 14,
                                          width: 14,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            fit: FlexFit.loose,
                                            child: Text(
                                              'Skills : ${jobList[index]['skills'] ?? 'Unknown'}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: Color(0xff545454)),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/ic_work_type.png',
                                            height: 14,
                                            width: 14,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            jobList[index]['workType'] ??
                                                'Fulltime',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Color(0xff545454)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        width: 150,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/ic_location.png',
                                              height: 14,
                                              width: 14,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  jobList[index]['location'] ??
                                                      'Not disclosed',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color: Color(0xff545454)),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
                                  Container(
                                      height: 20,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 0),
                                      decoration: BoxDecoration(
                                          color: Color(0xffE0EDFB),
                                          borderRadius:
                                              BorderRadius.circular(3)),
                                      child: Text(
                                        jobList[index]['statusName']
                                                .toString()
                                                .isEmpty
                                            ? 'Applied'
                                            : jobList[index]['statusName']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Color(0xff004C99)),
                                      ))
                                ],
                              ),

                              //Icon(Icons.bookmark_border_rounded, size: 25,)
                              SizedBox(
                                width: 25,
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              )
            : isConnectionAvailable
                ? Center(
                    child: Text('No Data'),
                  )
                : Expanded(
                    child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icon/noInternet.svg'),
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
                            getAppliedJobsList();
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
                  )));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    //ReferralData? _referralData = await getReferralProfileData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      //referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;
      getAppliedJobsList();
    });
  }
}
