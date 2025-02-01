class ReferralData {
  final int id;
  final int userId;
  final String referralCode;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String countryCode;
  final String phoneNumber;

  ReferralData({
    required this.id,
    required this.userId,
    required this.referralCode,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
  });

  // Factory method to create an instance from JSON
  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      id: json['id'],
      userId: json['userId'],
      referralCode: json['referralCode'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      name: json['name'],
      email: json['email'],
      countryCode: json['countryCode'],
      phoneNumber: json['phoneNumber'],
    );
  }

  // Method to convert an instance back to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'referralCode': referralCode,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
    };
  }
}
