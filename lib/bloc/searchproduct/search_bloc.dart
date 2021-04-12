

import 'package:FarmToHome/bloc/searchproduct/search_event.dart';
import 'package:FarmToHome/bloc/searchproduct/search_state.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/repository/searchproduct_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {

  SearchProductRepository repository;

  SearchBloc({@required this.repository}): super(SearchProductInitialState());

  @override
  // TODO: implement initialState
  SearchState get initialState => SearchProductInitialState();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is FetchSearchProductEvent) {
      yield SearchProductLoadingState();
      try {
        List<TodaySpecial> list = await repository.getProducts(event.userID,event.query);
        yield SearchProductLoadedState(list: list);
      } catch (e) {
        yield SearchProductErrorState(message: e.toString());
      }
    }

    if (event is AddDelFavouriteEvent) {
      yield SearchProductLoadingState();
      try {
        List<FavouriteData> favouriteData= await repository.adddelFavourite(event.userID,event.id,event.status);
        yield AdddelFavouriteLoadedState(favouriteData: favouriteData);
      } catch (e) {
        yield SearchProductErrorState(message: e.toString());
      }
    }

  }

}