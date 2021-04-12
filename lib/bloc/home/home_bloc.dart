
import 'package:FarmToHome/bloc/home/home_event.dart';
import 'package:FarmToHome/bloc/home/home_state.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/feedbackservices_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/previousorders_response_model.dart';
import 'package:FarmToHome/data/repository/home_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeRepository repository;

  HomeBloc({@required this.repository}) : super(HomeInitialState());

  @override
  // TODO: implement initialState
  HomeState get initialState => HomeInitialState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {

    if (event is FetchHomeEvent) {
      yield HomeLoadingState();
      try {
        List<HomeData> homedata= await repository.getHomedata(event.userID,event.locationID);
        yield HomeLoadedState(homedata: homedata);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

    if (event is AddRemoveFavouriteEvent) {
      yield HomeLoadingState();
      try {
        List<FavouriteData> favouriteData= await repository.addFavourite(event.userID,event.id,event.status);
        yield AddRemoveFavouriteLoadedState(favouriteData: favouriteData);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

    if (event is FetchPreviousordersEvent) {
      yield HomeLoadingState();
      try {
        List<Previousordersdetails> list= await repository.getPreviousorders(event.userID);
        yield PreviousordersLoadedState(list: list);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

    if (event is SubmitFeedbackEvent) {
      yield HomeLoadingState();
      try {
        List<EditProfileData> feedbckData = await repository.submitFeedback(event.feedbackMap);
        yield SubmitFeedbackLoadedState(feedbckData:feedbckData);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

    if (event is FetchfeedbackservicesEvent) {
      yield HomeLoadingState();
      try {
        List<FeedbackservicesData> feedbackservicesData = await repository.getFeedbackservices();
        yield FetchFeedbackservicesLoadedState(feedbackservicesData: feedbackservicesData);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

    if (event is FetchFavouritesEvent) {
      yield HomeLoadingState();
      try {
        List<TodaySpecial> myfavlist= await repository.fetchFavouritelist(event.userID);
        yield FetchFavouritesLoadedState(myfavlist: myfavlist);
      } catch (e) {
        yield HomeErrorState(message: e.toString());
      }
    }

  }

}