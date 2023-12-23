import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/ads_card.dart';
import 'package:glorify_god/components/banner_card.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/config/helpers.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class ReportAProblem extends StatefulWidget {
  const ReportAProblem({super.key});

  @override
  State<ReportAProblem> createState() => _ReportAProblemState();
}

class _ReportAProblemState extends State<ReportAProblem> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  String reportedIssue = '';
  TextEditingController issueController = TextEditingController();
  AppState appState = AppState();
  bool isLoading = false;

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    appState.reportedIssuesById();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CupertinoActivityIndicator(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: AppText(
            text: AppStrings.reportIssue,
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                const BannerCard(),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: AppText(
                        text: AppStrings.reportIssue,
                        styles: GoogleFonts.manrope(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                      trailing: CupertinoButton(
                        onPressed: reportedIssue.trim().isNotEmpty
                            ? () async {
                                setState(() {
                                  isLoading = true;
                                });
                                FocusScope.of(context).unfocus();
                                final res = await appState.updateFeedback(
                                    message: reportedIssue.trim());

                                if (res) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  toastMessage(
                                      message: 'Feedback sent successfully');
                                  // Navigator.pop(context);
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            : null,
                        child: AppText(
                          text: AppStrings.send,
                          styles: GoogleFonts.manrope(),
                        ),
                      ),
                    ),
                    TextFormField(
                      maxLines: 5,
                      maxLength: 500,
                      controller: issueController,
                      scrollPadding: const EdgeInsets.only(bottom: 120),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          reportedIssue = text;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                ...appState.reportedIssue.map((e) {
                  final index = appState.reportedIssue.indexOf(e) + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: width * 0.9,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.dullBlack.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: '$index.',
                            styles: GoogleFonts.manrope(
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: width * 0.75,
                                  child: Text(
                                    e.feedback,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                AppText(
                                  textAlign: TextAlign.start,
                                  styles: GoogleFonts.manrope(
                                    fontSize: 12,
                                  ),
                                  text: DateFormat('d MMM y').add_jm().format(
                                    e.createdAt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(
                  height: 40,
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: AdsCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
