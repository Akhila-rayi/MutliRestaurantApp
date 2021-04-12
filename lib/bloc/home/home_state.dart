
import 'package:FarmToHome/data/model/feedbackservices_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/previousorders_response_model.dart';
import 'package:meta/meta.dart';

abstract class HomeState extends Equatable {}

class HomeInitialState extends HomeState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class HomeLoadingState extends HomeState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class HomeLoadedState extends HomeState {

  List<HomeData> homedata;

  HomeLoadedState({@required this.homedata});

  @override
  // TODO: implement props
  List<Object> get props => [homedata];
}


class AddRemoveFavouriteLoadedState extends HomeState {

  List<FavouriteData> favouriteData;

  AddRemoveFavouriteLoadedState({@required this.favouriteData});

  @override
  // TODO: implement props
  List<Object> get props => [favouriteData];
}


class PreviousordersLoadedState extends HomeState {

  List<Previousordersdetails> list;

  PreviousordersLoadedState({@required this.list});

  @override
  // TODO: implement props
  List<Object> get props => [list];
}


class SubmitFeedbackLoadedState extends HomeState {

  List<EditProfileData> feedbckData;

  SubmitFeedbackLoadedState({@required this.feedbckData});

  @override
  // TODO: implement props
  List<Object> get props => [feedbckData];
}


class FetchFeedbackservicesLoadedState extends HomeState {

  List<FeedbackservicesData> feedbackservicesData;

  FetchFeedbackservicesLoadedState({@required this.feedbackservicesData});

  @override
  // TODO: implement props
  List<Object> get props => [feedbackservicesData];
}

class HomeErrorState extends HomeState {

  String message;

  HomeErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}


class FetchFavouritesLoadedState extends HomeState {

  List<TodaySpecial> myfavlist;

  FetchFavouritesLoadedState({@required this.myfavlist});

  @override
  // TODO: implement props
  List<Object> get props => [myfavlist];
}

