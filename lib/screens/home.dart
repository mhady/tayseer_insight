import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import '../globals.dart';
import './sura_subpage.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

/* 
var focusNode = FocusNode();
var textField = TextField(focusNode: focusNode);

FocusScope.of(context).requestFocus(focusNode);
// or 
focusNode.requestFocus();
*/

class HomeState extends State<Home> {
  bool data_ready = false;
  @override
  void initState() {
    getQare2();
    getShwahed();
    _asyncMethod();
  }

  _asyncMethod() async {
    // print('getAyaTextList called  ');
    await globals.LoadData().getAyaTextList();
    setState(() {
      data_ready = true;
      // print('getAyaTextList end  ');
      // print(globals.AyaTextList);
    });
  }

  void suraSubpage(int value) {
    RequiredSura requiredSura = new RequiredSura(id: value);
    Navigator.pushNamed(context, 'suraSubpage', arguments: requiredSura);
  }

  Future loadShwahedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('shawahed_setting');
  }

  void getShwahed() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? _myshawahed = null; //prefs.getStringList('shawahed_setting');

    loadShwahedData().then((data) {
      setState(() {
        _myshawahed = data;
      });
    });

    if (_myshawahed != null && _myshawahed!.length > 0) {
      // exist in saved preferences
      if (globals.myshawahed.length == 0) //not loaded
      {
        for (String i in _myshawahed!) {
          var item = List<Map>.from(jsonDecode("[" + i + "]") as List);
          globals.myshawahed.add({
            'type': item[0]['type'],
            'value': item[0]['value'],
            'selected': item[0]['selected']
          });
        }
      }
    } else {
      if (globals.myshawahed.length == 0) //not loaded
      {
        globals.myshawahed.add(
            {"type": "elsab3", "value": "شواهد السبع", "selected": "true"});
        globals.myshawahed.add(
            {"type": "elthalath", "value": "شواهد الثلاث", "selected": "true"});
        globals.myshawahed.add(
            {"type": "ershadat", "value": " متشابهات", "selected": "true"});
        globals.myshawahed
            .add({"type": "twgeh", "value": "توجيهات", "selected": "true"});
        globals.myshawahed
            .add({"type": "3adAlay", "value": "عد الآي", "selected": "true"});
      }
    }
  }

  void getQare2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedQare2 = prefs.getString('Qare2');
    if (savedQare2 == null) {
      savedQare2 = "ATolbaHfs";
    } else {
      globals.qre2Folder = savedQare2;
    }

    print(globals.qre2Folder);
    print(savedQare2);
  }

  Widget build(BuildContext context) {
    if (!data_ready) return globals.GlobalUI().getLoadingContent();
    // FocusScope.of(context).nextFocus();
    // print(FocusScope.of(context).debugDescribeChildren());
    // var focusNodes = FocusNode();
    // var textField = TextField(focusNode: focusNodes);
    // focusNode.requestFocus();
    return Scaffold(
//////////////////APPBAR///////////////
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff22160B),
          automaticallyImplyLeading: false,
          title: Text("تيسيرالقراءات",
              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold)),
        ),
//////////////////BODY///////////////
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xff22160B),
            image: DecorationImage(
              image: AssetImage("assets/images/islam.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: GridView.count(
            // primary: false,
            padding: const EdgeInsets.all(5),
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            crossAxisCount: 3,
            childAspectRatio: MediaQuery.of(context).size.height / 500,
            children: <Widget>[
//////////////////الفاتحة الى الأنفال///////////////
              Container(
                child: new ButtonTheme(
                  // height:90.0,
                  // minWidth: 130.0,
                  child: OutlinedButton(
                    autofocus: true,
                    onPressed: () {
                      suraSubpage(1);
                    },
                      style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                  
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الفاتحة",
                            style: TextStyle(
                              color: Colors.brown[100],
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "الى الأنفال",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////التوبة الى النحل///////////////
              Container(
                child: new ButtonTheme(
                  // height:90.0,
                  // minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(2);
                    },
                    style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "التوبة",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى النحل",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////الإسراء الى النور///////////////
              Container(
                child: new ButtonTheme(
                  // height:90.0,
                  // minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(3);
                    },
                   style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الإسراء",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى النور",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////الفرقان الى السجدة///////////////
              Container(
                child: new ButtonTheme(
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(4);
                    },
                   style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الفرقان",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى السجدة",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////الأحزاب الى غافر///////////////
              Container(
                child: new ButtonTheme(
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(5);
                    },
                    style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الأحزاب",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى غافر",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////فصلت الى الفتح///////////////
              Container(
                child: new ButtonTheme(
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(6);
                    },
                     style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "فصلت",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى الفتح",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),

//////////////////الحجرات الى الحديد///////////////
              Container(
                child: new ButtonTheme(
                  height: 50.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(7);
                    },
                      style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الحجرات",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى الحديد",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////المجادلة الى التحريم///////////////
              Container(
                child: new ButtonTheme(
                  height: 50.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(8);
                    },
                    style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "المجادلة",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى التحريم",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////الملك الى النبأ///////////////
              Container(
                child: new ButtonTheme(
                  height: 50.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(9);
                    },
                     style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الملك",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى النبأ",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////النازعات الى البلد///////////////
              Container(
                child: new ButtonTheme(
                  // padding: const EdgeInsets.only(left:1.0),
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(10);
                    },
                   style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "النازعات",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى البلد",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////الشمس الى التكاثر///////////////
              Container(
                child: new ButtonTheme(
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(11);
                    },
                    style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "الشمس",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى التكاثر",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
//////////////////العصر الى الناس///////////////
              Container(
                child: new ButtonTheme(
                  height: 90.0,
                  minWidth: 130.0,
                  child: OutlinedButton(
                    onPressed: () {
                      suraSubpage(12);
                    },
                     style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "العصر",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "الى الناس",
                            style: TextStyle(
                                color: Colors.brown[100],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
                color: Color(0xff22160B),
              ),
            ],
          ),
        ),

//////////////////////////////FOOTER//////////////////////////////////////////////
       bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xff22160B),
            image: DecorationImage(
              image: AssetImage("assets/images/islam.png"),
              fit: BoxFit.cover,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                     height: 70,
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width / 4,
                      height: 80.0,
                      child: TyseerButton( 
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 4,
                        text:   "المفضلات",
                        onPressed: () {
                       Navigator.pushNamed(context, 'favorites');
                         },
                      ), 
                        
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                     height: 70,
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width / 4,
                      height: 80.0,
                      child: TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 4,
                        text:  "الإعدادات",
                        onPressed: () {
                         Navigator.pushNamed(context, 'settings');
                        },
                      ), 
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                     height: 70,
                    child: 
                    TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 4,
                        text:  "الختمات",
                        onPressed: () {
                          Navigator.pushNamed(context, 'Khatamat');
                        },
                      ),
                     
                  ),
                ),
                Expanded(
                   child: Container(
                    height: 70,
                    child:
                    TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 4,
                        text: "الخدمات",
                        onPressed: () {
                          Navigator.pushNamed(context, 'extraspage');
                        },
                      ),
                  ),
                ),
              ],
            ),
          ),)
            );
  }
}
