import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glorify_god/provider/app_state.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CenterPlayIcon extends StatefulWidget {
  const CenterPlayIcon({
    super.key,
    required this.imageProvider,
    this.audioStarted = false,
  });

  final bool audioStarted;

  final ImageProvider imageProvider;

  @override
  State<CenterPlayIcon> createState() => _CenterPlayIconState();
}

class _CenterPlayIconState extends State<CenterPlayIcon>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  AppState appState = AppState();

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Container(
      width: Platform.isAndroid ? 50 : 60,
      height: Platform.isAndroid ? 50 : 60,
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppColors.darkGreyBlue,
        image: DecorationImage(
          opacity: widget.audioStarted ? 0.5 : 1,
          image: widget.imageProvider,
          fit: BoxFit.contain,
        ),
        border: Border.all(
          color: widget.audioStarted ? AppColors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: widget.audioStarted
          ? Center(
              child: appState.audioPlayer.playing
                  ? Lottie.asset(
                      LottieAnimations.musicAnimation,
                      controller: animationController,
                      height: 20,
                      width: 40,
                      fit: BoxFit.fill,
                    )
                  : Icon(
                      Icons.play_arrow,
                      size: 30,
                      color: AppColors.white,
                    ),
            )
          : const SizedBox(),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
