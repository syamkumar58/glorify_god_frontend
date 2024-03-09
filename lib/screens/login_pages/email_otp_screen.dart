import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({super.key, required this.emailAuth});

  final EmailOTP emailAuth;

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appColor2,
        elevation: 5,
      ),
      body: PinCodeTextField(
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
          if (await widget.emailAuth.verifyOTP(otp: 121949) == true) {
            log('Otp verified');
          } else {
            log('wrong Otp');
          }
        },
      ),
    );
  }
}
