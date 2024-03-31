import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:glorify_god/bloc/all_songs_cubit/all_songs_cubit.dart';
import 'package:glorify_god/bloc/artists_list_cubit/artists_list_cubit.dart';
import 'package:glorify_god/components/noisey_text.dart';
import 'package:glorify_god/models/artists_model/artists_list_model.dart';
import 'package:glorify_god/utils/app_colors.dart';
import 'package:glorify_god/utils/asset_images.dart';
import 'package:glorify_god/utils/hive_keys.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

Future artistsOrderOptionsSheet({required BuildContext context}) async {
  return showModalBottomSheet<dynamic>(
    context: context,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    builder: (ctx) {
      return UsersChoiceComponent(
        ctx: ctx,
      );
    },
  );
}

class UsersChoiceComponent extends StatefulWidget {
  const UsersChoiceComponent({super.key, required this.ctx});

  final BuildContext ctx;

  @override
  State<UsersChoiceComponent> createState() => _UsersChoiceComponentState();
}

class _UsersChoiceComponentState extends State<UsersChoiceComponent> {
  Box? box;

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  List<int> selectedIds = [];

  bool loading = false;

  @override
  void initState() {
    box = Hive.box<dynamic>(HiveKeys.openBox);
    super.initState();
    getStoredList();
  }

  Future getStoredList() async {
    final dynamic getStoreSelectedArtistIds =
        await box!.get(HiveKeys.storeSelectedArtistIds);
    if (getStoreSelectedArtistIds != null) {
      final decodedList =
          json.decode(getStoreSelectedArtistIds) as List<dynamic>;
      final storedList =
          decodedList.map((e) => int.parse(e.toString())).toList();
      log(
        '$getStoreSelectedArtistIds && ${json.decode(getStoreSelectedArtistIds)}',
        name: 'check store list for filter',
      );
      setState(() {
        selectedIds.clear();
        selectedIds.addAll(storedList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: const CupertinoActivityIndicator(),
      child: BlocProvider(
        create: (context) => ArtistsListCubit(),
        child: Builder(
          builder: (context) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.darkGreyBlue2,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.only(top: 25, bottom: 25),
              child: SafeArea(
                child: BlocBuilder<ArtistsListCubit, ArtistsListState>(
                  bloc: BlocProvider.of(context)..getArtistsList(),
                  builder: (context, state) {
                    if (state is! ArtistsListLoaded) {
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }

                    final artistsList = state.artistsList;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleBar(),
                        artists(artistsList: artistsList),
                        doneButton(),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget titleBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pop(widget.ctx);
        },
        icon: Icon(
          Icons.close,
          size: 21,
          color: AppColors.white,
        ),
      ),
      title: AppText(
        text: 'Choose Artists you like',
        // textAlign: TextAlign.center,
        styles: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget artists({required List<ArtistsListModel> artistsList}) {
    return Container(
      height: height * 0.8,
      width: width,
      color: Colors.transparent,
      alignment:
          artistsList.length > 3 ? Alignment.topLeft : Alignment.topCenter,
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: artistsList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final e = artistsList[index];
          return Bounce(
            duration: const Duration(milliseconds: 50),
            onPressed: () {
              if (selectedIds.contains(e.artistUid)) {
                selectedIds.remove(e.artistUid);
              } else {
                selectedIds.add(e.artistUid);
              }
              setState(() {});
            },
            child: SizedBox(
              width: 110,
              height: 150,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.appColor1,
                      borderRadius: BorderRadius.circular(50),
                      image: e.artistImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(e.artistImage),
                            )
                          : DecorationImage(
                              image: AssetImage(AppImages.appWhiteIcon),
                            ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.check_circle,
                        size: 25,
                        color: selectedIds.contains(e.artistUid)
                            ? AppColors.white
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  AppText(
                    text: e.artistName,
                    maxLines: 2,
                    styles: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget doneButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: selectedIds.isNotEmpty ? _onSelected : null,
      child: Container(
        width: width * 0.7,
        height: 45,
        decoration: BoxDecoration(
          color: selectedIds.isNotEmpty
              ? AppColors.darkGreyBlue
              : AppColors.darkGreyBlue.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AppText(
            styles: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: selectedIds.isNotEmpty
                  ? AppColors.white
                  : AppColors.grey.withOpacity(0.2),
            ),
            text: 'Done',
          ),
        ),
      ),
    );
  }

  Future _onSelected() async {
    setState(() {
      loading = true;
    });
    try {
      final dynamic getStoreSelectedArtistIds =
          await box!.get(HiveKeys.storeSelectedArtistIds);

      if (getStoreSelectedArtistIds != null) {
        await box!.delete(HiveKeys.storeSelectedArtistIds);
        await box!
            .put(HiveKeys.storeSelectedArtistIds, json.encode(selectedIds));
      } else {
        await box!
            .put(HiveKeys.storeSelectedArtistIds, json.encode(selectedIds));
      }

      await BlocProvider.of<AllSongsCubit>(context)
          .getAllSongs(selectedList: selectedIds);
      setState(() {
        loading = false;
      });
    } catch (er) {
      setState(() {
        loading = false;
      });
    }
    Navigator.pop(widget.ctx);
  }
}
