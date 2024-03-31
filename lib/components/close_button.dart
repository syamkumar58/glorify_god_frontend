import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/utils/app_colors.dart';

class CloseOption extends StatelessWidget {
  const CloseOption({super.key, required this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 50),
      onPressed: () {
        onPressed();
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppColors.grey.withOpacity(0.5),
        ),
        child: Center(
          child: Icon(
            Icons.close,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
