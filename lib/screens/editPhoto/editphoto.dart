// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/editPhoto/croppage.dart';
import 'package:talent_turbo_new/screens/editPhoto/discarddiolog.dart';
import 'package:talent_turbo_new/screens/editPhoto/removedialog.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/editPhoto/snack.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class EditPhotoPage extends StatefulWidget {
  const EditPhotoPage({Key? key}) : super(key: key);

  @override
  State<EditPhotoPage> createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool isLoading = false;

  CandidateProfileModel? candidateProfileModel;
  UserData? retrievedUserData;

  // Request permissions for camera and storage
  Future<void> _requestPermissions() async {
    if (await Permission.camera.request().isDenied) {
      return;
    }

    if (await Permission.storage.request().isDenied) {
      return;
    }

    if (await Permission.photos.request().isDenied) {
      return;
    }
  }

  // Open Camera and directly upload the image
  Future<void> _openCamera() async {
    await _requestPermissions(); // Ensure permissions are granted
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final XFile? processedImage = await processResizeImage(image);
      setState(() {
        _imageFile = processedImage;
      });
    }
  }

  // Open Gallery and directly upload the image
  Future<void> _openGallery_() async {
    await _requestPermissions(); // Ensure permissions are granted
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<XFile?> processResizeImage(XFile? image) async {
    if (image == null) return null;

    try {
      // Read the image file as bytes
      final imageBytes = await image.readAsBytes();
      // Decode the image
      img.Image? decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) return null;

      // Resize if the image dimensions are greater than 720
      /*if (decodedImage.width > 720 || decodedImage.height > 720) {
        decodedImage = img.copyResize(decodedImage, width: 720, height: 720, interpolation: img.Interpolation.cubic);
      }*/

      if (decodedImage.width > 720 || decodedImage.height > 720) {
        // Calculate the aspect ratio
        double aspectRatio = decodedImage.width / decodedImage.height;

        // Calculate new dimensions while maintaining the aspect ratio
        int newWidth;
        int newHeight;

        if (decodedImage.width > decodedImage.height) {
          // Landscape or square image
          newWidth = 720;
          newHeight = (720 / aspectRatio).round();
        } else {
          // Portrait image
          newHeight = 720;
          newWidth = (720 * aspectRatio).round();
        }

        // Resize the image while preserving the aspect ratio
        decodedImage = img.copyResize(
          decodedImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.cubic,
        );
      }
      // Check if the image is already a JPEG
      String fileExtension = path.extension(image.path).toLowerCase();
      bool isJPEG = fileExtension == '.jpg' || fileExtension == '.jpeg';

      // Get the app's temporary directory to save the image
      final tempDir = await getTemporaryDirectory();
      String jpegPath = path.join(tempDir.path,
          'processed_image${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Encode to JPEG format and save the file
      final jpegBytes =
          img.encodeJpg(decodedImage, quality: 85); // Set JPEG quality to 85
      File jpegFile = await File(jpegPath).writeAsBytes(jpegBytes);

      return XFile(jpegFile.path);
    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  Future<void> _openGallery() async {
    await _requestPermissions();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final mimeType = lookupMimeType(image.path);
      final fileSize = await image.length();

      setState(() {
        isLoading = true;
      });

      if (kDebugMode) {
        print('MIME ${mimeType}');
      }

      if (mimeType == 'image/jpeg' && fileSize <= 5 * 1024 * 1024) {
        // Check if the image dimensions are valid
        bool validDimensions = await _validateImageDimensions(image);

        if (validDimensions) {
          print('Valid Dimensions');
          setState(() {
            _imageFile = image;
          });
        } else {
          // _showError('Image size or dimensions are too large. Select a smaller one');
          print('Non- Valid Dimensions');
          final XFile? processedImage = await processResizeImage(image);
          setState(() {
            _imageFile = processedImage;
          });
        }

        setState(() {
          isLoading = false;
        });
      } else {
        /* String errorMessage = mimeType != 'image/jpeg'
            ? 'Please select a JPEG image.'
            : 'File size must be less than 5 MB.';

        _showError(errorMessage);*/

        final XFile? processedImage = await processResizeImage(image);

        if (processedImage != null) {
          print('Image processed and saved at: ${processedImage.path}');
          setState(() {
            _imageFile = processedImage;
          });
        } else {
          print('Image processing failed.');
          _showError('Image processing failed.');
        }

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> _validateImageDimensions(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    try {
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        const maxDimension = 4000;
        if (decodedImage.width <= maxDimension &&
            decodedImage.height <= maxDimension) {
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      //_showError('Image size is too large.');
    }
    return false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _removeImage() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REMOVE_PHOTO);

    final bodyParams = {
      "id": retrievedUserData!.profileId,
      "type": "Candidate"
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
        // Fluttertoast.showToast(
        //     msg: 'Removed successfully',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Color(0xff2D2D2D),
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: 'Removed successfully',
          snackBarType: SnackBarType.success,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );

        String token = retrievedUserData!.token;
        //Navigator.pop(context);
        fetchCandidateProfileData(retrievedUserData!.profileId, token);
      }
    } catch (e) {
      print(e);
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

    print('id ${retrievedUserData!.profileId.toString()}');
    print('file.path ${file.path}');
    print('filename ${file.path.split('/').last}');

    FormData formData = FormData.fromMap({
      "id": retrievedUserData!.profileId.toString(),
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
        backgroundColor: Color(0xff4CAF50),
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

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          contentPadding: EdgeInsets.fromLTRB(22, 15, 15, 22),
          title: Text(
            'Remove',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff333333)),
          ),
          content: Container(
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Are you sure you want to remove your profile photo?',
                style: TextStyle(
                    height: 1.4,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff333333)),
              )),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                _removeImage();
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Remove',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void showDiscardConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          contentPadding: EdgeInsets.fromLTRB(22, 15, 15, 22),
          title: Text(
            'Discard changes?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff333333)),
          ),
          content: Text(
            'Are you sure you want to discard changes?',
            style: TextStyle(
                height: 1.4,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff333333)),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Discard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xFF001B3E),
        child: Scaffold(
            backgroundColor: Colors.white,
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
                              showDiscardConfirmationDialog(context);
                            },
                          ),
                          InkWell(
                              onTap: () {
                                showDiscardConfirmationDialog(context);

                                // Navigator.pop(context);
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
                        'Edit Photo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      _imageFile != null
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: InkWell(
                                  onTap: () {
                                    if (_imageFile != null) {
                                      File file = File(_imageFile!.path);
                                      uploadImage(file);
                                    } else {
                                      showCustomSnackbar(
                                          context, 'Failed to upload!');
                                    }
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )),
                            )
                          : Container(
                              width: 60,
                            ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 360,
                          width: 360,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: _imageFile != null
                              ? ClipOval(
                                  child: Image.file(File(_imageFile!.path),
                                      fit: BoxFit.cover),
                                )
                              : ClipOval(
                                  child: (candidateProfileModel != null &&
                                          candidateProfileModel!.imagePath !=
                                              null)
                                      ? Image.network(
                                          candidateProfileModel!.imagePath!,
                                          height: 300,
                                          width: 300,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/profile.jfif',
                                          height: 300,
                                          width: 300,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                        ),
                      ),
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
                      const SizedBox(height: 20),
                      _imageFile != null
                          ? Column(
                              children: [
                                const Divider(
                                    thickness: 0.5, color: Color(0xffD9D9D9)),
                                Row(children: [
                                  const SizedBox(width: 30),
                                  const Icon(Icons.crop,
                                      color: Color(0xFF484C52), size: 14),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      if (_imageFile != null) {
                                        final croppedImagePath =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Croppage(
                                                imagePath: _imageFile!.path),
                                          ),
                                        );

                                        if (croppedImagePath != null) {
                                          setState(() {
                                            _imageFile =
                                                XFile(croppedImagePath);
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Please select an image first.")),
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Crop",
                                      style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                  ),
                                ]),
                              ],
                            )
                          : Container(),
                      const Divider(thickness: 0.5, color: Color(0xffD9D9D9)),
                      Row(
                        children: [
                          const SizedBox(width: 30),
                          const Icon(Icons.photo,
                              color: Color(0xFF484C52), size: 14),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 259,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        const Divider(
                                            thickness: 5,
                                            indent: 150,
                                            endIndent: 150,
                                            color: Colors.black),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Upload & take a picture',
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _openCamera();
                                                Navigator.pop(context);
                                              },
                                              child: _buildOptionContainer(
                                                  'assets/images/camera (1).png',
                                                  'Camera'),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                                _openGallery();
                                              },
                                              child: _buildOptionContainer(
                                                  'assets/images/files.png',
                                                  'Gallery'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "File types: png, jpg, jpeg  Max file size: 5MB",
                                          style: GoogleFonts.lato(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff333333)),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              "Change Photo",
                              style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF333333)),
                            ),
                          ),
                        ],
                      ),
                      candidateProfileModel!.imagePath != null
                          ? Column(
                              children: [
                                const Divider(
                                    thickness: 0.5, color: Color(0xffD9D9D9)),
                                Row(
                                  children: [
                                    const SizedBox(width: 30),
                                    const Icon(Icons.delete,
                                        color: Color(0xFF484C52), size: 14),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        showDeleteConfirmationDialog(context);
                                      },
                                      child: Text(
                                        "Remove Photo",
                                        style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff333333)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                      const Divider(thickness: 0.5, color: Color(0xffD9D9D9)),
                    ],
                  ),
                ),
              ],
            )));
  }

  // Helper function to build the option container for Camera/Gallery
  Widget _buildOptionContainer(String assetPath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            width: 143,
            color: const Color(0xFFEEEEEE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(assetPath,
                    height: 26, width: 31, fit: BoxFit.cover),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
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

      print(_candidateProfileModel.imagePath);

      if (loadedCredentials != null) {}
    });
  }
}
