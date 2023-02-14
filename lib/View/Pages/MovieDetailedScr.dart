import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:moshahda_app/Models/MovieModel.dart';
import 'package:moshahda_app/View/Pages/viedioPlyerScr.dart';
import 'package:moshahda_app/ViewModel/Database/local/SQFlightHelper.dart';

import '../../ViewModel/Cupits/HomeCupit/home_cubit.dart';
import '../../ViewModel/admobAdsManger.dart';
import 'desktopWebView.dart';

class MovieDetailedScr extends StatefulWidget {
  MovieModel movie;
  MovieDetailedScr(this.movie);

  @override
  State<MovieDetailedScr> createState() => _MovieDetailedScrState();
}

class _MovieDetailedScrState extends State<MovieDetailedScr> {
  BannerAd? banner;
  RewardedAd? rewardedAd;

  void createBannerAd() {
    banner = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdsManger.bannerAdUnit,
        listener: AdsManger.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdsManger.rewardedAdUnit,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => setState(() => rewardedAd = ad),
            onAdFailedToLoad: (error) => setState(
                  () {
                    debugPrint(error.message);
                    rewardedAd = null;
                  },
                )));
  }

  void showRewardedAd({required Function afterReward}) {
    if (rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      setState(() {
        createRewardedAd();
      });
      return;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        afterReward;
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd();
      },
    );

    rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      afterReward.call();
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    rewardedAd = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createBannerAd();
    createRewardedAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var cupit = HomeCubit.get(context);

          return Scaffold(
            backgroundColor: const Color.fromARGB(1000, 11, 10, 28),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: widget.movie.img!,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Container(
                          height: 500,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                const Color.fromARGB(1000, 11, 10, 28)
                                    .withOpacity(0.60),
                                const Color.fromARGB(1000, 11, 10, 28)
                                    .withOpacity(0.0),
                              ],
                                  end: Alignment.topCenter,
                                  begin: Alignment.bottomCenter))),
                      //back button
                      Positioned(
                          top: 20,
                          child: IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: Color.fromARGB(1000, 11, 10, 28),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                      //play button
                      Positioned(
                          top: 370,
                          left: 310,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Color(0xff1f005c),
                                    Color(0xff5b0060),
                                    Color(0xff870160),
                                    Color(0xffac255e),
                                    Color(0xffca485c),
                                    Color(0xffe16b5c),
                                    Color(0xfff39060),
                                    Color(0xffffb56b),
                                  ],
                                )),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.play,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (!Platform.isWindows) {
                                    showRewardedAd(afterReward: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VideoPlayerScr(
                                                    widget.movie.link!)),
                                      );
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DesktopWebView(
                                              widget.movie.link!)),
                                    );
                                  }
                                },
                              ),
                            ),
                          )),
                      Positioned(
                        left: 10,
                        top: 410,
                        child: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.name!,
                                style: GoogleFonts.roboto(
                                    color: Colors.white, fontSize: 24),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Date: ${widget.movie.dateTime} ",
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  if (banner != null)
                    Container(
                        height: 100, width: 400, child: AdWidget(ad: banner!)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.movie.description!,
                      style:
                          GoogleFonts.roboto(color: Colors.white, fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  cupit.FavoriteMoviestoDB(widget.movie);
                  // print(cupit.favoriteMovies.toString());
                },
                backgroundColor: Colors.grey.withOpacity(0.2),
                child: Icon(
                  Icons.favorite,
                  size: 40,
                  color: (HomeCubit.favoriteMovies
                          .containsKey('${widget.movie.name}'))
                      ? Colors.redAccent
                      : Colors.grey[300]!.withOpacity(0.2),
                )),
          );
        },
      ),
    );
  }
}
