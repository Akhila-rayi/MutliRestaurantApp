
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:meta/meta.dart';

abstract class SearchState extends Equatable {}

class SearchProductInitialState extends SearchState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SearchProductLoadingState extends SearchState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SearchProductLoadedState extends SearchState {

  List<TodaySpecial> list;

  SearchProductLoadedState({@required this.list});

  @override
  // TODO: implement props
  List<Object> get props => [list];
}


class AdddelFavouriteLoadedState extends SearchState {

  List<FavouriteData> favouriteData;

  AdddelFavouriteLoadedState({@required this.favouriteData});

  @override
  // TODO: implement props
  List<Object> get props => [favouriteData];
}


class SearchProductErrorState extends SearchState {

  String message;

  SearchProductErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}