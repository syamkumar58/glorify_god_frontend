part of 'ads_cubit.dart';

@immutable
abstract class AdsState {}

class AdsInitial extends AdsState {}
class AdsLoading extends AdsState {}
class AdsLoaded extends AdsState {
  AdsLoaded({required this.bannerAd});
  final BannerAd bannerAd;

}
class AdsError extends AdsState {}