
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:meta/meta.dart';

abstract class MyFavouriteState extends Equatable {}

class MyFavouriteInitialState extends MyFavouriteState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class MyFavouriteLoadingState extends MyFavouriteState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class MyFavouriteLoadedState extends MyFavouriteState {

  List<TodaySpecial> myfavlist;

  MyFavouriteLoadedState({@required this.myfavlist});

  @override
  // TODO: implement props
  List<Object> get props => [myfavlist];
}



class AddRemoveFavouriteLoadedState extends MyFavouriteState {

  List<FavouriteData> favouriteData;

  AddRemoveFavouriteLoadedState({@required this.favouriteData});

  @override
  // TODO: implement props
  List<Object> get props => [favouriteData];
}


class MyFavouriteErrorState extends MyFavouriteState {

  String message;

  MyFavouriteErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}