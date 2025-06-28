import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/docx_viewer.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/postSubmission.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class JobApply extends StatefulWidget {
  final dynamic jobData;
  const JobApply({super.key, required this.jobData});

  @override
  State<JobApply> createState() => _JobApplyState();
}

class _JobApplyState extends State<JobApply> {
  double uploadProgress = 0.0;
  bool isUploading = false;
  bool isLoading = false;
  final databaseRef =
      FirebaseDatabase.instance.ref().child(AppConstants.APP_NAME);

  ReferralData? referralData;
  UserData? retrievedUserData;
  CandidateProfileModel? candidateProfileModel;

  String email = '';
  String resumeUpdatedDate = '';

  bool _isEmailValid = true;
  TextEditingController emailController = TextEditingController();
  String emailErrorMessage = 'Email is required';

  bool _isResumeValid = true;
  String resumeErrorMsg = 'Upload your resume first';

  String? _selectedCountryCode = '+91';
  bool _isMobileNumberValid = true;
  String mobileErrorMsg = 'Mobile number is required';
  TextEditingController mobileController = TextEditingController();

  File? selectedFile;

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();

    setState(() {
      referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;

      email = _retrievedUserData?.email ?? "N/A";
      emailController.text = _candidateProfileModel?.email ?? "";

      String? mobileNumber = _candidateProfileModel?.mobile;
      if (mobileNumber != null && mobileNumber.length > 3) {
        mobileController.text = mobileNumber.substring(3);
      } else {
        mobileController.text = "";
      }

      fetchAndFormatUpdatedTime();
    });
  }

  Future<void> setUpdatedTimeInRTDB() async {
    try {
      final String sanitizedEmail = email.replaceAll('.', ',');
      final DatabaseReference resumeUpdatedRef =
          databaseRef.child('$sanitizedEmail/resumeUpdated');
      await resumeUpdatedRef.set(DateTime.now().toIso8601String());
    } catch (e) {
      print('Failed to update resume time: $e');
    }
  }

  Future<void> fetchAndFormatUpdatedTime() async {
    try {
      final String sanitizedEmail = email.replaceAll('.', ',');
      final DatabaseReference resumeUpdatedRef =
          databaseRef.child('$sanitizedEmail/resumeUpdated');

      final DataSnapshot snapshot = await resumeUpdatedRef.get();
      if (snapshot.exists) {
        String isoDateString = snapshot.value as String;
        DateTime dateTime = DateTime.parse(isoDateString);
        String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
        setState(() {
          resumeUpdatedDate = formattedDate;
        });
      }
    } catch (e) {
      print('Error fetching timestamp: $e');
    }
  }

  Future<void> applyJob() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.APPLY_JOB);
    final bodyParams = {
      "jobId": widget.jobData['id'],
      "candidateId": candidateProfileModel!.id.toString()
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

      if (response.statusCode >= 200 && response.statusCode < 210) {
        var resOBJ = jsonDecode(response.body);
        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PostJobApplicationSubmission(jobData: widget.jobData),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (Route<dynamic> route) => route.isFirst,
          );
        }
      } else {
        var resOBJ = jsonDecode(response.body);
        String statusMessage =
            resOBJ['message'] ?? 'An unknown error occurred.';
        IconSnackBar.show(
          context,
          label: statusMessage,
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: "No internet connection, try again",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final String? filePath = candidateProfileModel?.filePath;
    if (filePath != null && await canLaunchUrl(Uri.parse(filePath))) {
      await launchUrl(Uri.parse(filePath));
    } else {
      IconSnackBar.show(
        context,
        label: 'Could not launch ${filePath}',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);
        if (resOBJ['message'].toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          CandidateProfileModel candidateData =
              CandidateProfileModel.fromJson(data);
          await saveCandidateProfileData(candidateData);
          setState(() {
            candidateProfileModel = candidateData;
          });
          fetchAndFormatUpdatedTime();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool _isValidExtension(String extension) {
    const allowedExtensions = ['pdf', 'doc', 'docx'];
    return allowedExtensions.contains(extension);
  }

  Future<File?> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String extension = file.path.split('.').last.toLowerCase();

      if (!_isValidExtension(extension)) {
        IconSnackBar.show(
          context,
          label: 'Unsupported file type.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return null;
      }

      final fileSize = await file.length();
      if (fileSize <= 0) {
        IconSnackBar.show(
          context,
          label: 'File must be greater than 0MB.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return null;
      } else if (fileSize > 5 * 1024 * 1024) {
        IconSnackBar.show(
          context,
          label: 'File must be less than 5MB.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return null;
      }

      return file;
    }
    return null;
  }

  Future<void> uploadPDF(File file) async {
    Dio dio = Dio();
    String url =
        'https://mobileapi.talentturbo.us/api/v1/resumeresource/uploadresume';

    FormData formData = FormData.fromMap({
      "id": retrievedUserData!.profileId.toString(),
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    String token = retrievedUserData!.token;
    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
      });

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (int sent, int total) {
          setState(() {
            uploadProgress = sent / total;
          });
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        await setUpdatedTimeInRTDB();
        // IconSnackBar.show(
        //   context,
        //   label: 'Successfully uploaded',
        //   snackBarType: SnackBarType.success,
        //   backgroundColor: Color(0xff4CAF50),
        //   iconColor: Colors.white,
        // );
        await fetchCandidateProfileData(retrievedUserData!.profileId, token);
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: e.toString(),
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    } finally {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });
    }
  }

  Future<void> pickAndUploadPDF() async {
    File? file = await pickPDF();
    if (file != null) {
      setState(() {
        selectedFile = file;
        isUploading = true;
      });
      await uploadPDF(file);
    }
  }

  void _showResumeOptions() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xffFCFCFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                if (candidateProfileModel?.filePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocViewerPage(
                        url: candidateProfileModel!.filePath!,
                      ),
                    ),
                  );
                }
              },
              leading: SvgPicture.asset("assets/images/view.svg"),
              title: Text(
                'View Resume',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                pickAndUploadPDF();
              },
              leading: SvgPicture.asset("assets/images/replace.svg"),
              title: Text(
                'Replace Resume',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _launchURL();
              },
              leading: SvgPicture.asset("assets/images/download.svg"),
              title: Text(
                'Download',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadInProgress() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFAFCFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  'assets/images/curriculum.png',
                  width: 55,
                  height: 55,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFile != null
                        ? selectedFile!.path.split('/').last
                        : 'Uploading...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                      color: Color(0xff004C99),
                    ),
                  ),
                  Text(
                    'Uploading file: ${(uploadProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Color(0xff545454),
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 27,
            width: 27,
            child: CircularProgressIndicator(
              value: uploadProgress,
              color: Color(0xff004C99),
              backgroundColor: Color(0xffC8D9EB),
              strokeWidth: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadInitial() {
    return InkWell(
      onTap: pickAndUploadPDF,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFAFCFF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload file',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Color(0xff004C99),
                  ),
                ),
                Text(
                  'File types: pdf, docx  Max file size: 5MB',
                  style: TextStyle(
                    color: Color(0xff545454),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              'assets/images/mage_upload.svg',
              width: 30,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedResume() {
    return InkWell(
      onTap: _showResumeOptions,
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xafFAFCFF),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/ic_curriculum.png',
                  width: 50,
                  height: 55,
                ),
                SizedBox(width: 10),
                Container(
                  width: MediaQuery.of(context).size.width - 190,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          candidateProfileModel!.fileName ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff004C99),
                            fontSize: 14,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Last upload $resumeUpdatedDate',
                        style: TextStyle(
                          color: Color(0xff545454),
                          fontSize: 12,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 56,
              child: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon/moreDot.svg'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Back',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
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
                SizedBox(width: 80),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Image(
                              image: widget.jobData['logo'] != null &&
                                      widget.jobData['logo'].isNotEmpty
                                  ? NetworkImage(widget.jobData['logo'])
                                      as ImageProvider<Object>
                                  : AssetImage(
                                      'assets/images/tt_logo_resized.png'),
                              height: 60,
                              width: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                    'assets/images/tt_logo_resized.png',
                                    height: 60,
                                    width: 60);
                              },
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.70),
                                  child: Text(
                                    widget.jobData['jobTitle'] ??
                                        'Default Title',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                      fontSize: 20,
                                      color: Color(0xff333333),
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.jobData['companyName'] ?? '',
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
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      color: Color(0xffE6E6E6),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Confirm your application',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          color: Color(0xff333333)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This will let the recruiter contact you.',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          fontFamily: 'Lato',
                          color: Color(0xff333333)),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                      ),
                      child: Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Color(0xff333333)),
                      ),
                    ),
                    SizedBox(height: 7),
                    TextField(
                      readOnly: true,
                      controller: emailController,
                      cursorColor: Color(0xff004C99),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          color: Color(0xff333333)),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Color(0xff545454)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xffd9d9d9)
                                  : Color(0xffBA1A1A),
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xff004C99)
                                  : Color(0xffBA1A1A),
                              width: 1),
                        ),
                        errorText: _isEmailValid ? null : emailErrorMessage,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                      ),
                      child: Text(
                        'Mobile Number',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Color(0xff333333)),
                      ),
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffD9D9D9)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCountryCode!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Lato',
                                          color: Color(0xFF545454)),
                                    ),
                                    SvgPicture.asset(
                                      'assets/icon/ArrowDown.svg',
                                      height: 10,
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01),
                              Expanded(
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width) - 130,
                                  child: TextField(
                                    readOnly: true,
                                    maxLength: 10,
                                    controller: mobileController,
                                    cursorColor: Color(0xff004C99),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Lato',
                                        color: Color(0xff333333)),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Enter mobile number',
                                      hintStyle:
                                          TextStyle(color: Color(0xff545454)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: _isMobileNumberValid
                                                ? Color(0xffd9d9d9)
                                                : Color(0xffBA1A1A),
                                            width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: _isMobileNumberValid
                                                ? Color(0xff004C99)
                                                : Color(0xffBA1A1A),
                                            width: 1),
                                      ),
                                      errorText: _isMobileNumberValid
                                          ? null
                                          : mobileErrorMsg,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                      ),
                      child: Text(
                        'Resume',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          color: _isResumeValid
                              ? Color(0xff333333)
                              : Color(0xffBA1A1A),
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    DottedBorder(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFAFCFF),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isUploading)
                              _buildUploadInProgress()
                            else if ((candidateProfileModel?.fileName ?? '')
                                .isEmpty)
                              _buildUploadInitial()
                            else
                              _buildUploadedResume(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    if (!_isResumeValid)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          resumeErrorMsg,
                          style: TextStyle(
                            color: Color(0xffBA1A1A),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(height: 45),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isResumeValid =
                              candidateProfileModel?.fileName?.isNotEmpty ??
                                  false;

                          if (_isResumeValid) {
                            applyJob();
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Apply',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
