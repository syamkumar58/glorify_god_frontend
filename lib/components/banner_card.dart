import 'package:flutter/material.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_strings.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          width: width,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(15),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1561448817-bb90ab1327b5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2070&q=80',
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: const Column(
            children: [
              AppText(
                  text: AppStrings.proverbs1224,
                  maxLines: 4,
                  textAlign: TextAlign.start,
                  styles: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 2,
                  )),
              AppText(
                  text: AppStrings.proverbsMessage,
                  maxLines: 4,
                  styles: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    height: 2,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
