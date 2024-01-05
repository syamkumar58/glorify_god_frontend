import 'package:glorify_god/components/custom_app_bar.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatefulWidget {
  /// const
  const ExploreScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar('EXPLORE'),
      body: Center(
        child: AppText(
          text: 'Coming Soon',
          styles: GoogleFonts.manrope(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
