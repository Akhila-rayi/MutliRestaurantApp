

import 'package:FarmToHome/bloc/myfavourite/myfavourite_state.dart';
import 'package:FarmToHome/bloc/profile/profile_event.dart';
import 'package:FarmToHome/bloc/profile/profile_state.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:FarmToHome/data/repository/profile_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  ProfileRepository repository;

  ProfileBloc({@required this.repository}): super(ProfileInitialState());

  @override
  // TODO: implement initialState
  ProfileState get initialState => ProfileInitialState();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfileEvent) {
      yield ProfileLoadingState();
      try {
        List<ProfileData> myprofile = await repository.getprofile(event.userID);
        yield ProfileLoadedState(myprofile: myprofile);
      } catch (e) {
        yield ProfileErrorState(message: e.toString());
      }
    }

    if (event is SubmitProfileEvent) {
      yield ProfileLoadingState();
      try {
        List<EditProfileData> editprofilelist = await repository.submitprofile(event.profilemap);
        yield EditProfileLoadedState(editprofilelist:editprofilelist);
      } catch (e) {
        yield ProfileErrorState(message: e.toString());
      }
    }
  }

}