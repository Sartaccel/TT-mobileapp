class CandidateProfileModel {
  String? candidateName;
  String? email;
  int? id;
  String? mobile;
  String? candidateCode;
  String? firstName;
  String? lastName;
  double? experience;
  int? isActive;
  int? isReferred;
  int? isDeleted;
  String? gender;
  String? position;
  String? fileName;
  String? location;
  String? filePath;
  String? imagePath;
  int? status;
  int? resumeId;
  int? isEmailVerified;
  int? isPhoneVerified;
  String? candidateStatus;
  String? lastResumeUpdatedDate;
  String? dateOfBirth;
  List<dynamic> candidateContact;
  List<dynamic> candidateEducation;
  List<dynamic> candidateEmployment;
  List<dynamic> multipleFileData;

  CandidateProfileModel({
    this.candidateName,
    this.email,
    this.id,
    this.mobile,
    this.candidateCode,
    this.firstName,
    this.lastName,
    this.experience,
    this.isActive,
    this.isReferred,
    this.isDeleted,
    this.gender,
    this.position,
    this.status,
    this.resumeId,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.candidateStatus,
    this.fileName,
    this.filePath,
    this.location,
    this.imagePath,
    this.lastResumeUpdatedDate,
    this.dateOfBirth,
    required this.candidateContact,
    required this.candidateEducation,
    required this.candidateEmployment,
    required this.multipleFileData,
  });

  // Factory method to create a Candidate object from a JSON map
  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      candidateName: json['candidateName'],
      email: json['email'],
      id: json['id'],
      mobile: json['mobile'],
      candidateCode: json['candidateCode'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      experience: (json['experience'] as num?)?.toDouble(),
      isActive: json['isActive'],
      isReferred: json['isReferred'],
      isDeleted: json['isDeleted'],
      gender: json['gender'],
      position: json['position'],
      status: json['status'],
      resumeId: json['resumeId'],
      isEmailVerified: json['isEmailVerified'],
      isPhoneVerified: json['isPhoneVerified'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      location: json['location'],
      imagePath: json['imagePath'],
      lastResumeUpdatedDate: json['lastResumeUpdatedDate'],
      dateOfBirth: json['dateOfBirth'],
      candidateStatus: json['candidateStatus'],
      candidateContact: List<dynamic>.from(json['candidateContact']),
      candidateEducation: List<dynamic>.from(json['candidateEducation']),
      candidateEmployment: List<dynamic>.from(json['candidateEmployment']),
      multipleFileData: List<dynamic>.from(json['multipleFileData']),
    );
  }

  // Method to convert a Candidate object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'candidateName': candidateName,
      'email': email,
      'id': id,
      'mobile': mobile,
      'candidateCode': candidateCode,
      'firstName': firstName,
      'lastName': lastName,
      'experience': experience,
      'isActive': isActive,
      'isReferred': isReferred,
      'isDeleted': isDeleted,
      'gender': gender,
      'position': position,
      'status': status,
      'resumeId': resumeId,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'filePath': filePath,
      'fileName': fileName,
      'location': location,
      'imagePath': imagePath,
      'lastResumeUpdatedDate': lastResumeUpdatedDate,
      'dateOfBirth': dateOfBirth,
      'candidateStatus': candidateStatus,
      'candidateContact': candidateContact,
      'candidateEducation': candidateEducation,
      'candidateEmployment': candidateEmployment,
      'multipleFileData': multipleFileData,
    };
  }
}
