import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.showNavBack});

  final bool showNavBack;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool loading = true;
  bool value = false;
  AppState appState = AppState();

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkingCall();
    });
  }

  Future checkingCall() async {
    final res = await appState.checkUserAcceptedPolicyById();
    setState(() {
      value = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          leading: widget.showNavBack
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    size: 26,
                  ))
              : const SizedBox(),
          centerTitle: true,
          title: AppText(
            text: 'Privacy Policy',
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: Container(
          color: AppColors.black,
          width: double.infinity,
          height: double.infinity,
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Privacy Policy for Glorify God App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Effective Date: [December 23, 2023]',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 12,
                ),
                SectionWidget(
                  title: 'Information We Collect',
                  content: [
                    '1. Account Information: When you create an account on the Glorify God App, we may collect personal information such as your name, email address, and a password. This information is used to identify you and facilitate a personalized experience on the App.',
                    '2. Devotional Christian Songs: The core functionality of the Glorify God App involves listening to and uploading devotional Christian songs. We may collect information related to the songs you listen to and the songs you upload to provide you with an enhanced user experience.',
                  ],
                ),
                SectionWidget(
                  title: 'How We Use Your Information',
                  content: [
                    '1. Personalization: We use the information collected to personalize your experience on the Glorify God App, suggesting devotional Christian songs based on your preferences and usage patterns.',
                    '2. Account Management: Your account information is used for account management purposes, including authentication, security, and communication related to your account.',
                    '3. Song Recommendations: We use data about the devotional Christian songs you listen to and upload to provide tailored song recommendations and improve the overall App experience.',
                  ],
                ),
                SectionWidget(
                  title: 'Information Sharing',
                  content: [
                    '1. User-Generated Content: Devotional Christian songs uploaded by users are considered user-generated content. By using the Glorify God App, you understand and agree that this content will be shared with other users in accordance with the App\'s purpose.',
                    '2. Service Providers: We may engage third-party service providers to assist with app functionality, analytics, and other services. These providers are obligated to maintain the confidentiality of your information and comply with applicable data protection laws.',
                  ],
                ),
                SectionWidget(
                  title: 'Security',
                  content: [
                    'We prioritize the security of your information and employ reasonable measures to protect against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is entirely secure, and we cannot guarantee absolute security.',
                  ],
                ),
                SectionWidget(
                  title: 'Changes to this Privacy Policy',
                  content: [
                    'We reserve the right to update or modify this Privacy Policy at any time, and such changes will be effective immediately upon posting. We encourage you to review this Privacy Policy periodically for any updates.',
                  ],
                ),
                SectionWidget(
                  title: 'Contact Us',
                  content: [
                    'If you have any questions or concerns about this Privacy Policy or the Glorify God App, please contact us at [E-main: k.syam7908@gmail.com, P.No: 9704263451].',
                  ],
                ),
                Text(
                  'By using the Glorify God App, you consent to the terms outlined in this Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      width: double.infinity,
      height: !widget.showNavBack ? 130 : 80,
      color: AppColors.dullBlack.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              dense: true,
              leading: Checkbox(
                  value: value,
                  activeColor: widget.showNavBack
                      ? AppColors.redAccent.withOpacity(0.5)
                      : AppColors.redAccent,
                  onChanged: widget.showNavBack
                      ? null
                      : (val) {
                          setState(() {
                            value = val!;
                          });
                        }),
              title: AppText(
                text: 'I agree to the terms and conditions.',
                textAlign: TextAlign.start,
                styles: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (!widget.showNavBack)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CupertinoButton(
                    padding: const EdgeInsets.only(left: 60, right: 60),
                    color: AppColors.white,
                    disabledColor: AppColors.grey,
                    onPressed: value
                        ? () async {
                            setState(() {
                              loading = true;
                            });
                            final accepted =
                                await appState.acceptedPolicyById();
                            setState(() {
                              loading = false;
                            });
                            if (accepted) {
                              await navigation();
                            }
                          }
                        : null,
                    child: AppText(
                      text: 'Agree & Continue',
                      styles: GoogleFonts.manrope(
                          color: value
                              ? AppColors.black
                              : AppColors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w600),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Future navigation() async {
    await Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<BottomTabs>(
          builder: (_) => const BottomTabs(),
        ),
        (route) => false);
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<String> content;

  const SectionWidget({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map((item) => Text('• $item')).toList(),
          ),
        ],
      ),
    );
  }
}
