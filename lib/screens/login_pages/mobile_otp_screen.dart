import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MobileOtpScreen extends StatefulWidget {
  const MobileOtpScreen({
    super.key,
    required this.verificationId,
    required this.mobileNumber,
    required this.dailCode,
    this.isGuest = false,
  });

  final String verificationId;
  final String mobileNumber;
  final String dailCode;
  final bool isGuest;

  @override
  State<MobileOtpScreen> createState() => _MobileOtpScreenState();
}

class _MobileOtpScreenState extends State<MobileOtpScreen> {
  bool loading = false;

  String verificationId = '';

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  OtpTimerButtonController resendTimerController = OtpTimerButtonController();

  @override
  void initState() {
    verificationId = widget.verificationId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 5,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.appColor1,
                  AppColors.appColor2,
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: width * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'OTP Authentication',
                      styles: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppText(
                        text:
                            'An authentication code has been sent to\n${widget.mobileNumber}',
                        textAlign: TextAlign.start,
                        styles: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 40),
                      child: SizedBox(
                        width: width * 0.8,
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          keyboardType: TextInputType.number,
                          cursorColor: AppColors.white,
                          autovalidateMode: AutovalidateMode.always,
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          // obscureText: true,
                          backgroundColor: Colors.transparent,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            inactiveColor: AppColors.grey,
                            activeColor: AppColors.white,
                            activeFillColor: AppColors.white,
                            selectedColor: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onCompleted: (String otp) async {
                            log(otp, name: 'onCompleted');
                            setState(() {
                              loading = true;
                            });
                            await verifyOtp(otp);
                            setState(() {
                              loading = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: AppText(
                          text: "Didn't received an OTP?",
                          textAlign: TextAlign.center,
                          styles: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: OtpTimerButton(
                        controller: resendTimerController,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.appColor2,
                        onPressed: onPressed,
                        text: const Text('Resend OTP'),
                        duration: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future verifyOtp(String otp) async {
    //<-- Not a guest user so normal flow -->/
    try {
      final authCredentials = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredentials =
          await firebaseAuth.signInWithCredential(authCredentials);

      //<-- Using userCredentials login in to app -->/
      userLoginCall(userCredentials: userCredentials);
    } catch (er) {
      log('$er', name: 'OTP verification failed');
    }
  }

  Future userLoginCall({UserCredential? userCredentials}) async {
    final userLoginResponse = await phoneNumberUserLogin(
      mobileNumber: widget.mobileNumber,
    );

    if (userLoginResponse != null) {
      await homeScreenNavigation();
    } else {
      log('Login call failed from verification otp');
    }
  }

  Future homeScreenNavigation() async {
    await Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<BottomTabs>(
          builder: (_) => const BottomTabs(),
        ),
        (route) => false,);
  }

  Future onPressed() async {
    resendTimerController.startTimer();
    await resendOtp();
  }

  Future resendOtp() async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: widget.dailCode + widget.mobileNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
        verificationFailed: (FirebaseAuthException firebaseAuthException) {
          setState(() {
            loading = false;
          });

          log('$firebaseAuthException', name: 'firebaseAuthException');
        },
        codeSent: (String verificationId, int? forceResendToken) {
          setState(() {
            loading = false;
            verificationId = verificationId;
          });
          //<-- Navigate to Nottom tabs screen -->/
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            loading = false;
          });
        },
      );
    } catch (er) {
      log('$er', name: 'Resending otp failed due to');
    }
  }
}
