import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> list = [
    {
      'heading': 'Followers',
      'count': 0,
    },
    {
      'heading': 'Total seconds',
      'count': 56040,
    },
    {
      'heading': 'Total minutes',
      'count': 934,
    },
    {
      'heading': 'Total hours',
      'count': 15.34,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(
        'WALLET',
      ),
      body: GridView.builder(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3,
        ),
        itemBuilder: (context, index) {
          final data = list[index];
          return Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dullBlack.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: '${data['heading']}',
                  styles: GoogleFonts.manrope(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.dullWhite,
                  ),
                ),
                AppText(
                  text: '${data['count']}',
                  styles: GoogleFonts.manrope(),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 200,
        padding:
            const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 40),
        decoration: BoxDecoration(
          color: AppColors.dullBlack.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                dense: true,
                title: AppText(
                  text: 'Earned',
                  textAlign: TextAlign.start,
                  styles: GoogleFonts.manrope(
                    fontSize: 16,
                    color: AppColors.dullWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: AppText(
                  text: '1234567890987654321234',
                  textAlign: TextAlign.start,
                  styles: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  decoration: BoxDecoration(
                      color: AppColors.blueAccent,
                      borderRadius: BorderRadius.circular(8)),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: AppText(
                      text: 'Withdraw Amout',
                      styles: GoogleFonts.manrope(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
