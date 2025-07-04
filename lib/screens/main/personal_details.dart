import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/docx_viewer.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/editPhoto/editphoto.dart';
import 'package:talent_turbo_new/screens/main/AddDeleteSkills.dart';
import 'package:talent_turbo_new/screens/main/AddEducation.dart';
import 'package:talent_turbo_new/screens/main/AddEmployment.dart';
import 'package:talent_turbo_new/screens/main/edit_personal_details.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({Key? key}) : super(key: key);

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails>
    with WidgetsBindingObserver {
  double uploadProgress = 0.0;
  bool isUploading = false;
  bool isLoading = false;
  final databaseRef =
      FirebaseDatabase.instance.ref().child(AppConstants.APP_NAME);

  List<String> userSkills = [];
  List<dynamic> educationList = [];
  List<dynamic> workList = [];

  CandidateProfileModel candidateProfileModel = CandidateProfileModel(
      candidateContact: [],
      candidateEducation: [],
      candidateEmployment: [],
      multipleFileData: []);
  UserData? retrievedUserData;

  String email = '';
  String resumeUpdatedDate = '';
  File? selectedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print("App has resumed - refreshing data");
      }
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    try {
      setState(() => isLoading = true);

      final profile = await getCandidateProfileData();
      final userData = await getUserData();
      final credentials = await UserCredentials.loadCredentials();

      setState(() {
        candidateProfileModel = profile ??
            CandidateProfileModel(
              candidateContact: [],
              candidateEducation: [],
              candidateEmployment: [],
              multipleFileData: [],
            );
        retrievedUserData = userData;
        educationList = candidateProfileModel.candidateEducation ?? [];
        workList = candidateProfileModel.candidateEmployment ?? [];

        if (credentials != null) {
          email = credentials.username ?? '';
        } else if (userData != null) {
          email = userData.email ?? '';
        }
      });

      await _fetchAndFormatUpdatedTime();
      await _fetchSkills();
    } catch (e) {
      // _showErrorToast("Failed to load profile");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAndFormatUpdatedTime() async {
    try {
      if (email.isEmpty) return;

      final String sanitizedEmail = email.replaceAll('.', ',');
      final DatabaseReference resumeUpdatedRef =
          databaseRef.child('$sanitizedEmail/resumeUpdated');

      final DataSnapshot snapshot = await resumeUpdatedRef.get();
      if (snapshot.exists && snapshot.value != null) {
        String isoDateString = snapshot.value as String;
        DateTime dateTime = DateTime.parse(isoDateString);
        setState(() {
          resumeUpdatedDate = DateFormat('dd-MM-yyyy').format(dateTime);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching timestamp: $e');
      }
    }
  }

  Future<void> _fetchSkills() async {
    try {
      if (email.isEmpty) return;

      final String sanitizedEmail = email.replaceAll('.', ',');
      final DatabaseReference skillRef =
          databaseRef.child('$sanitizedEmail/mySkills');

      skillRef.onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            userSkills = data.values.cast<String>().toList();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching skills: $e');
      }
    }
  }

  Future<void> _deleteEducation(String id) async {
    try {
      if (retrievedUserData == null) return;

      setState(() => isLoading = true);
      final url = Uri.parse(
          AppConstants.BASE_URL + AppConstants.DELETE_EDUCATION + '/$id');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token ?? ''
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        // _showSuccessToast('Education deleted successfully');
        await _fetchCandidateProfileData();
      } else {
        throw Exception('Failed to delete education');
      }
    } catch (e) {
      // _showErrorToast('Failed to delete education');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteEmployment(String id) async {
    try {
      if (retrievedUserData == null) return;

      setState(() => isLoading = true);
      final url = Uri.parse(
          AppConstants.BASE_URL + AppConstants.DELETE_EMPLOYMENT + '/$id');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token ?? ''
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        // _showSuccessToast('Experience deleted successfully');
        await _fetchCandidateProfileData();
      } else {
        throw Exception('Failed to delete employment');
      }
    } catch (e) {
      // _showErrorToast('Failed to delete experience');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteResume(int id) async {
    try {
      setState(() {
        isLoading = true;
        isUploading = false;
        selectedFile = null;
      });

      if (retrievedUserData == null) return;

      final url =
          Uri.parse(AppConstants.BASE_URL + AppConstants.DELETE_RESUME + '$id');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token ?? ''
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        // _showSuccessToast('Resume deleted successfully');
        await _fetchCandidateProfileData();
      } else {
        throw Exception('Failed to delete resume');
      }
    } catch (e) {
      // _showErrorToast('Failed to delete resume');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCandidateProfileData([int show = 1]) async {
    try {
      if (retrievedUserData == null) return;

      setState(() => isLoading = true);
      final url = Uri.parse(AppConstants.BASE_URL +
          AppConstants.CANDIDATE_PROFILE +
          retrievedUserData!.profileId.toString());

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token ?? ''
        },
      );

      if (response.statusCode == 200) {
        final resOBJ = jsonDecode(response.body);
        if (resOBJ['message'].toString().toLowerCase().contains('success')) {
          final data = resOBJ['data'];
          final candidateData = CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);
          await _initializeData();

          if (show == 1 && mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     behavior: SnackBarBehavior.floating,
            //     backgroundColor: Color(0xff2D2D2D),
            //     elevation: 10,
            //     margin: EdgeInsets.only(bottom: 30, left: 15, right: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     content: Row(
            //       children: [
            //         SvgPicture.asset('assets/icon/success.svg'),
            //         SizedBox(width: 12),
            //         Expanded(
            //           child: Text(
            //             'Profile updated successfully !',
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //         GestureDetector(
            //           onTap: () =>
            //               ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            //           child: Icon(Icons.close_rounded, color: Colors.white),
            //         )
            //       ],
            //     ),
            //     duration: Duration(seconds: 3),
            //   ),
            // );
          }
        }
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      // _showErrorToast("Failed to refresh profile");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<File?> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) return null;

      final file = File(result.files.single.path!);
      final extension = file.path.split('.').last.toLowerCase();

      if (!['pdf', 'doc', 'docx'].contains(extension)) {
        throw 'Unsupported file type';
      }

      final fileSize = await file.length();
      if (fileSize <= 0) throw 'File must be greater than 0MB';
      if (fileSize > 5 * 1024 * 1024) throw 'File must be less than 5MB';

      return file;
    } catch (e) {
      _showErrorToast(e.toString());
      return null;
    }
  }

  Future<void> _uploadPDF(File file) async {
    try {
      if (retrievedUserData == null) return;

      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
        selectedFile = file;
      });

      final dio = Dio();
      final url = '${AppConstants.BASE_URL}/api/v1/resumeresource/uploadresume';
      final token = retrievedUserData!.token ?? '';

      final formData = FormData.fromMap({
        "id": retrievedUserData!.profileId.toString(),
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (sent, total) {
          if (total != 0 && mounted) {
            setState(() => uploadProgress = sent / total);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        await _setUpdatedTimeInRTDB();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xff2D2D2D),
            elevation: 10,
            margin: EdgeInsets.only(bottom: 30, left: 15, right: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                SvgPicture.asset('assets/icon/success.svg'),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resume uploaded !',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Icon(Icons.close_rounded, color: Colors.white),
                )
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
        // _showSuccessToast('Resume uploaded successfully');
        await _fetchCandidateProfileData();
      } else {
        throw Exception('Failed to upload resume');
      }
    } catch (e) {
      // _showErrorToast('Failed to upload resume: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
          uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _pickAndUploadPDF() async {
    final file = await _pickPDF();
    if (file != null) {
      await _uploadPDF(file);
    }
  }

  Future<void> _setUpdatedTimeInRTDB() async {
    try {
      if (email.isEmpty) return;

      final String sanitizedEmail = email.replaceAll('.', ',');
      final DatabaseReference resumeUpdatedRef =
          databaseRef.child('$sanitizedEmail/resumeUpdated');
      await resumeUpdatedRef.set(DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update resume time: $e');
      }
    }
  }

  Future<void> _launchURL() async {
    try {
      final filePath = candidateProfileModel.filePath;
      if (filePath == null) throw 'No file available';

      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch the file';
      }
    } catch (e) {
      _showErrorToast(e.toString());
    }
  }

  Future<void> _downloadAndShareCV() async {
    try {
      final filePath = candidateProfileModel.filePath;
      final fileName = candidateProfileModel.fileName;

      if (filePath == null || fileName == null) {
        throw 'No resume available to share';
      }

      final tempDir = await getTemporaryDirectory();
      final localPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final dio = Dio();
      await dio.download(filePath, localPath);

      await Share.shareXFiles([XFile(localPath)], text: 'Check out my CV');
    } catch (e) {
      _showErrorToast('Failed to share file');
    }
  }

  void _showResumeDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width - 35,
            padding: EdgeInsets.fromLTRB(22, 15, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete resume',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete your resume?',
                  style: TextStyle(
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _deleteResume(id);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String type, String id) {
    String title = type == 'education'
        ? 'Delete educational details'
        : 'Delete work experience';
    String message = type == 'education'
        ? 'Are you sure you want to delete your educational details?'
        : 'Are you sure you want to delete your work experience?';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width - 35,
            padding: const EdgeInsets.fromLTRB(22, 15, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'lato',
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    height: 1.4,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'lato',
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                  color: AppColors.primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontFamily: 'lato',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if (type == 'education') {
                                _deleteEducation(id);
                              } else {
                                _deleteEmployment(id);
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'lato',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xff2D2D2D),
        elevation: 10,
        margin: EdgeInsets.only(bottom: 30, left: 15, right: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            SvgPicture.asset('assets/icon/success.svg'),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Personal details updated !',
                style: TextStyle(color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Icon(Icons.close_rounded, color: Colors.white),
            )
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xffBA1A1A),
      textColor: Colors.white,
    );
  }

  String _formatDate(String date) {
    try {
      return date == '1970-01-01'
          ? 'Present'
          : DateFormat('dd-MMM-yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  String _formatToMonthYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '1970-01-01') {
      return 'Present';
    }

    try {
      // Handle multiple possible date formats
      if (dateStr.contains('-')) {
        List<String> parts = dateStr.split('-');

        // Format 1: yyyy-MM-dd (ISO format)
        if (parts[0].length == 4) {
          return DateFormat('MMM yyyy').format(DateTime.parse(dateStr));
        }
        // Format 2: dd-MM-yyyy
        else if (parts.length == 3) {
          DateTime date = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]) // day
              );
          return DateFormat('MMM yyyy').format(date);
        }
      }
      return 'Present';
    } catch (e) {
      debugPrint('Date formatting error for "$dateStr": $e');
      return 'Present';
    }
  }

  String _formatResumeDate(String? inputDate) {
    if (inputDate == null) return "Unknown date";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(inputDate));
    } catch (e) {
      return inputDate;
    }
  }

  Widget _buildUploadInProgress() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/curriculum.png',
            width: 55,
            height: 55,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedFile != null
                      ? selectedFile!.path.split('/').last
                      : 'Processing...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Color(0xff004C99),
                  ),
                ),
                Text(
                  isUploading
                      ? 'Uploading file: ${(uploadProgress * 100).toStringAsFixed(0)}%'
                      : 'Deleting resume...',
                  style: const TextStyle(
                    color: Color(0xff545454),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.02,
            ),
            child: SizedBox(
              height: 27,
              width: 27,
              child: CircularProgressIndicator(
                value: isUploading ? uploadProgress : null,
                color: const Color(0xff004C99),
                backgroundColor: const Color(0xffC8D9EB),
                strokeWidth: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadInitial() {
    return InkWell(
      onTap: _pickAndUploadPDF,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload file',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Color(0xff004C99),
                  ),
                ),
                const Text(
                  'File types: pdf, docx  Max file size: 5MB',
                  style: TextStyle(
                    color: Color(0xff545454),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: SvgPicture.asset(
                'assets/images/mage_upload.svg',
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedResume() {
    return InkWell(
      onTap: () => _showResumeOptions(),
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xafFAFCFF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/curriculum.png',
                  width: 55,
                  height: 55,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateProfileModel.fileName ?? '',
                      style: const TextStyle(
                        color: Color(0xff004C99),
                        fontSize: 14,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last upload ${_formatResumeDate(candidateProfileModel.lastResumeUpdatedDate)}',
                      style: const TextStyle(
                        color: Color(0xff545454),
                        fontSize: 12,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.02,
              ),
              child: SvgPicture.asset('assets/icon/moreDot.svg'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResumeOptions() {
    showModalBottomSheet(
      backgroundColor: Color(0x00000000),
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
        width: MediaQuery.of(context).size.width,
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
            ListTile(
              leading: SvgPicture.asset('assets/images/ic_resume_view.svg'),
              title: const Text('View Resume'),
              onTap: () {
                Navigator.pop(context);
                if (candidateProfileModel.filePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DocViewerPage(url: candidateProfileModel.filePath!),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: SvgPicture.asset('assets/images/ic_resume_change.svg'),
              title: const Text('Change Resume'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPDF();
              },
            ),
            ListTile(
              leading: SvgPicture.asset('assets/images/ic_resume_download.svg'),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _launchURL();
              },
            ),
            ListTile(
              leading: SvgPicture.asset('assets/images/ic_share_resume.svg'),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _downloadAndShareCV();
              },
            ),
            ListTile(
              leading: SvgPicture.asset('assets/images/ic_resume_delete.svg'),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                if (candidateProfileModel.resumeId != null) {
                  _showResumeDeleteConfirmationDialog(
                      candidateProfileModel.resumeId!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceList() {
    if (workList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Include your work experience to help recruiters match your profile with suitable job openings.',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xff7D7C7C),
              fontSize: 14,
            ),
          )
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workList.length,
      itemBuilder: (context, index) {
        final item = workList[index];
        return Column(
          children: [
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: const Color(0x00000000),
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.03,
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffFCFCFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
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
                        ListTile(
                          leading:
                              SvgPicture.asset('assets/images/tabler_edit.svg'),
                          title: const Text('Edit'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Addemployment(emplomentData: item),
                              ),
                            );
                            _initializeData();
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.delete, color: Colors.black),
                          title: const Text('Delete'),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmationDialog(
                                'employment', item['id'].toString());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        height: MediaQuery.of(context).size.width - 360,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            if (index != workList.length - 1)
                              Positioned(
                                top: 15,
                                child: Container(
                                  height: MediaQuery.of(context).size.width,
                                  width: 2,
                                  color: const Color(0xff004C99),
                                ),
                              ),
                            Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff004C99),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                      Transform.translate(
                        offset: Offset(
                            0, -MediaQuery.of(context).size.width * 0.015),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['jobTitle'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xff333333),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['companyName'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xff333333),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_formatToMonthYear(item['employedFrom'])} - ${item['employedTo'] == '1970-01-01' ? 'Present' : _formatToMonthYear(item['employedTo'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  fontFamily: 'lato',
                                  color: Color(0xff7D7C7C),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: SvgPicture.asset('assets/icon/moreDot.svg'),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEducationList() {
    if (educationList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          const Text(
            'Update your education details to boost your chances of securing a job more quickly.',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xff7D7C7C),
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: educationList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                  backgroundColor: const Color(0x00000000),
                  isDismissible: true,
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.03,
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffFCFCFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
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
                        ListTile(
                          leading:
                              SvgPicture.asset('assets/images/tabler_edit.svg'),
                          title: const Text('Edit'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Addeducation(
                                    educationDetail: educationList[index]),
                              ),
                            );
                            _initializeData();
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.delete, color: Colors.black),
                          title: const Text('Delete'),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmationDialog('education',
                                educationList[index]['id'].toString());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        height: MediaQuery.of(context).size.width - 360,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            if (index != educationList.length - 1)
                              Positioned(
                                top: 15,
                                child: Container(
                                  height: MediaQuery.of(context).size.width,
                                  width: 2,
                                  color: const Color(0xff004C99),
                                ),
                              ),
                            Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff004C99),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                      Transform.translate(
                        offset: Offset(
                            0, -MediaQuery.of(context).size.width * 0.022),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                educationList[index]['degree'] ?? 'Unknown',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  fontFamily: 'lato',
                                  color: Color(0xff333333),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Text(
                                educationList[index]['schoolName'] ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'lato',
                                  fontSize: 14,
                                  color: Color(0xff333333),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Text(
                                '${_formatToMonthYear(educationList[index]['graduatedFrom'])} - ${educationList[index]['graduatedTo'] == '1970-01-01' ? 'Present' : _formatToMonthYear(educationList[index]['graduatedTo'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  fontFamily: 'lato',
                                  color: Color(0xff7D7C7C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: SvgPicture.asset('assets/icon/moreDot.svg'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillsSection() {
    if (userSkills.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'List your skills on your profile. This will help recruiters find you more easily.',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xff7D7C7C),
              fontSize: 14,
            ),
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 12.0,
          runSpacing: 12.0,
          children: userSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.primaryColor,
              ),
              child: Text(
                skill,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: RefreshIndicator(
        onRefresh: () async {
          if (retrievedUserData != null) {
            await _fetchCandidateProfileData(0);
          }
        },
        child: Column(
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
                        icon:
                            Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                  SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    PhysicalModel(
                      elevation: 0.5,
                      color: const Color(0xffFCFCFC),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.23,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height *
                                      0.0723,
                                  decoration: const BoxDecoration(
                                    color: Color(0xff001B3E),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: MediaQuery.of(context).size.height *
                                      0.007,
                                  left: (MediaQuery.of(context).size.width -
                                          (MediaQuery.of(context).size.width *
                                              0.25)) /
                                      2,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EditPhotoPage()),
                                            );
                                            _initializeData();
                                          },
                                          child: ClipOval(
                                            child: candidateProfileModel
                                                        .imagePath !=
                                                    null
                                                ? Image.network(
                                                    candidateProfileModel
                                                        .imagePath!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return SvgPicture.asset(
                                                        'assets/icon/profile.svg',
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : SvgPicture.asset(
                                                    'assets/icon/profile.svg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: SvgPicture.asset(
                                          'assets/icon/DpEdit.svg',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right:
                                      MediaQuery.of(context).size.width * 0.07,
                                  top: MediaQuery.of(context).size.height *
                                      0.105,
                                  child: InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const EditPersonalDetails()),
                                      );
                                      _initializeData();
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/edit.svg',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045,
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Color(0xff001B3E),
                                            fontSize: 14,
                                            fontFamily: 'lato',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height * 0.14,
                                  left: 15,
                                  right: 15,
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          candidateProfileModel.candidateName ??
                                              'No name provided',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff333333),
                                            fontFamily: 'Lato',
                                            fontSize: 20,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          candidateProfileModel.position ??
                                              'Designation not updated',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'lato',
                                            color: Color(0xff545454),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ListTile(
                                dense: true,
                                leading: SvgPicture.asset(
                                  'assets/icon/location.svg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                  height:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                minLeadingWidth: 10,
                                title: Text(
                                  candidateProfileModel.location ??
                                      'Location not updated',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff333333),
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: SvgPicture.asset(
                                  'assets/icon/newJob.svg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                  height:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                minLeadingWidth: 10,
                                title: Text(
                                  candidateProfileModel.experience == null
                                      ? 'Experience not updated'
                                      : candidateProfileModel.experience == 0 ||
                                              candidateProfileModel
                                                      .experience ==
                                                  0.0
                                          ? 'Fresher'
                                          : candidateProfileModel.experience!
                                                  .toStringAsFixed(1)
                                                  .endsWith('.0')
                                              ? '${candidateProfileModel.experience!.toInt()} ${candidateProfileModel.experience!.toInt() == 1 ? 'Year' : 'Years'}'
                                              : '${candidateProfileModel.experience} Years',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff333333),
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: SvgPicture.asset(
                                  'assets/icon/phone.svg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                  height:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                minLeadingWidth: 10,
                                title: Text(
                                  candidateProfileModel.mobile != null
                                      ? (() {
                                          String cleanedMobile =
                                              candidateProfileModel.mobile!
                                                  .replaceAll(
                                                      RegExp(r'[^\d+]'), '');
                                          return cleanedMobile
                                                      .startsWith('+91') &&
                                                  cleanedMobile.length == 13
                                              ? '+91 ${cleanedMobile.substring(3)}'
                                              : cleanedMobile;
                                        })()
                                      : 'Not available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff333333),
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: SvgPicture.asset(
                                  'assets/icon/mail.svg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                  height:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                minLeadingWidth: 10,
                                title: Text(
                                  candidateProfileModel.email ??
                                      'Email not available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff333333),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Resume Section
                    Container(
                      width: 550,
                      decoration: BoxDecoration(
                        color: const Color(0xffFCFCFC),
                        border: Border.all(
                            width: 0.3, color: const Color(0xffD2D2D2)),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resume',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: Color(0xff333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (isUploading ||
                              (isLoading && selectedFile != null))
                            _buildUploadInProgress()
                          else if (candidateProfileModel.fileName?.isEmpty ??
                              true)
                            _buildUploadInitial()
                          else
                            _buildUploadedResume(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Work Experience Section
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.3, color: const Color(0xffD2D2D2)),
                        color: const Color(0xffFCFCFC),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Work Experience',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Addemployment(
                                              emplomentData: null),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                  _initializeData();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icon/add.svg',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildExperienceList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Education Section
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.3, color: const Color(0xffD2D2D2)),
                        color: const Color(0xffFCFCFC),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Educational Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Addeducation(
                                              educationDetail: null),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                  _initializeData();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icon/add.svg',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildEducationList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Skills Section
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.3, color: const Color(0xffD2D2D2)),
                        color: const Color(0xffFCFCFC),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Skills',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Adddeleteskills(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icon/add.svg',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildSkillsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
