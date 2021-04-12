

import 'package:FarmToHome/bloc/searchproduct/search_event.dart';
import 'package:FarmToHome/bloc/searchproduct/search_state.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_event.dart';
import 'package:FarmToHome/bloc/subcategories/subcategories_state.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/subcategories_response_model.dart';
import 'package:FarmToHome/data/repository/searchproduct_repository.dart';
import 'package:FarmToHome/data/repository/subcategories_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class SubCategoriesBloc extends Bloc<SubCategoriesEvent, SubCategoriesState> {

  SubcategoriesRepository repository;

  SubCategoriesBloc({@required this.repository}): super(SubCategoriesInitialState());

  @override
  // TODO: implement initialState
  SubCategoriesState get initialState => SubCategoriesInitialState();

  @override
  Stream<SubCategoriesState> mapEventToState(SubCategoriesEvent event) async* {
    if (event is FetchSubCategoriesEvent) {
      yield SubCategoriesLoadingState();
      try {
        List<SubcategoriesData> list = await repository.getSubcategories(event.userID,event.locID,event.category);
        yield SubCategoriesLoadedState(list: list);
      } catch (e) {
        yield SubCategoriesErrorState(message: e.toString());
      }
    }


    if (event is AddRemoveFavouriteEvent) {
      yield SubCategoriesLoadingState();
      try {
        List<FavouriteData> favouriteData= await repository.addFavourite(event.userID,event.id,event.status);
        yield AddRemoveFavouriteLoadedState(favouriteData: favouriteData);
      } catch (e) {
        yield SubCategoriesErrorState(message: e.toString());
      }
    }

  }

}