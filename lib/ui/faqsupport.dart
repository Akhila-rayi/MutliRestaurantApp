

import 'package:FarmToHome/ui/FAQs.dart';
import 'package:FarmToHome/ui/privacypolicy.dart';
import 'package:FarmToHome/ui/terms_conditions.dart';
import 'package:flutter/material.dart';

class FAQSupport extends StatefulWidget {
  @override
  FAQSupportState createState() {
    return FAQSupportState();
  }
}

class FAQSupportState extends State<FAQSupport> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "FAQs & Support",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .apply(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            backgroundColor: Colors.white,
            body:ListView(
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.help,
                          color: Colors.black38,
                          size: 20,
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'FAQs',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black54,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => FAQs()));
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.assignment,
                          color: Colors.black38,
                          size: 20,
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black54,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  onTap: () {

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => TermsConditions()));
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.view_headline,
                          color: Colors.black38,
                          size: 20,
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black54,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  onTap: () {

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PrivacyPolicy()));
                  },
                ),


              ],
            ) ));
  }
}
