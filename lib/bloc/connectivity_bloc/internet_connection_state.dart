part of 'internet_connection_cubit.dart';

@immutable
abstract class InternetConnectionState {}

class InternetConnectionInitial extends InternetConnectionState {}

class InternetConnection extends InternetConnectionState {
  InternetConnection({required this.connectivityResult});

  /// connectivityResult
  final ConnectivityResult connectivityResult;
}
