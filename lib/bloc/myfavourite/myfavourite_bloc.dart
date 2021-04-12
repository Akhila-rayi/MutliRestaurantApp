

import 'package:FarmToHome/bloc/myfavourite/myfavourite_event.dart';
import 'package:FarmToHome/bloc/myfavourite/myfavourite_state.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/repository/myfav_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class MyFavouriteBloc extends Bloc<MyFavouriteEvent, MyFavouriteState> {

  MyFavouriteRepository repository;

  MyFavouriteBloc({@required this.repository}): super(MyFavouriteInitialState());

  @override
  // TODO: implement initialState
  MyFavouriteState get initialState => MyFavouriteInitialState();

  @override
  Stream<MyFavouriteState> mapEventToState(MyFavouriteEvent event) async* {

    if (event is FetchFavouritesEvent) {
      yield MyFavouriteLoadingState();
      try {
        List<TodaySpecial> myfavlist= await repository.fetchFavouritelist(event.userID);
        yield MyFavouriteLoadedState(myfavlist: myfavlist);
      } catch (e) {
        yield MyFavouriteErrorState(message: e.toString());
      }
    }


    if (event is AddRemoveFavouriteEvent) {
      yield MyFavouriteLoadingState();
      try {
        List<FavouriteData> favouriteData= await repository.addFavourite(event.userID,event.id,event.status);
        yield AddRemoveFavouriteLoadedState(favouriteData: favouriteData);
      } catch (e) {
        yield MyFavouriteErrorState(message: e.toString());
      }
    }

  }

}