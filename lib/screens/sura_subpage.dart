import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';
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
    log("*******_mySura: $_mySura");
    title = _mySura!.map((t) => t["page_title"]).toList();
    log(title![0]);
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
    log(this.format(ayaNumber.text));
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
                    log(value);
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

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    requiredSura = settings.arguments as RequiredSura?;
    currentSura = requiredSura!.id!;

    if (title == null || _mySura == null) return const LoadingView();
    final String pageTitle = title![0];
    final List<Map> mySuraList = _mySura!;
    final scale = AppTheme.textScale(context);

    return AppScaffold(
      title: pageTitle,
      body: LayoutBuilder(builder: (context, constraints) {
        // One column at large text sizes so long sura names never clip.
        final columns = scale > 1.3 ? 1 : gridLength;
        final cellWidth = constraints.maxWidth / columns;
        final lines = scale > 1.3 ? 2 : 1;
        final cellHeight =
            MediaQuery.textScalerOf(context).scale(27) * 1.4 * lines + 28;
        return GridView.builder(
          itemCount: mySuraList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: cellWidth / (cellHeight < 72 ? 72 : cellHeight),
          ),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              margin: const EdgeInsets.all(4),
              child: ElevatedButton(
                autofocus: index == 0,
                onPressed: () => showMyDialog(mySuraList[index]["sura_id"]),
                style: AppTheme.buttonStyle(minHeight: 70),
                child: Text(
                  mySuraList[index]["sura_name"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 27.0),
                ),
              ),
            );
          },
        );
      }),
      bottomBar: AppBottomBar(
        children: [
          TyseerButton(
            buttonHeight: 70,
            text: 'المفضلات',
            onPressed: () => Navigator.pushNamed(context, 'favorites'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الإعدادات',
            onPressed: () => Navigator.pushNamed(context, 'settings'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الرئيسية',
            onPressed: () => Navigator.pushNamed(context, 'Home'),
          ),
        ],
      ),
    );
  }
}
