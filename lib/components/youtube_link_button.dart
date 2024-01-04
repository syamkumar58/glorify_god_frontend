import 'dart:developer';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class YoutubeLinkButton extends StatelessWidget {
  const YoutubeLinkButton(
      {Key? key,
      required this.ytTitle,
      required this.ytImage,
      required this.ytUrl})
      : super(key: key);

  final String ytTitle;
  final String ytImage;
  final String ytUrl;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.9,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
              text: 'Watch video',
              styles: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(
            height: 12,
          ),
          ListTile(
            tileColor: Colors.blueGrey.withOpacity(0.3),
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            // leading: CircleAvatar(
            //   backgroundColor: AppColors.dullBlack.withOpacity(0.3),
            //   backgroundImage: NetworkImage(
            //     ytImage,
            //   ),
            // ),
            title: AppText(
              text: ytTitle,
              textAlign: TextAlign.left,
              styles: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const AppText(
              text: 'Sub-title',
              textAlign: TextAlign.left,
              styles: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
            onTap: () async {
              log(ytUrl, name: 'The url');
              // await browser.open(url: Uri.parse(ytUrl)).catchError((onError) {
              //   log(onError.toString(), name: 'Error On opening the browser ');
              // });

              if (await canLaunchUrlString(ytUrl)) {
                await launchUrlString(ytUrl);
              } else {
                log('',name: 'Error On opening the browser ');
              }
            },
          ),
        ],
      ),
    );
  }
}
