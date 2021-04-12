
import 'package:equatable/equatable.dart';
import 'package:FarmToHome/data/model/editprofile_response_model.dart';
import 'package:FarmToHome/data/model/favourite_response_model.dart';
import 'package:FarmToHome/data/model/home_response_model.dart';
import 'package:FarmToHome/data/model/profile_response_model.dart';
import 'package:meta/meta.dart';

abstract class ProfileState extends Equatable {}

class ProfileInitialState extends ProfileState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProfileLoadingState extends ProfileState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProfileLoadedState extends ProfileState {

  List<ProfileData> myprofile;

  ProfileLoadedState({@required this.myprofile});

  @override
  // TODO: implement props
  List<Object> get props => [myprofile];
}



class EditProfileLoadedState extends ProfileState {

  List<EditProfileData> editprofilelist;

  EditProfileLoadedState({@required this.editprofilelist});

  @override
  // TODO: implement props
  List<Object> get props => [editprofilelist];
}



class ProfileErrorState extends ProfileState {

  String message;

  ProfileErrorState({@required this.message});

  @override
  // TODO: implement props
  List<Object> get props => [message];
}