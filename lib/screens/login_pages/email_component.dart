import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/screens/login_pages/my_sign_up_screen.dart';
import 'package:glorify_god/src/provider/user_bloc.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmailComponent extends StatefulWidget {
  const EmailComponent(
      {super.key, required this.loading, required this.context});

  final Function(bool loading) loading;

  final BuildContext context;

  @override
  State<EmailComponent> createState() => _EmailComponentState();
}

class _EmailComponentState extends State<EmailComponent> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AppState appState = AppState();

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(widget.context);
    return Form(
      key: formKey,
      child: Column(
        children: [
          emailField(),
          passwordField(),
          forgotPassword(),
          emailLoginButton(),
          signUp(),
        ],
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
                text: AppStrings.forgotPassword,
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
          if (!EmailValidator.validate(emailController.text)) {
            toast(messageText: AppStrings.enterAValidEmail);
          } else if (firebaseAuth.currentUser != null &&
              !firebaseAuth.currentUser!.emailVerified) {
            await firebaseAuth.currentUser!.reload();
            log('${firebaseAuth.currentUser}', name: 'Email is not verified');
            toast(
                messageText:
                    '${emailController.text} ${AppStrings.providedEmailNotVerified}');
          } else {
            await onSubmit();
          }
        },
        child: AppText(
          text: AppStrings.login,
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
            text: AppStrings.dontHaveAnAccount,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
          TextSpan(
            text: AppStrings.signUp,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                //<-- On Tap signUp open create account -->/
                Navigator.of(widget.context).push(
                  CupertinoPageRoute(
                      builder: (_) => MySignUpScreen(
                            holdEmailData: (String email, bool emailVerified) {
                              setState(() {
                                emailController.text = email;
                              });
                            },
                          )),
                );
              },
          ),
        ],
      )),
    );
  }

  Future onSubmit() async {
    final form = formKey.currentState!;

    if (form.validate()) {
      if (passwordController.text.trim().isEmpty) {
        toast(messageText: AppStrings.enterAValidPassword);
      } else {
        log('step 3');
        FocusScope.of(widget.context).unfocus();
        await onSubmitEmailLogin();
      }
    }
  }

  Future onSubmitEmailLogin() async {
    widget.loading(true);

    try {
      final userLogin = await emailLogin(
        context: widget.context,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userLogin != null) {
        widget.loading(false);
        bottomTabsNavigation();
      } else {
        widget.loading(false);
        log('something went wrong on logIn with email');
      }
    } on FirebaseAuthException catch (er) {
      if (er.toString().contains(
          'The supplied auth credential is incorrect, malformed or has expired.')) {
        toast(
          messageText: AppStrings.credentialsAreWrong,
        );
      } else if (er.message.toString().contains(''
          'INVALID_LOGIN_CREDENTIALS')) {
        toast(
          messageText: AppStrings.provideAValidDetails,
        );
      }
      log('$er and  ${er.runtimeType}', name: 'Email login failed');
      // if(){}
      widget.loading(false);
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
      toast(messageText: AppStrings.enterAValidEmail);
    }
  }

  void toast({required String messageText}) {
    flushBar(
      context: widget.context,
      messageText: messageText,
    );
  }

  void bottomTabsNavigation() {
    Navigator.pushAndRemoveUntil(
        widget.context,
        CupertinoPageRoute<BottomTabs>(
          builder: (_) => const BottomTabs(),
        ),
        (route) => false);
  }
}
