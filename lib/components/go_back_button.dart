import 'package:flutter/material.dart';

class GoBackButton extends StatelessWidget {
  const GoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_back_ios,
      color: Colors.white,
    );
  }
}
