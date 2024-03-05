// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/login_button.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/screens/login_pages/mobile_otp_screen.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AppState appState = AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  String guestLoginNumber = '6666666666';

  late Box<dynamic> glorifyGodBox;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;

  String dailCode = '+91';

  @override
  void initState() {
    glorifyGodBox = Hive.box(HiveKeys.openBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.dullBlack,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: CupertinoActivityIndicator(
          color: AppColors.white,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                AppColors.appColor1,
                AppColors.appColor2,
              ],
            )),
            child: SizedBox(
              width: width,
              height: height,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      appTitle(),
                      // sinInText(),
                      mobileNumberField(),
                      sendOtpButton(),
                      // emailField(),
                      // passwordField(),
                      // forgotPassword(),
                      // emailLoginButton(),
                      // signUp(),
                      orWidget(),
                      googleLoginWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appTitle() {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.08,
        bottom: height * 0.05,
      ),
      child: SizedBox(
        width: width * 0.9,
        child: const AppText(
          text: AppStrings.appName2,
          styles: TextStyle(
            fontSize: 60,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'AppTitle',
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget sinInText() {
    return Padding(
      padding: EdgeInsets.only(
        top: height * 0.05,
        bottom: height * 0.05,
      ),
      child: AppText(
        text: 'Sign In with',
        styles: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget googleLoginWidget() {
    return Column(
      children: [
        loginButtonComponent(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            await login();
          },
          image: AppImages.googleImage,
        ),
        const SizedBox(
          height: 12,
        ),
        AppText(
          text: 'Sign in with\nGoogle',
          styles: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget loginButtonComponent({
    required Function onPressed,
    required String image,
  }) {
    return Bounce(
        duration: const Duration(milliseconds: 500),
        onPressed: () async {
          onPressed();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ));
  }

  Widget appleLoginButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: height * 0.2),
      child: loginButton(
        title: 'Sign in with Apple',
        height: 50,
        width: width * 0.7,
        boxColor: Colors.black12.withOpacity(0.08),
        backgroundImage: AppImages.googleImage,
        onPressed: () {},
      ),
    );
  }

  Widget orWidget() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.05, bottom: height * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.08,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: AppColors.dullWhite.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: AppText(
              styles: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              text: AppStrings.or,
            ),
          ),
          Container(
            width: width * 0.08,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: AppColors.dullWhite.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
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

  Widget emailField() {
    return SizedBox(
      width: width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Email',
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              height: 50,
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColors.white,
                scrollPadding: const EdgeInsets.only(bottom: 50),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  // Disallow spaces
                ],
                decoration: InputDecoration(
                    fillColor: AppColors.grey.withOpacity(0.3),
                    focusColor: AppColors.white,
                    contentPadding: const EdgeInsets.only(top: 8),
                    hintText: 'Enter your Email',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.dullWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(
                      Icons.mail,
                      size: 20,
                      color: AppColors.white,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        log('message 1');
                        emailController.clear();
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
                    )),
                validator: (email) => email != null &&
                        !EmailValidator.validate(emailController.text)
                    ? 'Enter a valid email'
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.02),
      child: SizedBox(
        width: width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Password',
              styles: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: passwordController,
                  scrollPadding: const EdgeInsets.only(bottom: 50),
                  cursorColor: AppColors.white,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    // Disallow spaces
                  ],
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    fillColor: AppColors.grey.withOpacity(0.3),
                    focusColor: AppColors.white,
                    contentPadding: const EdgeInsets.only(top: 8),
                    hintText: 'Enter your Password',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.dullWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppColors.white,
                      size: 20,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        log('message 2');
                        passwordController.clear();
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 30),
      child: SizedBox(
        width: width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Bounce(
              duration: const Duration(milliseconds: 50),
              onPressed: () async {
                await forgotPasswordMethod();
              },
              child: AppText(
                text: 'Forgot Password?',
                styles: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emailLoginButton() {
    return Container(
      width: width * 0.6,
      height: 35,
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(15)),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          await onSubmit();
        },
        child: AppText(
          text: 'LOGIN',
          styles: GoogleFonts.manrope(
            color: AppColors.appColor2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget signUp() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.03),
      child: RichText(
          text: TextSpan(
        children: [
          TextSpan(
            text: "Don't have an Account?",
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          TextSpan(
            text: " Sign Up",
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                //<-- On Tap signUp open create account -->/
              },
          ),
        ],
      )),
    );
  }

  Future<dynamic> login() async {
    try {
      final userLogin = await googleLogin();
      if (userLogin != null) {
        setState(() {
          loading = false;
        });
        await Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<BottomTabs>(
              builder: (_) => const BottomTabs(),
            ),
            (route) => false);
      } else {
        setState(() {
          loading = false;
        });
        log('something went wrong on logIn');
      }
    } catch (er) {
      setState(() {
        loading = false;
      });
      log('$er', name: 'login failed with');
    }
  }

  Future onSubmit() async {
    final form = formKey.currentState!;

    if (form.validate()) {
      if (passwordController.text.trim().isEmpty) {
        flushBar(context: context, messageText: 'Enter a valid password');
      } else {
        log('step 3');
        FocusScope.of(context).unfocus();
        await onSubmitEmailLogin();
      }
    }
  }

  Future onSubmitEmailLogin() async {
    setState(() {
      loading = true;
    });

    try {
      final userLogin = await emailLogin(
        context: context,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userLogin != null) {
        setState(() {
          loading = false;
        });
        await Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute<BottomTabs>(
              builder: (_) => const BottomTabs(),
            ),
            (route) => false);
      } else {
        setState(() {
          loading = false;
        });
        log('something went wrong on logIn with email');
      }
    } catch (er) {
      log('$er', name: 'Email login failed');
      setState(() {
        loading = false;
      });
    }
  }

  Future forgotPasswordMethod() async {
    if (emailController.text.trim().isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
      } catch (er) {
        log('$er', name: 'Reset password not sent');
      }
    } else {
      flushBar(context: context, messageText: 'Enter a valid Email');
    }
  }

  Future sendOtpMethod() async {
    if (mobileNumberController.text.isNotEmpty &&
        mobileNumberController.text.length == 10 &&
        mobileNumberController.text != guestLoginNumber) {
      setState(() {
        loading = true;
      });
      final phoneNumber = '$dailCode${mobileNumberController.text}';
      log(phoneNumber, name: 'On send otp mobile number');
      await sendOTPToMobileNumber(phoneNumber: phoneNumber);
    } else if (mobileNumberController.text == guestLoginNumber) {
      final phoneNumber = '$dailCode${mobileNumberController.text}';
      setState(() {
        loading = false;
      });
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => MobileOtpScreen(
            verificationId: '',
            mobileNumber: phoneNumber,
            dailCode: dailCode,
            isGuest: true,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
      });
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
          setState(() {
            loading = false;
          });
          log('$firebaseAuthException', name: 'firebaseAuthException');

          if (firebaseAuthException.toString().contains(
              'We have blocked all requests from this device due to unusual activity. Try again later')) {
            flushBar(
                context: context,
                messageText: 'Please try again! after sometime');
          }
        },
        codeSent: (String verificationId, int? forceResendToken) async {
          setState(() {
            loading = false;
          });
          //<-- Navigate to OTP screen -->/
          await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => MobileOtpScreen(
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
          setState(() {
            loading = false;
          });
        },
      );
    } catch (er) {
      log('$er', name: 'Sending otp to mobile number failed');
    }
  }
}
