import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/profile_cubit/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/profile_models/tracker_model.dart';
import 'package:glorify_god/models/song_models/artists_song_data_by_id.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SongsInfoScreen extends StatefulWidget {
  const SongsInfoScreen({super.key});

  @override
  State<SongsInfoScreen> createState() => _SongsInfoScreenState();
}

class _SongsInfoScreenState extends State<SongsInfoScreen> {
  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
  AppState appState = AppState();
  bool loading = false;
  TrackerModel? trackerDetails;

  // int monetizationCount = 10;
  String monetizationCountString = '10,000';

  //<-- In Video player cubit these times for getData are set manually
  // if need to change check tha places to -->/
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    initialCall();
  }

  Future initialCall() async {
    await BlocProvider.of<SongsDataInfoCubit>(context).getData(
      artistId: appState.artistLoginDataByEmail!.artistDetails.artistUid,
      startDate: startDate,
      endDate: endDate,
    );
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
            text: AppStrings.songInfo2,
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
                  onPressed: () async {
                    await initialCall();
                  },
                  icon: Icon(
                    Icons.sync,
                    size: 25,
                    color: AppColors.white,
                  ),),
            ),
          ],
        ),
        body: BlocBuilder<SongsDataInfoCubit, SongsDataInfoState>(
          builder: (context, state) {
            if (state is! SongsDataInfoLoaded) {
              return const SizedBox();
            }

            final songsInfo = state.songsInformation;
            final totalStreamCount = state.totalStreamCount;
            final monetization = state.monetization;
            final streamsCompletedAfterMonetization =
                state.streamsCompletedAfterMonetization;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 0),
                      child: ListTile(
                        title: AppText(
                          text: AppStrings.monetizationHeading,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          styles: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: AppText(
                          text: AppStrings.monetizationSubText,
                          textAlign: TextAlign.start,
                          maxLines: 4,
                          styles: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          monetization
                              ? Icons.check_circle
                              : Icons.radio_button_off,
                          color: monetization
                              ? AppColors.red
                              : AppColors.dullBlack,
                          size: 22,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ListTile(
                        title: AppText(
                          text:
                              'Need to complete $monetizationCountString songs to complete monetization'
                              '\nOnce the monetization completes will start the revenue based on the songs that are played on top of monetization count'
                              '\nOnce monetization is started your total stream count wil start from 0, Which means from here revenue will starts for each song/stream',
                          textAlign: TextAlign.start,
                          maxLines: 10,
                          styles: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    if (monetization)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: AppText(
                            text: 'Streams Completed\nafter monetization',
                            textAlign: TextAlign.start,
                            styles: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: AppText(
                            text: NumberFormat('#,##0')
                                .format(streamsCompletedAfterMonetization),
                            //'${totalStreamCount}00000000000000',
                            styles: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.bold,),
                          ),
                        ),
                      ),
                    if (monetization)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: AppText(
                            text:
                                'Payments will be based on the above monetization count',
                            textAlign: TextAlign.start,
                            maxLines: 4,
                            styles: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListTile(
                        title: AppText(
                          text: 'Total Streams Completed\n'
                              '${DateFormat('d MMM y').format(DateTime(DateTime.now().year, 1, 1))} to ${DateFormat('d MMM y').format(DateTime.now())}',
                          textAlign: TextAlign.start,
                          styles: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: AppText(
                          text: NumberFormat('#,##0').format(totalStreamCount),
                          //'${totalStreamCount}00000000000000',
                          styles: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                    //<-- Graph system -->/
                    graphData(songsInfo),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomNavBarAd(),
      ),
    );
  }

  Widget graphData(List<Datum> songsInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 30),
          child: AppText(
            text: 'Monthly data',
            styles: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: width,
          height: 200,
          color: Colors.transparent,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              isInversed: true,
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<Datum, String>>[
              ColumnSeries(
                width: 0.09,
                dataSource: songsInfo,
                color: AppColors.redAccent,
                xValueMapper: (Datum sales, _) => DateFormat('MMM')
                    .format(DateTime.parse(sales.createdAt.toString())),
                yValueMapper: (Datum sales, _) => sales.streamCount,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
              LineSeries(
                width: 0.6,
                dataSource: songsInfo,
                color: AppColors.redAccent,
                xValueMapper: (Datum sales, _) => DateFormat('MMM')
                    .format(DateTime.parse(sales.createdAt.toString())),
                yValueMapper: (Datum sales, _) => sales.streamCount,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget dayGraphData() {
    return BlocBuilder<SongsDataInfoCubit, SongsDataInfoState>(
      bloc: BlocProvider.of(context)
        ..getData(
          artistId: appState.artistLoginDataByEmail!.artistDetails.artistUid,
          startDate: startDate,
          endDate: endDate,
        ),
      builder: (context, state) {
        if (state is! SongsDataInfoLoaded) {
          return const SizedBox();
        }

        final songsInfo = state.songsInformation;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 30),
              child: AppText(
                text: 'Monthly data',
                styles: GoogleFonts.manrope(),
              ),
            ),
            Container(
              width: width,
              height: 200,
              color: Colors.transparent,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  isInversed: true,
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<Datum, String>>[
                  ColumnSeries(
                    width: 0.09,
                    dataSource: songsInfo,
                    color: AppColors.redAccent,
                    xValueMapper: (Datum sales, _) => DateFormat('MMM')
                        .format(DateTime.parse(sales.createdAt.toString())),
                    yValueMapper: (Datum sales, _) => sales.streamCount,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  LineSeries(
                    width: 0.6,
                    dataSource: songsInfo,
                    color: AppColors.redAccent,
                    xValueMapper: (Datum sales, _) => DateFormat('MMM')
                        .format(DateTime.parse(sales.createdAt.toString())),
                    yValueMapper: (Datum sales, _) => sales.streamCount,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// class _SalesData {
//   _SalesData(this.year, this.sales);
//
//   final String year;
//   final double sales;
// }
