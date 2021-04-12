import 'dart:convert';

import 'package:FarmToHome/LocalStorage/userPrefs.dart';
import 'package:FarmToHome/data/model/location_response_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:html/parser.dart';

class Apputils {
  BuildContext buildContext;

  /*showLoaderDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        buildContext = context;
        return WillPopScope(
          onWillPop: () {},
          child: new AlertDialog(
            content: new Row(
              children: [
                CircularProgressIndicator(),
                Container(
                    margin: EdgeInsets.only(left: 7),
                    child: Text("Loading...")),
              ],
            ),
          ),

          */ /*new AlertDialog(    // two buttons dialog
          title: new Text('Title'),
          content: new Text('This is Demo'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                //Function called
              },
              child: new Text('Ok Done!'),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('Go Back'),
            ),
          ],
        ),*/ /*
        );
      },
    );
  }*/
/*
  dismissProgrsdlg() {
    if (buildContext != null) {
      Navigator.of(buildContext).pop();
    }
  }*/
/*
  dismissPrgrsfromroot() {
    Navigator.of(buildContext, rootNavigator: true).pop();
  }*/

  String getCurrentdate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  bool allowOrder(LocationDetls _locationDetls) {

    if (_locationDetls != null) {

      debugPrint("@@@ opentime "+ _locationDetls.OpenTime.toString());

      var splitopentime = _locationDetls.OpenTime.toString().split(":");
      var splitclosetime = _locationDetls.closeTime.toString().split(":");
      String opentime = splitopentime[0] + ":" + splitopentime[1];
      String closetime = splitclosetime[0] + ":" + splitclosetime[1];
      var now = new DateTime.now();
      var formatter = new DateFormat('HH:mm');
      String formattedtime = formatter.format(now);
      debugPrint("@@@ CURRENT TIME" + formattedtime);

      DateTime mintime = formatter.parse(opentime);
      var open = new DateTime(
          now.year, now.month, now.day, mintime.hour, mintime.minute);
      DateTime maxtime = formatter.parse(closetime);
      var close = new DateTime(
          now.year, now.month, now.day, maxtime.hour, maxtime.minute);

      if (now.isBefore(close) && now.isAfter(open)) {
        return true;
      }
      return false;

    } else {

      return false;
    }

  }

   String twelvehrformat_time(String given_time) {

    // format hh:mm aa
    List<String> splittime = given_time.split(":");
    int hr = int.parse(splittime[0]);
    int min = int.parse(splittime[1]);
    int sec = int.parse(splittime[2]);
    String ampm = "AM";

    String new_hr = "", new_min = "", new_sec = "";

    if (hr >= 13 && hr <= 23) {

      hr = hr - 12;
      ampm = "PM";
    }
    if (hr == 12) {

      ampm = "PM";
    }
    if (hr == 0) {

      hr = 12;
      ampm = "AM";
    }

    if (hr < 10) {

      new_hr = "0" + hr.toString();
    } else {

      new_hr = hr.toString() + "";
    }


    if (min < 10) {

      new_min = "0" + min.toString();
    } else {

      new_min = min.toString() + "";
    }
    return new_hr + ":" + new_min + " " + ampm;
  }

  String reformatDate(String given_date) {

    // format DD-MM-YYYY
    List<String> splittime = given_date.split("-");
    int year = int.parse(splittime[0]);
    int month = int.parse(splittime[1]);
    int day = int.parse(splittime[2]);

    String new_day = "$day", new_month = "$month", new_yr = "$year";

    if(day<10 && day>0){
      new_day="0$day";
    }

    if(month<10 && month>0){
      new_month="0$month";
    }

    return "$new_day-$new_month-$new_yr";
  }

  void showtoast(BuildContext context, String s) {
    Toast.show(
      s,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      textColor: Colors.white,
      backgroundRadius: 5,
      backgroundColor: Colors.red,
      border: Border.all(color: const Color(0xFF009A00), width: 1.0),
    );
  }

  bool equalsIgnoreCase(String a, String b) =>
      (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  String date_newformat(String given_date) {
    //returns  format: dd monthname yyyy

    List<String> splitdate = given_date.split("-");
    int day = int.parse(splitdate[2]);
    int month = int.parse(splitdate[1]);
    int year = int.parse(splitdate[0]);
    String new_day = day.toString();
    String new_month = "";
    String new_year = year.toString();
    switch (month) {
      case 1:
        new_month = "Jan";
        break;
      case 2:
        new_month = "Feb";
        break;
      case 3:
        new_month = "Mar";
        break;
      case 4:
        new_month = "Apr";
        break;
      case 5:
        new_month = "May";
        break;
      case 6:
        new_month = "Jun";
        break;
      case 7:
        new_month = "Jul";
        break;
      case 8:
        new_month = "Aug";
        break;
      case 9:
        new_month = "Sep";
        break;
      case 10:
        new_month = "Oct";
        break;
      case 11:
        new_month = "Nov";
        break;
      case 12:
        new_month = "Dec";
        break;
      default:
        new_month = "Jan";
        break;
    }
    return new_day + " " + new_month + " " + new_year;
  }

  String getDayNumberSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  Widget buildLoading(BuildContext context) {
    return Center(
        child: Card(
            color: const Color(0xFF009A00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            )));
  }

  Widget buildLoadinginitial(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
            child: Card(
                color: const Color(0xFF009A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 5.0,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ))));
  }

  Widget buildErrorUi(String message, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .apply(color: Colors.red),
            ),
          ),
        ));
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  showNoticeDialog(BuildContext context, String msg) {
    // set up the buttons

    Widget continueButton = FlatButton(
      child: Text("OK",
          style: Theme.of(context)
              .textTheme
              .headline5
              .apply(color: const Color(0xFF009A00))),
      onPressed: () {
        dismissProgrsdlg(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "FarmToHome",
        textAlign: TextAlign.center,

      ),
      content: Text(
          msg),
      actions: [continueButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              dismissProgrsdlg(context);
            },
            child: alert);
      },
    );
  }


  dismissProgrsdlg(context) {
    Navigator.of(context).pop();
  }
}
