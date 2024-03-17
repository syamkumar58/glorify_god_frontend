import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:google_fonts/google_fonts.dart';

class MySignUpScreen extends StatefulWidget {
  const MySignUpScreen({super.key, required this.holdEmailData});

  final Function(String email, bool emailVerified) holdEmailData;

  @override
  State<MySignUpScreen> createState() => _MySignUpScreenState();
}

class _MySignUpScreenState extends State<MySignUpScreen> {
  Timer? _timer;

  String email = '';
  String password = '';
  String reEnteredPassword = '';

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  bool passwordObscureText = true;
  bool reEnterPasswordObscureText = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();

  bool emailVerified = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 5,
          centerTitle: true,
          leading: !emailVerified
              ? IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: AppColors.white,
                  ),
                )
              : const SizedBox(),
          title: AppText(
            text: AppStrings.mySignUp,
            styles: GoogleFonts.manrope(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppImages.cross,
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: SafeArea(
                child: !emailVerified
                    ? Column(
                        children: [
                          SizedBox(
                            height: height * 0.1,
                          ),
                          emailField(),
                          passwordField(),
                          reEnterPasswordField(),
                          signUpButton(),
                        ],
                      )
                    : emailVerifiedWidget(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emailVerifiedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.white,
          size: 50,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 21, bottom: 21),
          child: AppText(
            text: AppStrings.accountVerified,
            styles: GoogleFonts.manrope(
              fontSize: 21,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Bounce(
          duration: const Duration(milliseconds: 50),
          onPressed: () {
            setState(() {
              loading = false;
            });
            widget.holdEmailData(email, true);
            Navigator.pop(context);
          },
          child: Container(
            width: width * 0.4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_left,
                  size: 25,
                  color: AppColors.black,
                ),
                AppText(
                  text: AppStrings.goBack,
                  styles: GoogleFonts.manrope(
                    fontSize: 20,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget emailField() {
    return SizedBox(
      width: width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: AppStrings.email,
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
                  hintText: AppStrings.enterYourEmail,
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.redAccent,
                    ),
                  ),
                  errorStyle: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.redAccent,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                // validator: (email) => email != null &&
                //         !EmailValidator.validate(emailController.text)
                //     ? 'Enter a valid email'
                //     : null,
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
              text: AppStrings.password,
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
                  obscureText: passwordObscureText,
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
                    hintText: AppStrings.enterYourPassword,
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
                        setState(() {
                          passwordObscureText = !passwordObscureText;
                        });
                      },
                      child: Icon(
                        passwordObscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 19,
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
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reEnterPasswordField() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.02),
      child: SizedBox(
        width: width * 0.8,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              controller: reEnterPasswordController,
              scrollPadding: const EdgeInsets.only(bottom: 50),
              cursorColor: AppColors.white,
              obscureText: reEnterPasswordObscureText,
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
                hintText: AppStrings.reEnterYourPassword,
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
                    setState(() {
                      reEnterPasswordObscureText = !reEnterPasswordObscureText;
                    });
                  },
                  child: Icon(
                    reEnterPasswordObscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 19,
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
              onChanged: (value) {
                setState(() {
                  reEnteredPassword = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Container(
        width: width * 0.6,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: !loading ? signUp : null,
          child: !loading
              ? AppText(
                  text: AppStrings.signUp,
                  styles: GoogleFonts.manrope(
                    color: AppColors.appColor2,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Center(
                  child: CupertinoActivityIndicator(
                    color: AppColors.black,
                  ),
                ),
        ),
      ),
    );
  }

  Future signUp() async {
    if (!EmailValidator.validate(emailController.text)) {
      flushBar(context: context, messageText: AppStrings.enterAValidEmail);
    } else if (password.isEmpty || reEnteredPassword.isEmpty) {
      flushBar(
        context: context,
        messageText: AppStrings.passwordCannotBeEmpty,
      );
    } else if (password != reEnteredPassword) {
      setState(() {
        passwordObscureText = false;
        reEnterPasswordObscureText = false;
      });
      flushBar(context: context, messageText: AppStrings.reCheckYourPasswords);
    } else {
      setState(() {
        loading = true;
      });
      log('', name: 'step 1');
      await sendVerification();
    }
  }

  Future sendVerification() async {
    try {
      final userCreated = await createEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCreated != null && !userCreated.user!.emailVerified) {
        await userCreated.user!.sendEmailVerification();

        // Let your know that email was sent for verification

        toastMessage(
          messageText:
              '${AppStrings.verificationEmailSentTo} $email, ${AppStrings.pleaseVerify}',
        );

        // Wait for a short time to allow the email verification process to complete
        await Future.delayed(const Duration(seconds: 2));

        // Check for email verification status
        await userCreated.user!
            .reload(); // Reload the user to get the latest info
        emailVerified = userCreated.user!.emailVerified;

        log('$emailVerified', name: 'Email verified');

        //<-- Verification email sent check for user verification
        // Start timer to check for every 3 seconds
        // -->/
        startTimer(userCredential: userCreated);
      }
    } on FirebaseAuthException catch (er) {
      setState(() {
        loading = false;
      });
      log('$er', name: 'step 4');
      if (er
          .toString()
          .contains('The email address is already in use by another account')) {
        toastMessage(
          messageText:
              '${AppStrings.thisEmail} ${emailController.text} ${AppStrings.alreadyInUse}',
        );
      }
    }
  }

  void startTimer({UserCredential? userCredential}) {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Check for email verification status
      await FirebaseAuth.instance.currentUser!
          .reload(); // Reload the user to get the latest info
      if (mounted) {
        setState(() {
          emailVerified = userCredential != null
              ? FirebaseAuth.instance.currentUser!.emailVerified
              : false;
          log(
            '$emailVerified - ${FirebaseAuth.instance.currentUser!.emailVerified} // ${FirebaseAuth.instance.currentUser!}',
            name: 'Email verified',
          );

          if (emailVerified) {
            //<-- Email is verified -->/
            FocusScope.of(context).unfocus();
            timer.cancel();
          }
        });
      }
    });
  }

  void toastMessage({required String messageText}) {
    flushBar(
      context: context,
      messageText: messageText,
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }
}
