import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/screens/main/notifications.dart';

class MyReferralsFragment extends StatefulWidget {
  const MyReferralsFragment({super.key});

  @override
  State<MyReferralsFragment> createState() => _MyReferralsFragmentState();
}

class _MyReferralsFragmentState extends State<MyReferralsFragment> {
  bool isConnectionAvailable = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _checkConnection();
    });
  }

  void _checkConnection() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        isConnectionAvailable =
            result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        isLoading = false;
      });
    } on SocketException catch (_) {
      setState(() {
        isConnectionAvailable = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          color: const Color(0xff001B3E),
        ),
        Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: const Color(0xff001B3E),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 50.0), // adjust value as needed
                      child: Text(
                        'My Referrals',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const NotificationScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SvgPicture.asset(
                      'assets/icon/Notify.svg',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              ],
            )),

        // Main Content
        Expanded(
          child: isConnectionAvailable
              ? Center(
                  child: Transform.translate(
                    offset: const Offset(0, -90),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/no_referrals.svg',
                          width: MediaQuery.of(context).size.width * 0.9,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No referrals yet',
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff333333)),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'You haven\'t referred anyone to jobs or apps yet. \nRefer now, view status, and start earning \nreward points..',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff545454)),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Transform.translate(
                    offset: const Offset(0, -60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icon/noInternet.svg',
                          height: MediaQuery.of(context).size.height * 0.22,
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'No Internet connection',
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff333333)),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Connect to Wi-Fi or cellular data and try again.',
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff545454)),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: isLoading ? null : _checkConnection,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: 5),
                                        duration: const Duration(seconds: 2),
                                        curve: Curves.linear,
                                        builder: (context, value, child) {
                                          return Transform.rotate(
                                            angle: value * 2 * 3.1416,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4,
                                              value: 0.20,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      142, 234, 232, 232),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Colors.white),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Text(
                                      'Try Again',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
