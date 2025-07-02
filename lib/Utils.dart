import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

bool validateEmail(String email) {
  // A basic regex pattern for email validation
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regExp = RegExp(emailPattern);
  return regExp.hasMatch(email);
}

Future<void> saveUserData(UserData userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userDataJson = jsonEncode(userData.toJson());
  await prefs.setString('userData', userDataJson);
}

Future<UserData?> getUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataJson = prefs.getString('userData');
  if (userDataJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userDataJson);
    return UserData.fromJson(userMap);
  }
  return null;
}

Future<void> saveReferralProfileData(ReferralData userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userDataJson = jsonEncode(userData.toJson());
  await prefs.setString('referralProfileData', userDataJson);
}

Future<ReferralData?> getReferralProfileData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataJson = prefs.getString('referralProfileData');
  if (userDataJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userDataJson);
    return ReferralData.fromJson(userMap);
  }
  return null;
}

Future<void> saveStringToPreferences(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> saveBoolToPreferences(String key, bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<String?> getStringFromPreferences(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<bool?> getBoolFromPreferences(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

Future<void> saveCandidateProfileData(CandidateProfileModel userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userDataJson = jsonEncode(userData.toJson());
  await prefs.setString('candidateProfileData', userDataJson);
}

Future<CandidateProfileModel?> getCandidateProfileData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataJson = prefs.getString('candidateProfileData');
  if (userDataJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userDataJson);
    return CandidateProfileModel.fromJson(userMap);
  }
  return null;
}


String processDate(String createdDate) {
  DateTime postDate = DateTime.tryParse(createdDate) ?? DateTime(1990);
  DateTime now = DateTime.now();
  Duration diff = now.difference(postDate);

  if (diff.inHours < 1) {
    return 'Just now';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  } else if (diff.inDays < 30) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  } else if (diff.inDays < 365) {
    int months = (diff.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} ago';
  } else {
    int years = (diff.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}


Future<void> saveJobListLocally(List<dynamic> jobs) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jobListString = jsonEncode(jobs);
  await prefs.setString('jobList', jobListString);
}

Future<void> clearCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
  await prefs.remove('password');
}
