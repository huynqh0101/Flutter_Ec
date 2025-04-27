import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: appTheme.deepPurpleA200,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(
              'lib/assets/images/img_welcome_onboarding.jpg',
            ),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -160,
              left: SizeUtils.width / 2 - 600 / 2,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  color: appTheme.deepPurpleA200,
                  shape: BoxShape.circle,

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 235),
                    SizedBox(
                      // height: 234.h,
                      width: double.maxFinite,
                      child: Stack(
                        // alignment: Alignment.topCenter,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Shop".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 120, // Adjust the font size as needed
                                fontWeight: FontWeight.bold, // Make the text bold
                                color: Colors.white,
                                height: 0.4,// White text to contrast with the circle
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Smarter".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 68, // Adjust the font size as needed
                              fontWeight: FontWeight.bold, // Make the text bold
                              color: Colors.white,
                              height: 1.6,// White text to contrast with the circle
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "live better".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 52, // Adjust the font size as needed
                              fontWeight: FontWeight.bold, // Make the text bold
                              color: Colors.white,
                              height: 0.1,// White text to contrast with the circle
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 310,
                      margin: EdgeInsets.only(),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              text: 'Login',
                              height: 44.h,
                              leftIcon: const Icon(
                                Icons.account_circle_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              buttonStyle: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.signInScreen);
                              },
                            ),
                          ),
                          SizedBox(width: 12.h), // Khoảng cách giữa 2 nút
                          Expanded(
                            child: CustomElevatedButton(
                              text: 'Guest',
                              height: 44.h,
                              leftIcon: const Icon(
                                Icons.card_travel,
                                size: 20,
                                color: Colors.white,
                              ),
                              buttonStyle: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // AuthService().signInAnonymous();
                                Navigator.pushNamed(context, AppRoutes.homeScreen);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
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




