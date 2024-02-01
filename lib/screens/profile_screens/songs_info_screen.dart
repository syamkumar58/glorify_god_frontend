
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glorify_god/bloc/profile_bloc/songs_info_cubit/songs_data_info_cubit.dart';
import 'package:glorify_god/components/custom_nav_bar_ad.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/profile_models/tracker_model.dart';
import 'package:glorify_god/models/song_models/artists_song_data_by_id.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
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

  // List<_SalesData> data = [
  //   _SalesData('Jan', 35),
  //   _SalesData('Feb', 28),
  //   _SalesData('Mar', 34),
  //   _SalesData('Apr', 32),
  //   _SalesData('May', 40),
  //   _SalesData('Jun', 10),
  //   _SalesData('Jul', 23),
  //   _SalesData('Aug', 49),
  //   _SalesData('Sep', 47),
  //   _SalesData('Oct', 50),
  //   _SalesData('Nov', 60),
  //   _SalesData('Dec', 90),
  // ];

  @override
  void initState() {
    appState = context.read<AppState>();
    super.initState();
    // initialCalls();
    BlocProvider.of<SongsDataInfoCubit>(context).getData(artistId: 1);
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
                    BlocProvider.of<SongsDataInfoCubit>(context)
                        .getData(artistId: 1);
                  },
                  icon: Icon(
                    Icons.sync,
                    size: 25,
                    color: AppColors.white,
                  )),
            )
          ],
        ),
        body: BlocBuilder<SongsDataInfoCubit, SongsDataInfoState>(
          builder: (context, state) {
            if (state is! SongsDataInfoLoaded) {
              return const SizedBox();
            }

            final songsInfo = state.songsInformation;
            final totalStreamCount = state.totalStreamCount;

            return SingleChildScrollView(
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ListTile(
                        title: AppText(
                          text: 'Total Songs Completed',
                          textAlign: TextAlign.start,
                          styles: GoogleFonts.manrope(
                            fontSize: 14,
                          ),
                        ),
                        trailing: AppText(
                          text: NumberFormat('#,##0').format(totalStreamCount),
                          //'${totalStreamCount}00000000000000',
                          styles: GoogleFonts.manrope(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 20, bottom: 60),
                    //   child: ListTile(
                    //     title: AppText(
                    //       text: 'Today Completed Songs',
                    //       textAlign: TextAlign.start,
                    //       styles: GoogleFonts.manrope(
                    //         fontSize: 18,
                    //       ),
                    //     ),
                    //     trailing: AppText(
                    //       text: '0',
                    //       styles: GoogleFonts.manrope(
                    //         fontSize: 22,
                    //       ),
                    //     ),
                    //   ),
                    // ),

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
  }

  Widget dayGraphData() {
    return BlocBuilder<SongsDataInfoCubit, SongsDataInfoState>(
      bloc: BlocProvider.of(context)..getData(artistId: 1),
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
