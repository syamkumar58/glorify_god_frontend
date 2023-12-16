import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';

class YoutubeLinkButton extends StatelessWidget {
  const YoutubeLinkButton({Key? key}) : super(key: key);

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
            leading: const CircleAvatar(),
            title: const AppText(
              text: 'Title',
              textAlign: TextAlign.left,
              styles: TextStyle(
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
          ),
        ],
      ),
    );
  }
}
