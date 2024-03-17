import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

part 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  InternetConnectionCubit() : super(InternetConnectionInitial());

  Future checkConnection() async {
    Connectivity().onConnectivityChanged.listen((result) {
      log('$result', name: 'checkConnection 3');
      emit(InternetConnection(connectivityResult: result));
    });
  }
}
