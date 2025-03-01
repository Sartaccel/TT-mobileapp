import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/docx_viewer.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/companyDetails.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/jobDetails/postSubmission.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class JobApply extends StatefulWidget {
  final dynamic jobData;
  const JobApply({super.key, required this.jobData});

  @override
  State<JobApply> createState() => _JobApplyState();
}

class _JobApplyState extends State<JobApply> {
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
  String emailErrorMessage = 'Email cannot be empty';

  String? _selectedCountryCode = '+91';
  //final List<String> countryOptions = ['+91', '+1', '+2'];
  final List<String> countryOptions = [
    '+1', // USA, Canada, etc.
    '+7', // Russia, Kazakhstan
    '+20', // Egypt
    '+27', // South Africa
    '+30', // Greece
    '+31', // Netherlands
    '+32', // Belgium
    '+33', // France
    '+34', // Spain
    '+36', // Hungary
    '+39', // Italy
    '+40', // Romania
    '+41', // Switzerland
    '+43', // Austria
    '+44', // UK
    '+45', // Denmark
    '+46', // Sweden
    '+47', // Norway
    '+48', // Poland
    '+49', // Germany
    '+51', // Peru
    '+52', // Mexico
    '+53', // Cuba
    '+54', // Argentina
    '+55', // Brazil
    '+56', // Chile
    '+57', // Colombia
    '+58', // Venezuela
    '+60', // Malaysia
    '+61', // Australia
    '+62', // Indonesia
    '+63', // Philippines
    '+64', // New Zealand
    '+65', // Singapore
    '+66', // Thailand
    '+81', // Japan
    '+82', // South Korea
    '+84', // Vietnam
    '+86', // China
    '+90', // Turkey
    '+91', // India
    '+92', // Pakistan
    '+93', // Afghanistan
    '+94', // Sri Lanka
    '+95', // Myanmar
    '+98', // Iran
    '+211', // South Sudan
    '+212', // Morocco
    '+213', // Algeria
    '+216', // Tunisia
    '+218', // Libya
    '+220', // Gambia
    '+221', // Senegal
    '+222', // Mauritania
    '+223', // Mali
    '+224', // Guinea
    '+225', // Ivory Coast
    '+226', // Burkina Faso
    '+227', // Niger
    '+228', // Togo
    '+229', // Benin
    '+230', // Mauritius
    '+231', // Liberia
    '+232', // Sierra Leone
    '+233', // Ghana
    '+234', // Nigeria
    '+235', // Chad
    '+236', // Central African Republic
    '+237', // Cameroon
    '+238', // Cape Verde
    '+239', // São Tomé and Príncipe
    '+240', // Equatorial Guinea
    '+241', // Gabon
    '+242', // Republic of the Congo
    '+243', // Democratic Republic of the Congo
    '+244', // Angola
    '+245', // Guinea-Bissau
    '+248', // Seychelles
    '+249', // Sudan
    '+250', // Rwanda
    '+251', // Ethiopia
    '+252', // Somalia
    '+253', // Djibouti
    '+254', // Kenya
    '+255', // Tanzania
    '+256', // Uganda
    '+257', // Burundi
    '+258', // Mozambique
    '+260', // Zambia
    '+261', // Madagascar
    '+262', // Réunion/Mayotte
    '+263', // Zimbabwe
    '+264', // Namibia
    '+265', // Malawi
    '+266', // Lesotho
    '+267', // Botswana
    '+268', // Eswatini (Swaziland)
    '+269', // Comoros
    '+290', // Saint Helena
    '+291', // Eritrea
    '+297', // Aruba
    '+298', // Faroe Islands
    '+299', // Greenland
    '+350', // Gibraltar
    '+351', // Portugal
    '+352', // Luxembourg
    '+353', // Ireland
    '+354', // Iceland
    '+355', // Albania
    '+356', // Malta
    '+357', // Cyprus
    '+358', // Finland
    '+359', // Bulgaria
    '+370', // Lithuania
    '+371', // Latvia
    '+372', // Estonia
    '+373', // Moldova
    '+374', // Armenia
    '+375', // Belarus
    '+376', // Andorra
    '+377', // Monaco
    '+378', // San Marino
    '+379', // Vatican City
    '+380', // Ukraine
    '+381', // Serbia
    '+382', // Montenegro
    '+383', // Kosovo
    '+385', // Croatia
    '+386', // Slovenia
    '+387', // Bosnia and Herzegovina
    '+389', // North Macedonia
    '+420', // Czech Republic
    '+421', // Slovakia
    '+423', // Liechtenstein
    '+500', // Falkland Islands
    '+501', // Belize
    '+502', // Guatemala
    '+503', // El Salvador
    '+504', // Honduras
    '+505', // Nicaragua
    '+506', // Costa Rica
    '+507', // Panama
    '+508', // Saint Pierre and Miquelon
    '+509', // Haiti
    '+590', // Guadeloupe/Martinique
    '+591', // Bolivia
    '+592', // Guyana
    '+593', // Ecuador
    '+594', // French Guiana
    '+595', // Paraguay
    '+596', // Martinique
    '+597', // Suriname
    '+598', // Uruguay
    '+599', // Curaçao/Bonaire
    '+670', // Timor-Leste
    '+672', // Norfolk Island
    '+673', // Brunei
    '+674', // Nauru
    '+675', // Papua New Guinea
    '+676', // Tonga
    '+677', // Solomon Islands
    '+678', // Vanuatu
    '+679', // Fiji
    '+680', // Palau
    '+681', // Wallis and Futuna
    '+682', // Cook Islands
    '+683', // Niue
    '+685', // Samoa
    '+686', // Kiribati
    '+687', // New Caledonia
    '+688', // Tuvalu
    '+689', // French Polynesia
    '+690', // Tokelau
    '+691', // Micronesia
    '+692', // Marshall Islands
    '+850', // North Korea
    '+852', // Hong Kong
    '+853', // Macau
    '+855', // Cambodia
    '+856', // Laos
    '+880', // Bangladesh
    '+886', // Taiwan
    '+960', // Maldives
    '+961', // Lebanon
    '+962', // Jordan
    '+963', // Syria
    '+964', // Iraq
    '+965', // Kuwait
    '+966', // Saudi Arabia
    '+967', // Yemen
    '+968', // Oman
    '+970', // Palestine
    '+971', // UAE
    '+972', // Israel
    '+973', // Bahrain
    '+974', // Qatar
    '+975', // Bhutan
    '+976', // Mongolia
    '+977', // Nepal
    '+992', // Tajikistan
    '+993', // Turkmenistan
    '+994', // Azerbaijan
    '+995', // Georgia
    '+996', // Kyrgyzstan
    '+998', // Uzbekistan
  ];
  bool _isMobileNumberValid = true;
  String mobileErrorMsg = 'Mobile number cannot be empty';
  TextEditingController mobileController = TextEditingController();

  Future<void> setUpdatedTimeInRTDB() async {
    try {
      final String sanitizedEmail = email.replaceAll('.', ',');

      final DatabaseReference resumeUpdatedRef =
          databaseRef.child('$sanitizedEmail/resumeUpdated');

      await resumeUpdatedRef.set(DateTime.now().toIso8601String());

      print('Resume updated time set successfully.');
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

        print('Formatted Date: $formattedDate');
      } else {
        print('No timestamp found in the database.');
      }
    } catch (e) {
      print('Error fetching or formatting timestamp: $e');
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

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 210) {
        var resOBJ = jsonDecode(response.body);
        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          // Fluttertoast.showToast(
          //   msg: statusMessage,
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.green,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );
          // Navigate to the next screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PostJobApplicationSubmission(jobData: widget.jobData),
            ),
            (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );
        }
      } else {
        var resOBJ = jsonDecode(response.body);
        String statusMessage =
            resOBJ['message'] ?? 'An unknown error occurred.';

        // Show backend error message or a default message
        // Fluttertoast.showToast(
        //   msg: statusMessage,
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: statusMessage,
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      // Handle network or unexpected errors
      // Fluttertoast.showToast(
      //   msg: "Network error. Please try again later.",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.red,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
      IconSnackBar.show(
        context,
        label: "Network error, try again later.",
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xffBA1A1A),
        iconColor: Colors.white,
      );
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      // Ensure isLoading is set to false after the request completes
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final String? filePath = candidateProfileModel?.filePath;

    if (filePath != null && await canLaunchUrl(Uri.parse(filePath))) {
      //await launchUrlString(filePath, mode: LaunchMode.externalApplication);
      await launchUrl(Uri.parse(filePath));
      //await launch(filePath, forceSafariVC: false, forceWebView: false);
    } else {
      // Fluttertoast.showToast(
      //     msg: 'Could not launch ${filePath}',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0xff2D2D2D),
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      IconSnackBar.show(
        context,
        label: 'Could not launch ${filePath}',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      throw 'Could not launch ${candidateProfileModel!.filePath}';
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          // Fluttertoast.showToast(
          //     msg: 'Fetching updated profile...',
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Color(0xff2D2D2D),
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: 'Fetching updated profile...',
            snackBarType: SnackBarType.alert,
            backgroundColor: Color(0xff2D2D2D),
            iconColor: Colors.white,
          );

          final Map<String, dynamic> data = resOBJ['data'];
          //ReferralData referralData = ReferralData.fromJson(data);
          CandidateProfileModel candidateData =
              CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);

          /*Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PersonalDetails()),
                (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );*/

          //Navigator.pop(context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print(response);
        setState(() {
          isLoading = false;
        });
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
      //allowedExtensions: ['pdf'],
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      String extension = file.path.split('.').last.toLowerCase();
      if (!_isValidExtension(extension)) {
        // Fluttertoast.showToast(
        //     msg: 'Unsupported file type.',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Color(0xff2D2D2D),
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: 'Unsupported file type.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );

        return null;
      }

      final fileSize = await file.length(); // Get file size in bytes
      if (fileSize <= 0) {
        // Fluttertoast.showToast(
        //   msg: 'File must be greater than 0MB.',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Color(0xff2D2D2D),
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: 'File must be greater than 0MB.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return null;
      } else if (fileSize > 5 * 1024 * 1024) {
        // 5MB in bytes
        // Fluttertoast.showToast(
        //   msg: 'File must be less than 5MB.',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Color(0xff2D2D2D),
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
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

  Future<File?> pickPDF_() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    }

    return null;
  }

  File? selectedFile;

  Future<void> uploadPDF(File file) async {
  Dio dio = Dio();

  String url =
      'https://mobileapi.talentturbo.us/api/v1/resumeresource/uploadresume';

  // Prepare the form data for the file upload
  FormData formData = FormData.fromMap({
    "id": retrievedUserData!.profileId.toString(), // Your id
    "file": await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  String token = retrievedUserData!.token;
  try {
    setState(() {
      isLoading = true;
    });

    // Sending the request to upload the file
    Response response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': token, // Authorization Header
          'Content-Type': 'multipart/form-data', // Content-Type for file uploads
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Upload success: ${response.statusCode}');
      setUpdatedTimeInRTDB();
      
      // Success feedback using Snackbar
      IconSnackBar.show(
        context,
        label: 'Successfully uploaded',
        snackBarType: SnackBarType.success,
        backgroundColor: Color(0xff4CAF50),
        iconColor: Colors.white,
      );
      
      fetchCandidateProfileData(retrievedUserData!.profileId, token);
    } else {
      // Handle case where upload wasn't successful
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    print('Upload failed: $e');
    
    // Error feedback using Snackbar
    IconSnackBar.show(
      context,
      label: e.toString(),
      snackBarType: SnackBarType.alert,
      backgroundColor: Color(0xff2D2D2D),
      iconColor: Colors.white,
    );
  }
}

Future<void> pickAndUploadPDF() async {
  // Pick a file
  File? file = await pickPDF();
  if (file != null) {
    setState(() {
      selectedFile = file;
    });

    // Upload the file
    await uploadPDF(file);
  } else {
    // Provide feedback if no file was selected
    IconSnackBar.show(
      context,
      label: 'No file selected',
      snackBarType: SnackBarType.alert,
      backgroundColor: Color(0xff2D2D2D),
      iconColor: Colors.white,
    );
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
          Expanded(
              child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          //Image.asset('assets/images/bmw_logo.png', height: 41, width: 41, ),
                          Image(
                            image: widget.jobData['logo'] != null &&
                                    widget.jobData['logo'].isNotEmpty
                                ? NetworkImage(
                                    widget.jobData['logo'],
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
                                  height: 40,
                                  width: 40);
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Container(
  width: 280, // Example fixed width
  child: Text(
    widget.jobData['jobTitle'] ?? 'Default Title',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'Lato',
      fontSize: 20,
      color: Color(0xff333333),
    ),
  ),
)
,
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                widget.jobData['companyName'] == null
                                    ? ''
                                    : widget.jobData['companyName'],
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

                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                    color: Color(0xffE6E6E6),
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Confirm your application',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Lato',
                        color: Color(0xff333333)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'This will let the recruiter contact you.',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff333333)),
                  ),

                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Email',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        color: Color(0xff333333)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    readOnly: true,
                    controller: emailController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xffd9d9d9)
                                  : Color(0xffBA1A1A), // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xff004C99)
                                  : Color(0xffBA1A1A), // Border color when focused
                              width: 1),
                        ),
                        errorText: _isEmailValid
                            ? null
                            : emailErrorMessage, // Display error message if invalid
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isEmailValid = true;
                      });
                    },
                  ),

                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Mobile Number',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        color: Color(0xff333333)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(4)),
                        padding: EdgeInsets.all(9),
                        child: DropdownButton(
                            underline: Container(),
                            value: _selectedCountryCode,
                            items: countryOptions.map((countryCode) {
                              return DropdownMenuItem(
                                  value: countryCode,
                                  child: Text(countryCode,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Lato',
                                          color: const Color(0xFF333333))));
                            }).toList(),
                            onChanged: (val) {}),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 130,
                        child: TextField(
                          readOnly: true,
                          maxLength: 10,
                          controller: mobileController,
                          cursorColor: Color(0xff004C99),
                          style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                          decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Enter mobile number',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isMobileNumberValid
                                        ? Color(0xffd9d9d9)
                                        : Color(0xffBA1A1A), // Default border color
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isMobileNumberValid
                                        ? Color(0xff004C99)
                                        : Color(0xffBA1A1A), // Border color when focused
                                    width: 1),
                              ),
                              errorText: _isMobileNumberValid
                                  ? null
                                  : mobileErrorMsg, // Display error message if invalid
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            // Validate the email here and update _isEmailValid
                            setState(() {
                              setState(() {
                                _isMobileNumberValid = true;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Resume',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        color: Color(0xff333333)),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 0.3, color: Colors.grey)),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Resume',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                color: Color(0xff333333)),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        candidateProfileModel!.fileName == null
                            ? InkWell(
                                onTap: () {
                                  pickAndUploadPDF();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Upload file',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff004C99)),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                         Container(
  width: MediaQuery.of(context).size.width - 100,
  child: Text(
    'File types: pdf, .doc, .docx  Max file size: 5MB',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    style: TextStyle(
        color: Color(0xff7D7C7C),
        fontSize: 14),
                ),
          )

                                        ],
                                      ),
                                      SvgPicture.asset(
                                          'assets/images/mage_upload.svg')
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () => {
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 10),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              final String? filePath =
                                                  candidateProfileModel
                                                      ?.filePath;
                                              if (filePath != null) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DocViewerPage(
                                                            url: filePath),
                                                  ),
                                                );
                                              }
                                            },
                                            leading:
                                                Icon(Icons.visibility_outlined),
                                            title: Text('View Resume'),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              Navigator.pop(context);
                                              pickAndUploadPDF();
                                            },
                                            leading: Icon(Icons.refresh),
                                            title: Text('Replace Resume'),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              _launchURL();
                                            },
                                            leading: Icon(Icons.download),
                                            title: Text('Download'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Color(0xafFAFCFF)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                              'assets/images/ic_curriculum.png'),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                180,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      '${candidateProfileModel!.fileName}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff004C99),
                                                          fontFamily:
                                                              'NunitoSans',
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    )),
                                                Text(
                                                  'Last updated $resumeUpdatedDate',
                                                  style: TextStyle(
                                                      color: Color(0xff004C99),
                                                      fontFamily: 'NunitoSans',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset('assets/images/ic_more.png')
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  //Loading
                 

                  SizedBox(
                    height: 50,
                  ),
                 InkWell(
  onTap: () {
    if (candidateProfileModel?.fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload your resume before applying.'),
          backgroundColor: Color(0xffBA1A1A),
        ),
      );
    } else {
      applyJob();
    }
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
  child: TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 5),
    duration: Duration(seconds: 2), // Faster rotation (Reduced duration)
    curve: Curves.linear,
    builder: (context, value, child) {
      return Transform.rotate(
        angle: value * 2 * 3.1416, // Full rotation effect
        child: CircularProgressIndicator(
          strokeWidth: 4,
          value: 0.20, // 1/5 of the circle
          backgroundColor: const Color.fromARGB(142, 234, 232, 232), // Grey stroke
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White rotating stroke
        ),
      );
    },
    onEnd: () => {}, // Ensures smooth infinite animation
  ),
) : Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
    ),
  ),
),
],
              ),
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
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();

    setState(() {
      referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;

      email = retrievedUserData!.email;
      emailController.text = _candidateProfileModel!.email!;
      mobileController.text = _candidateProfileModel!.mobile!.substring(3);

      fetchAndFormatUpdatedTime();
    });
  }
}
