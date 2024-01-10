import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, required this.showNavBack});

  final bool showNavBack;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.parse(
              'http://glorifyGod.in/privacyPolicy',
            ),
          ),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 130,
        color: AppColors.dullBlack.withOpacity(0.8),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                dense: true,
                leading: Checkbox(
                    value: value,
                    activeColor: AppColors.redAccent,
                    onChanged: (val) {
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
              CupertinoButton(
                  padding: const EdgeInsets.only(left: 60, right: 60),
                  color: AppColors.white,
                  disabledColor: AppColors.grey,
                  onPressed: value
                      ? () async {
                          await Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute<BottomTabs>(
                                builder: (_) => const BottomTabs(),
                              ),
                              (route) => false);
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
            ],
          ),
        ),
      ),
    );
  }
}
