
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/data/model/subcategories_response_model.dart';
import 'package:meta/meta.dart';

abstract class SubCategoriesState extends Equatable {}

class SubCategoriesInitialState extends SubCategoriesState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SubCategoriesLoadingState extends SubCategoriesState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SubCategoriesLoadedState extends SubCategoriesState {

  List<SubcategoriesData> list;

  SubCategoriesLoadedState({@required this.list});

  @override
  // TODO: implement props
  List<Object> get props => [list];
}




class AddRemoveFavouriteLoadedState extends SubCategoriesState {

  List<FavouriteData> favouriteData;

  AddRemoveFavouriteLoadedState({@required this.favouriteData});

  @override
  // TODO: implement props
  List<Object> get props => [favouriteData];
}

class SubCategoriesErrorState extends SubCategoriesState {

  String message;

  SubCategoriesErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}