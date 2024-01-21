import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/profile_models/tracker_model.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class SongsInfoScreen extends StatefulWidget {
  const SongsInfoScreen({super.key});

  @override
  State<SongsInfoScreen> createState() => _SongsInfoScreenState();
}

class _SongsInfoScreenState extends State<SongsInfoScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  bool loading = true;
  TrackerModel? trackerDetails;

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    initialCalls();
  }

  Future initialCalls() async {
    setState(() {
      loading = true;
    });
    //<-- For testing using Artist AS 4 -->/
    final data = await appState.getTrackerDetails(artistId: 4);
    setState(() {
      trackerDetails = data;
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 24,
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          title: AppText(
            text: 'SONGS INFO',
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.white,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                  onPressed: () {
                    initialCalls();
                  },
                  icon: Icon(
                    Icons.sync,
                    size: 25,
                    color: AppColors.white,
                  )),
            )
          ],
        ),
        body: Center(
          child: Container(
            width: width * 0.9,
            decoration: BoxDecoration(
              color: AppColors.dullBlack.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: trackerDetails != null
                ? ListTile(
                    title: AppText(
                      text:
                          'Total Songs Completed:- ${trackerDetails!.totalSongsCompleted}',
                      styles: GoogleFonts.manrope(
                        fontSize: 22,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
