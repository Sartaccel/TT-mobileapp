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
import 'package:intl/intl.dart';
import 'package:talent_turbo_new/screens/jobDetails/JobDetails.dart';

class SavedJobsFragment extends StatefulWidget {
  const SavedJobsFragment({super.key});

  @override
  State<SavedJobsFragment> createState() => _SavedJobsFragmentState();
}

class _SavedJobsFragmentState extends State<SavedJobsFragment> {
  bool isLoading = false;
  ReferralData? referralData;
  CandidateProfileModel? candidateProfileModel;

  UserData? retrievedUserData;

  List<dynamic> jobList = [];
  bool isConnectionAvailable = true;

  Future<void> getAppliedJobsList() async {
    final url =
        // Uri.parse(AppConstants.BASE_URL + AppConstants.SAVED_JOBS_LISTS_GET);
        Uri.parse(AppConstants.BASE_URL + AppConstants.GET_FAV_NEW);

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Authorization': retrievedUserData!.token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        setState(() {
          //jobList = resOBJ['savedJobs'];
          jobList = resOBJ['favJobs'];
        });

        setState(() {
          isLoading = false;
        });

        if (kDebugMode) {
          print('jobList : ${jobList.length}');
        }
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

  bool checkExpiry(String dateString) {
    // Parse the date string
    DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Compare the dates
    return (providedDate.isBefore(currentDate));
  }

  Future<void> removeJob(int jobId) async {
  if (retrievedUserData == null) {
    if (kDebugMode) print("Error: User data is null.");
    return;
  }

  // Check internet connection before making the API call
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    if (mounted) {
      IconSnackBar.show(
        context,
        label: 'No internet connection',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    }
    return; // Exit function if no internet
  }

  final url = Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV_NEW);
  final bodyParams = {"jobId": jobId, "isFavorite": 0};

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': retrievedUserData!.token
      },
      body: jsonEncode(bodyParams),
    );

    if (kDebugMode) {
      print('Response code ${response.statusCode} :: Response => ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 202) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'Removed successfully',
          snackBarType: SnackBarType.success,
          backgroundColor: Colors.green,
          iconColor: Colors.white,
        );
      }
      // Optionally refresh job list
      // getAppliedJobsList();
    } else {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'Failed to remove. Please try again.',
          snackBarType: SnackBarType.fail,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
      }
    }
  } catch (e) {
    if (kDebugMode) print("Error: $e");

    if (mounted) {
      IconSnackBar.show(
        context,
        label: 'Network error. Please try again.',
        snackBarType: SnackBarType.fail,
        backgroundColor: Colors.red,
        iconColor: Colors.white,
      );
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
          highlightColor: Colors.grey[100]!, // Highlight color for the shimmer
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
    : (jobList.length > 0
            ? RefreshIndicator(
                onRefresh: getAppliedJobsList,
                child: ListView.builder(
                    itemCount: jobList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Jobdetails(
                                        jobData: jobList[index],
                                        isFromSaved: true,
                                      )));

                          getAppliedJobsList();
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
                                height: 40,
                                width: 40,
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
                                        jobList[index]['jobTitle'] ?? 'NA',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Lato',
                                            fontSize: 16,
                                            color: Color(0xff333333)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    jobList[index]['companyName'] ?? 'N/A',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Lato',
                                        fontSize: 13,
                                        color: Color(0xff545454)),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 120,
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
                                              'Skills : ${jobList[index]['skills']}',
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
                                            jobList[index]['workType'] ?? 'N/A',
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
                                        width:
                                            MediaQuery.of(context).size.width -
                                                255,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/ic_location.svg',
                                              height: 14,
                                              width: 14,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            //Text(jobList[index]['location'], overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xff545454)),),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Text(
                                                jobList[index]['location'] ??
                                                    'N/A',
                                                //"kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: Color(0xff545454),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
                                  Container(
                                    height: 24,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    //decoration: BoxDecoration(color: checkExpiry(jobList[index]['job']['dueDate'] ) ? Color(0xffFBE2E0) : Color(0xffE0EDFB), borderRadius: BorderRadius.circular(3)),
                                    decoration: BoxDecoration(
                                      color: checkExpiry(jobList[index]
                                                  ['dueDate'] ??
                                              '1990-01-01')
                                          ? const Color(0xffFBE2E0)
                                          : const Color.fromARGB(
                                              255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child:
                                        //Text(checkExpiry(jobList[index]['job']['dueDate']) ? "Expired" : "Expires ${jobList[index]['job']['dueDate']}" , style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: checkExpiry(jobList[index]['job']['dueDate']) ? Color(0xffBA1A1A) : Color(0xff004C99)),)
                                        Text(
                                      checkExpiry(jobList[index]['dueDate'] ??
                                              '1990-01-01')
                                          ? 'Expired'
                                          : processDate(jobList[index]
                                                  ['jobCreatedDate'] ??
                                              '1990-01-01'), // Formatting createdDate
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: checkExpiry(jobList[index]
                                                    ['dueDate'] ??
                                                '1990-01-01')
                                            ? const Color(
                                                0xffBA1A1A) // Expired color
                                            : const Color(
                                                0xff545454), // Active/Default color
                                      ),
                                    ),
                                  )
                                ],
                              ),
                             InkWell(
  onTap: () {
    var jobData = jobList[index]; // Get job data safely
    int? jobId = jobData.containsKey('jobId') ? jobData['jobId'] : jobData['id']; // Try alternative keys

    if (jobId == null) {
      if (kDebugMode) print("Error: jobId is null at index $index. Job Data: $jobData");
      return; // Exit function
    }

    // Remove from UI instantly
    setState(() {
      jobList.removeAt(index);
    });

    // Call API to remove job
    removeJob(jobId);
  },
  child: Icon(
    Icons.bookmark,
    size: 25,
  ),
),




                            ],
                          ),
                        ),
                      );
                    }),
              )
            : isConnectionAvailable
                ? Center(
                    child: Text('No data to show here.'),
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
                                borderRadius: BorderRadius.circular(8)),
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
