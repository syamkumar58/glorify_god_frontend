import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

String convertDurations(Duration duration) {
  final convert = duration.inHours > 0
      ? '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString()..padLeft(2, '0')}'
      : '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  return convert;
}

void toastMessage({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    fontSize: 16,
    backgroundColor: AppColors.white,
    textColor: AppColors.black,
    gravity: ToastGravity.SNACKBAR,
  );
}

List<dynamic> songs = [
  {
    'songUrl':
        'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    'id': '0',
    'title': 'First Song',
    'artist': 'syam noisey',
    'artUri':
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
  },
  {
    'songUrl':
        'https://storage.googleapis.com/heartintune-qa-storage/MeditateNow/audios/english/15Min-Checkat7min.m4a',
    'id': '1',
    'title': 'Third Song',
    'artist': 'Daaji',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl': 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
    'id': '2',
    'title': 'Second Song',
    'artist': 'kumar noisey',
    'artUri':
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
  },
  {
    'songUrl':
        'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    'id': '3',
    'title': 'First Song',
    'artist': 'syam noisey',
    'artUri':
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
  },
  {
    'songUrl': 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
    'id': '4',
    'title': 'Second Song',
    'artist': 'kumar noisey',
    'artUri':
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg',
  },
  {
    'songUrl':
        'https://storage.googleapis.com/heartintune-qa-storage/MeditateNow/audios/english/15Min-Checkat7min.m4a',
    'id': '5',
    'title': 'Third Song',
    'artist': 'Daaji',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl':
        'https://glorify-god.s3.ap-south-1.amazonaws.com/songs/BetterDays.mp3',
    'id': '6',
    'title': 'AWS Song',
    'artist': 'Uploaded by syam noisey',
    'artUri':
        'https://i.scdn.co/image/ab67616d0000b273c0412c357933a4a2c6c126a8',
  },
];

List<dynamic> mostPlayedSongsData = [
  {
    'songUrl': 'https://cdn.pixabay.com/audio/2023/02/03/audio_534a89f910.mp3',
    'id': '0',
    'title': 'Easy life style',
    'artist': 'Life style one',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl': 'https://cdn.pixabay.com/audio/2023/02/03/audio_534a89f910.mp3',
    'id': '1',
    'title': 'Easy',
    'artist': 'Life style two',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl':
        'https://cdn.pixabay.com/download/audio/2023/01/23/audio_384c4a93a5.mp3?filename=nature-calls-136344.mp3',
    'id': '2',
    'title': 'Life',
    'artist': 'Life style three',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl':
        'https://cdn.pixabay.com/download/audio/2023/01/23/audio_384c4a93a5.mp3?filename=nature-calls-136344.mp3',
    'id': '3',
    'title': 'Life style',
    'artist': 'Life style four',
    'artUri':
        'https://storage.googleapis.com/heartintune-dev-storage/MeditationBackGround/DevelopFocus.png',
  },
  {
    'songUrl':
        'https://glorify-god.s3.ap-south-1.amazonaws.com/songs/BetterDays.mp3',
    'id': '4',
    'title': 'AWS Song',
    'artist': 'Uploaded by syam noisey',
    'artUri':
        'https://i.scdn.co/image/ab67616d0000b273c0412c357933a4a2c6c126a8',
  },
];

void flushBar({
  required BuildContext context,
  required String messageText,
}) {
  Flushbar(
    backgroundColor: AppColors.white,
    messageText: AppText(
      text: messageText,
      maxLines: 5,
      styles: GoogleFonts.manrope(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}

enum LoginProviders {
  GOOGLE,
  EMAIL,
  PHONENUMBER,
}
