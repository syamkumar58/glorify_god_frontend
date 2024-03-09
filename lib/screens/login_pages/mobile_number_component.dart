import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/login_pages/mobile_otp_screen.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileNumberComponent extends StatefulWidget {
  const MobileNumberComponent({super.key});

  @override
  State<MobileNumberComponent> createState() => _MobileNumberComponentState();
}

class _MobileNumberComponentState extends State<MobileNumberComponent> {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AppState appState = AppState();

  double get width =>
      MediaQuery
          .of(context)
          .size
          .width;

  double get height =>
      MediaQuery
          .of(context)
          .size
          .height;

  String dailCode = '+91';

  TextEditingController mobileNumberController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mobileNumberField(),
        sendOtpButton(),
      ],
    );
  }

  Widget mobileNumberField() {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.08,
      ),
      child: SizedBox(
        width: width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Mobile Number',
              styles: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextFormField(
                controller: mobileNumberController,
                keyboardType: TextInputType.number,
                cursorColor: AppColors.white,
                scrollPadding: const EdgeInsets.only(bottom: 50),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // Disallow spaces
                ],
                maxLength: 10,
                decoration: InputDecoration(
                  fillColor: AppColors.grey.withOpacity(0.3),
                  focusColor: AppColors.white,
                  contentPadding: const EdgeInsets.only(top: 20),
                  hintText: 'Enter your mobile number',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.dullWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: SizedBox(
                    width: 60,
                    child: Center(
                      child: AppText(
                        styles: GoogleFonts.manrope(
                          color: Colors.white,
                        ),
                        text: dailCode,
                      ),
                    ),
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      log('message 1');
                      mobileNumberController.clear();
                    },
                    child: Icon(
                      Icons.close,
                      size: 17,
                      color: AppColors.white,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.white,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorStyle: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.redAccent,
                  ),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sendOtpButton() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.04),
      child: Container(
        width: width * 0.6,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            await sendOtpMethod();
            // await phoneNumberUserLogin(
            //   mobileNumber:  '+919999999999',//'+919704263451',
            // );
          },
          child: AppText(
            text: 'Send OTP',
            styles: GoogleFonts.manrope(
              color: AppColors.appColor2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future sendOtpMethod() async {
    if (mobileNumberController.text.isNotEmpty &&
        mobileNumberController.text.length == 10) {
      // setState(() {
      //   loading = true;
      // });
      final phoneNumber = '$dailCode${mobileNumberController.text}';
      log(phoneNumber, name: 'On send otp mobile number');
      await sendOTPToMobileNumber(phoneNumber: phoneNumber);
    } else {
      // setState(() {
      //   loading = false;
      // });
      if (mobileNumberController.text.length < 10) {
        flushBar(
            context: context, messageText: 'Please check your mobile number');
      }
    }
  }

  Future sendOTPToMobileNumber({required String phoneNumber}) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
        verificationFailed: (FirebaseAuthException firebaseAuthException) {
          // setState(() {
          //   loading = false;
          // });
          log('$firebaseAuthException', name: 'firebaseAuthException');

          if (firebaseAuthException.toString().contains(
              'We have blocked all requests from this device due to unusual activity. Try again later')) {
            flushBar(
                context: context,
                messageText: 'Please try again! after sometime');
          }
        },
        codeSent: (String verificationId, int? forceResendToken) async {
          // setState(() {
          //   loading = false;
          // });
          //<-- Navigate to OTP screen -->/
          await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) =>
                  MobileOtpScreen(
                    verificationId: verificationId,
                    mobileNumber: phoneNumber,
                    dailCode: dailCode,
                    isGuest: false,
                  ),
            ),
          );
          mobileNumberController.clear();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // setState(() {
          //   loading = false;
          // });
        },
      );
    } catch (er) {
      log('$er', name: 'Sending otp to mobile number failed');
    }
  }


}
