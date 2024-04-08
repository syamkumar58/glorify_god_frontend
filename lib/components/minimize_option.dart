import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/utils/app_colors.dart';

class MinimizeOption extends StatelessWidget {
  const MinimizeOption({super.key, required this.youtubePlayerHandler});

  final YoutubePlayerHandler youtubePlayerHandler;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 50),
      onPressed: () {
        if (youtubePlayerHandler.extendToFullScreen) {
          youtubePlayerHandler.extendToFullScreen = false;
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppColors.black.withOpacity(0.5),
        ),
        child: Center(
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}
