import 'dart:convert';

class UserData {
  final String email;
  final String userType;
  final String name;
  final String token;
  final int accountId;
  final int profileId;
  //final String referralCode;

  UserData({
    required this.email,
    required this.userType,
    required this.name,
    required this.token,
    required this.accountId,
    required this.profileId,
    //required this.referralCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'],
      userType: json['userType'],
      name: json['name'],
      token: json['token'],
      accountId: json['accountId'],
      profileId: json['profileId'],
      //referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userType': userType,
      'name': name,
      'token': token,
      'accountId': accountId,
      'profileId': profileId,
     // 'referralCode': referralCode,
    };
  }
}
