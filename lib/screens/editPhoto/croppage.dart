import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/editPhoto/discarddiolog.dart';
import 'package:talent_turbo_new/screens/editPhoto/snack.dart';
import 'package:http/http.dart' as http;

class Croppage extends StatefulWidget {
  final String imagePath;

  const Croppage({super.key, required this.imagePath});

  @override
  State<Croppage> createState() => _CroppageState();
}

class _CroppageState extends State<Croppage> {
  File? _croppedImage;
  File? pickedImage;
  bool isLoading = false;

  CandidateProfileModel? candidateProfileModel;
  UserData? retrievedUserData;

  Future<void> _cropImage1() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        compressQuality: 40,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 16));

    if (croppedFile != null) {
      setState(() {
        //_croppedImage = croppedFile;
      });
    }
  }

  Future<void> _cropImage() async {
    try {
      CroppedFile? croppedImg = await ImageCropper()
          .cropImage(sourcePath: widget.imagePath, compressQuality: 40);
      if (croppedImg == null) {
        return null;
      } else {
        setState(() {
          _croppedImage = File(croppedImg.path);
        });
        //return File(croppedImg.path);
      }
    } catch (e) {
      print(e);
    }
    return null;
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
          //     msg: 'Personal details updated successfully',
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Color(0xff2D2D2D),
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: 'Personal details updated successfully',
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
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

          Navigator.pop(context);
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

  Future<void> uploadImage(File file) async {
    Dio dio = Dio();

    String url =
        AppConstants.BASE_URL + AppConstants.UPDATE_CANDIDATE_PROFILE_PICTURE;

    FormData formData = FormData.fromMap({
      "id": retrievedUserData!.profileId.toString(), // Your id
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      "type": "candidate"
    });

    String token = retrievedUserData!.token;
    try {
      setState(() {
        isLoading = true;
      });
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
            // Authorization Header
            'Content-Type': 'multipart/form-data',
            // Content-Type for file uploads
          },
        ),
      );
      print('Upload success: ${response.statusCode}');

      // Fluttertoast.showToast(
      //     msg: 'Successfully uploaded',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0xff2D2D2D),
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      IconSnackBar.show(
        context,
        label: 'Successfully uploaded',
        snackBarType: SnackBarType.success,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );

      fetchCandidateProfileData(retrievedUserData!.profileId, token);
      //Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Upload failed: $e');

      // Fluttertoast.showToast(
      //     msg: e.toString(),
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0xff2D2D2D),
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      IconSnackBar.show(
        context,
        label: e.toString(),
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xFFBA1A1A),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF001B3E),
        toolbarHeight: 90,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_croppedImage != null) {
                //uploadImage(_croppedImage!);
                //showCustomSnackbar(context, 'Profile picture updated !');
                Navigator.pop(context, _croppedImage!.path);
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return DiscardDialog(
                      onDiscard: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.check_sharp, color: Colors.white),
          ),
        ],
        title: Text(
          "Crop",
          style: GoogleFonts.lato(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _croppedImage != null
                ? Image.file(File(_croppedImage!.path),
                    width: 400, height: 400, fit: BoxFit.cover)
                : Image.file(File(widget.imagePath),
                    width: 400, height: 400, fit: BoxFit.cover),
            const SizedBox(height: 20),
            isLoading
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
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
                  )
                : Container(),
            MaterialButton(
              onPressed: _cropImage,
              // Call the crop function
              color: const Color(0xFF004C99),
              // Button color
              textColor: Colors.white,
              // Text color
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              minWidth: 360,
              // Set width
              height: 50,
              // Set height
              child: const Text('Crop'),
            ),
          ],
        ),
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
    //ReferralData? _referralData = await getReferralProfileData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    UserData? _retrievedUserData = await getUserData();

    print('Resume : ${_candidateProfileModel!.fileName}');
    UserCredentials? loadedCredentials =
        await UserCredentials.loadCredentials();

    setState(() {
      //referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;

      if (loadedCredentials != null) {}
    });
  }
}
