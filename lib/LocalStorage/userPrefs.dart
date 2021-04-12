import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {


  Future<bool> setLoggedIn(bool loggedin) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('LoggedIn', loggedin);
  }

  Future<bool> getLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('LoggedIn');
  }


  Future<bool> setLoctndetls(String locationdetails) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('locationdetails', locationdetails);

  }

  Future<String> getLoctndetls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('locationdetails');
  }

  Future<bool> setUserdetls(String userDetails) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('userDetails', userDetails);
  }

  Future<String> getUserdetls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userDetails');
  }


  Future<bool> setdeviceToken(String userDetails) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('deviceToken', userDetails);
  }

  Future<String> getdeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceToken');
  }


  Future<bool> setFavCount(int  favCount) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt('favCount', favCount);
  }

  Future<int> getFavCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('favCount');
  }

  Future<bool> setIsEnteredmobileNo(bool enteredmobileNo) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isenteredmobileNo', enteredmobileNo);

  }

  Future<bool> getIsEnteredmobileNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isenteredmobileNo');
  }

  Future<bool> setMobileNo(String userDetails) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('mobileNumber', userDetails);
  }

  Future<String> getMobileNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobileNumber');
  }
}
