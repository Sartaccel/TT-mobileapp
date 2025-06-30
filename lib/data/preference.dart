import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String TOKEN = 'token';
  static const String COUNTRY_CODE = 'country_code';
  static const String COUNTRY_ID = 'country_id';
  static const String SELECTED_COUNTRY = 'selected_country';
  static const String SELECTED_COUNTRYCODE_NAME = 'countrycode_name';
  static const String ANDROID_ID = 'androidID';
  static const String ISREGISTERED = 'isregistered';
  static const String ISLOGINED = 'is_logged_in';
  static const String CURRENCY = 'currency';
  static const String SAVED_DATE = 'savedDate';
  static const String COMPANYID = 'companyid';
  static const String MERCHANTTRANID = 'merchantTranId';
  static const String UPITRANSAMOUNT = 'upitransamount';
  static const String ISGETPAIDDETAILS = 'isgetpaiddetails';
  static const String TANDC = 'tandc';
  static const String USER = 'user';
  static const String SELECTED_LANGUAGE = 'selected_language';
  static const String TOTAL_CREDITS = 'total_credits';
  static const String IS_NOTIFICATION_TAPPED = 'tapped';
  static const String NOTIFICATIONJCID = 'notificationJcId';

  static bool get isIndia {
    String selectedCountry = Preference.selectedCountry;
    return selectedCountry.toLowerCase() == "india";
  }

  static String get token => _prefs.getString(TOKEN) ?? '';
  static set token(String value) => _prefs.setString(TOKEN, value);

  static int get countryid => _prefs.getInt(COUNTRY_ID) ?? 0;
  static set countryid(int value) => _prefs.setInt(COUNTRY_ID, value);

  static String get countryCode => _prefs.getString(COUNTRY_CODE) ?? '';
  static set countryCode(String value) => _prefs.setString(COUNTRY_CODE, value);

  static String get countryCodeName =>
      _prefs.getString(SELECTED_COUNTRYCODE_NAME) ?? '';
  static set countryCodeName(String value) =>
      _prefs.setString(SELECTED_COUNTRYCODE_NAME, value);

  static String get selectedCountry => _prefs.getString(SELECTED_COUNTRY) ?? '';
  static set selectedCountry(String value) =>
      _prefs.setString(SELECTED_COUNTRY, value);

  static String get androidID => _prefs.getString(ANDROID_ID) ?? '';
  static set androidID(String value) => _prefs.setString(ANDROID_ID, value);

  static String get savedDate => _prefs.getString(SAVED_DATE) ?? '';
  static set savedDate(String value) => _prefs.setString(SAVED_DATE, value);

  static bool get isNeedToHitToday {
    String currentDate = DateTime.now().toIso8601String().split("T").first;
    String? saved = savedDate;
    if (saved != currentDate) {
      savedDate = currentDate;
      return true;
    }
    return false;
  }

  static bool get isRegistered => _prefs.getBool(ISREGISTERED) ?? false;
  static set isRegistered(bool value) => _prefs.setBool(ISREGISTERED, value);

  static bool get isLogined => _prefs.getBool(ISLOGINED) ?? false;
  static set isLogined(bool value) => _prefs.setBool(ISLOGINED, value);

  static String get currency => _prefs.getString(CURRENCY) ?? '';
  static set currency(String value) => _prefs.setString(CURRENCY, value);

  static String get companyId => _prefs.getString(COMPANYID) ?? '0';
  static set companyId(String value) => _prefs.setString(COMPANYID, value);

  static String get merchantTranId => _prefs.getString(MERCHANTTRANID) ?? '';
  static set merchantTranId(String value) =>
      _prefs.setString(MERCHANTTRANID, value);

  static String get upiTransAmount => _prefs.getString(UPITRANSAMOUNT) ?? '0';
  static set upiTransAmount(String value) =>
      _prefs.setString(UPITRANSAMOUNT, value);

  static bool get isGetPaidDetails => _prefs.getBool(ISGETPAIDDETAILS) ?? false;
  static set isGetPaidDetails(bool value) =>
      _prefs.setBool(ISGETPAIDDETAILS, value);

  static String get termsAndCondition => _prefs.getString(TANDC) ?? '';
  static set termsAndCondition(String value) => _prefs.setString(TANDC, value);

  static int get totalCredits => _prefs.getInt(TOTAL_CREDITS) ?? 0;
  static set totalCredits(int value) => _prefs.setInt(TOTAL_CREDITS, value);

  static String get selectedLanguage =>
      _prefs.getString(SELECTED_LANGUAGE) ?? 'English';
  static set selectedLanguage(String value) =>
      _prefs.setString(SELECTED_LANGUAGE, value);

  static bool get isNotificaitonTapped =>
      _prefs.getBool(IS_NOTIFICATION_TAPPED) ?? false;
  static set isNotificaitonTapped(bool value) =>
      _prefs.setBool(IS_NOTIFICATION_TAPPED, value);

  static int get notificationJcId => _prefs.getInt(NOTIFICATIONJCID) ?? 0;
  static set notificationJcId(int value) =>
      _prefs.setInt(NOTIFICATIONJCID, value);

  static void clearAllExceptCountryData() {
    final keepKeys = [
      COUNTRY_CODE,
      COUNTRY_ID,
      SELECTED_COUNTRY,
      SELECTED_COUNTRYCODE_NAME,
      ISLOGINED,
      ISREGISTERED,
      CURRENCY,
    ];

    final allKeys = _prefs.getKeys();
    for (String key in allKeys) {
      if (!keepKeys.contains(key)) {
        _prefs.remove(key);
      }
    }
  }
}
