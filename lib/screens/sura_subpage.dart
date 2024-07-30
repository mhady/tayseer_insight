import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayseer_insight/globals.dart';
import 'subpage.dart';
import 'dart:convert';

class SuraPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SuraPageState();
}

class RequiredSura {
  final int? id;
  RequiredSura({this.id});
}

class SuraPageState extends State<SuraPage> {
  RequiredSura? requiredSura;
  int currentSura = 0;
  List<Map>? _mySura;
  List<dynamic>? title;
  int gridLength = 0;
  double childRatioLength = 0;
  @override
  void initState() {
    //super.initState();
    //_loadIntroData();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _loadIntroData();
      setState(() {});
    });

    //  _loadIntroData(); //.then((value) => super.initState());
  }

  Future _loadIntroData() async {
    await currentSura;
    String jsonSura =
        await rootBundle.loadString("assets/data/sura_jsons/$currentSura.json");
    //  setState(() {
    _mySura = List<Map>.from(jsonDecode(jsonSura) as List);
    print("*******_mySura: $_mySura");
    title = _mySura!.map((t) => t["page_title"]).toList();
    print(title![0]);
    if (_mySura!.length == 9 || _mySura!.length == 12) {
      gridLength = 3;
      childRatioLength = 1.1;
    } else {
      gridLength = 2;
      childRatioLength = 2.0;
    }
    //   });
  }

  TextEditingController subpagetitle = new TextEditingController();
  TextEditingController suraName = new TextEditingController();
  String format(String ayaAndSoraNumber) {
    int n = int.parse(ayaAndSoraNumber);
    String r = '';
    if (n <= 9)
      r = "00" + n.toString();
    else if (n > 9 && n <= 99)
      r = "0" + n.toString();
    else if (n > 99) r = n.toString();
    return r;
  }

  void soraNumber(String value) {
    print(this.format(ayaNumber.text));
    String rr = this.format(ayaNumber.text);
    AyaSoraNumber as = new AyaSoraNumber(aya: rr, sora: value);
    Navigator.pushNamed(context, 'subPage', arguments: as);
  }

  TextEditingController ayaNumber = TextEditingController();
  void showMyDialog(String value) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
//////////////////POPUP CONTAINER TEXT FIELD ///////////////
            content: SingleChildScrollView(
              // height: MediaQuery.of(context).size.height/2,
              child: Container(
                child: Wrap(
                  spacing: 10.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              decoration: InputDecoration(
                                counterText: 'من فضلك ادخل رقم الآية',
                                counterStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                    color: Color(0xff22160B)),
                              ),
                              controller: ayaNumber,
                              autofocus: true,
                              textDirection: TextDirection.rtl,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
//////////////////POPUP BUTTONS ///////////////
              new ButtonTheme(
                height: 50.0,
                minWidth: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "الغاء",
                    style: TextStyle(fontSize: 21.0),
                  ),
                        style: OutlinedButton.styleFrom( 
                    
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                ),
              ),
              new ButtonTheme(
                height: 50.0,
                minWidth: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    soraNumber(value);
                    ayaNumber.clear();
                    print(value);
                  },
                  child: Text(
                    "ذهاب",
                    style: TextStyle(fontSize: 21.0),
                  ),
                         style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    requiredSura = settings.arguments as RequiredSura?;
    currentSura = requiredSura!.id!;
    print(currentSura);

    String pageTitle = "";
    List<Map>? mySuraList = [];
    if (title != null) pageTitle = title![0];
    if (_mySura != null) mySuraList = _mySura;
    if (title == null || _mySura == null) return Scaffold();

    return Scaffold(
//////////////////APPBAR///////////////
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            child: new GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text("الرجوع",
                  style: TextStyle(fontSize: 16.0, color: Colors.brown[100])),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff22160B),
          title: Text(pageTitle, style: TextStyle(color: Colors.brown[100])),
        ),
//////////////////CONTAINER///////////////
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Color(0xff22160B),
            image: DecorationImage(
              image: AssetImage("assets/images/islam.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: GridView.builder(
              shrinkWrap: true,
              itemCount: mySuraList!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridLength,
                  childAspectRatio: childRatioLength),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  // elevation: 6.0,
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: 170.0,
                    child: TextButton(
                      autofocus: index == 0 ? true : false,
                      onPressed: () {
                        showMyDialog(_mySura![index]["sura_id"]);
                      },
                      child: Text(_mySura![index]["sura_name"],
                          style: TextStyle(
                            fontSize: 27.0,
                          )),
                          style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                    ),
                  ),
                );
              }),
        ),
/////////////////////////////////////////FOOTER//////////////////////////////////////////////
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Color(0xff22160B),
              image: DecorationImage(
                image: AssetImage("assets/images/islam.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            // color: Colors.white,
            margin: const EdgeInsets.only(bottom: 2.0),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//////////////////BUTTON (FAVORITES)///////////////
                  new ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    height: 70.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'favorites');
                      },
                      child: Text("المفضلات",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    ),
                  ),
//////////////////BUTTON (SETTINGS)///////////////
                  new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'settings');
                      },
                      child: Text("الإعدادات",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    ),
                  ),
//////////////////BUTTON (HOME)///////////////
                  new ButtonTheme(
                    // padding: const EdgeInsets.only(left:1.0),
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'Home');
                      },
                      child: Text("الرئيسية",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
