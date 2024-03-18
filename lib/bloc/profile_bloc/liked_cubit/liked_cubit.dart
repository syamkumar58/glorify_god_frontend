import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:glorify_god/models/get_favourites_model.dart';
import 'package:glorify_god/src/api/api_calls.dart';
import 'package:meta/meta.dart';

part 'liked_state.dart';

class LikedCubit extends Cubit<LikedState> {
  LikedCubit() : super(LikedInitial());

  Future<void> likedSongs(int userId) async {
    final data = await ApiCalls().getFavourites(userId: userId);

    if (data != null && data.statusCode == 200) {
      log(data.body,name:'Check the fav body');
      final likedSongs = getFavouritesModelFromJson(data.body);
      emit(LikedLoaded(likedSongs: likedSongs));
    } else {
      emit(LikedLoaded(likedSongs: const []));
    }
  }
}
