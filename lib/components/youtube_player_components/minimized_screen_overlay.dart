import 'package:flutter/material.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/provider/youtube_player_handler.dart';
import 'package:glorify_god/utils/app_colors.dart';

class MinimizedScreenOverLay extends StatelessWidget {
  const MinimizedScreenOverLay({super.key, required this.youtubePlayerHandler, required this.appState});

  final YoutubePlayerHandler youtubePlayerHandler;
   final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      decoration: BoxDecoration(
        // color: AppColors.red,
        color: AppColors.black.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // appState.positionXRatio = 0.45;
                // appState.positionYRatio = 0.57;
                youtubePlayerHandler.extendToFullScreen =
                    !youtubePlayerHandler.extendToFullScreen;
              },
              icon: Icon(
                Icons.north_west,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (youtubePlayerHandler
                    .youtubePlayerController!.value.isPlaying) {
                  youtubePlayerHandler.youtubePlayerController!.pause();
                } else {
                  youtubePlayerHandler.youtubePlayerController!.play();
                }
              },
              icon: Icon(
                youtubePlayerHandler.youtubePlayerController!.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_arrow,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                youtubePlayerHandler.youtubePlayerController!.dispose();
                youtubePlayerHandler.youtubePlayerController = null;
              },
              icon: Icon(
                Icons.close,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
