class AppConstants {
  static const String BASE_URL = "https://mobileapi.talentturbo.us";

  static String APP_NAME = 'talent_turbo_referral';

  static String LOGIN = "/api/v1/userresource/authenticate";
  static String SOCIAL_LOGIN = "/api/v1/userresource/social/authenticate";
  static String LOGIN_BY_MOBILE =
      "/api/v1/userresource/authenticate/with/mobileno";
  static String VERIFY_LOGIN_OTP = "/api/v1/userresource/verify/login/otp";
  static const String REGISTER = "/api/v1/userresource/register";

  static String FORGOT_PASSWORD = "/api/v1/userresource/reset/password";
  static String FORGOT_PASSWORD_OTP_VERIFY =
      "/api/v1/userresource/verify/resetotp";
  static String FORGOT_PASSWORD_UPDATE_PASSWORD =
      "/api/v1/userresource/update/password";

  static String REFERRAL_PROFILE =
      "/api/v1/referralresource/view/referral/profile/";
  static String CANDIDATE_PROFILE = "/api/v1/candidateresource/profile/";
  static String UPDATE_CANDIDATE_PROFILE =
      "/api/v1/candidateresource/update/profile";
  static String UPDATE_CANDIDATE_PROFILE_PICTURE =
      "/api/v1/resumeresource/uploadprofilephoto";

  static String APPLIED_JOBS_LIST =
      "/api/v1/jobresource/candidate/applied/jobs";
  static String APPLIED_JOBS_STATUS =
      "/api/v1/jobresource/candidate/applied/job/status";

  static String SAVE_JOB_TO_FAV_NEW = "/api/v1/jobresource/job/favorite";
  static String GET_FAV_NEW = "/api/v1/jobresource/list/favorite/jobs";

  static String ADD_UPDATE_EDUCATION =
      "/api/v1/candidateresource/update/candidate/"; //api/v1/candidateresource/update/candidate/{candidateId}}/education;
  static String DELETE_EDUCATION =
      "/api/v1/candidateresource/delete/candidate/education/";

  ///api/v1/candidateresource/delete/candidate/education/{education_id};

  static String ADD_EMPLOYMENT =
      "/api/v1/candidateresource/update/candidate/"; // /api/v1/candidateresource/update/candidate/{candidateId}/employment;
  static String DELETE_EMPLOYMENT =
      "/api/v1/candidateresource/delete/candidate/employment/"; // /api/v1/candidateresource/delete/candidate/employment/{employment_id};
  static String DELETE_RESUME =
      "/api/v1/resumeresource/delete/resume?id="; // /api/v1/candidateresource/delete/candidate/employment/{employment_id};

  static String REMOVE_PHOTO = "/api/v1/resumeresource/delete/profile/photo";

  static String JOBS_LIST = "/api/v1/jobresource/job/list";
  static String VIEW_JOB = "/api/v1/jobresource/view/";
  static String ALL_JOBS_LIST = "/api/v1/jobresource/list/all/jobs";
  static String APPLY_JOB = "/api/v1/jobresource/candidate/job/applied";
  static String GET_REF_CODE_SHARE = "/api/v1/jobresource/add/job/share";

  static String VERIFY_EMAIL_PHONE =
      "/api/v1/userresource/send/verificationcode";
  static String VALIDATE_VERIFY_OTP =
      "/api/v1/userresource/verify/verificationcode";
}
