import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
// import './osoolSubpage.dart';

class FarshiatFilter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FarshiatFilterState();
  }
}

class FarshiatFilterState extends State<FarshiatFilter> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    String jsonRowah =
        await rootBundle.loadString("assets/data/rowah_list.json");
    setState(() {
      RowahList = List<Map>.from(jsonDecode(jsonRowah) as List);
      dropdpwnRowahFirstValue =
          RowahList.length > 0 ? RowahList[0]['id'].toString() : "loading";
      dropdpwnRowahSecondValue =
          RowahList.length > 0 ? RowahList[0]['id'].toString() : "loading";
    });
  }

  String dropdownValue = "0";
  String dropdpwnRowahFirstValue = "loading";
  String dropdpwnRowahSecondValue = "loading";
  bool _firstRawyFilterVisability = true;
  bool _secondRawyFilterVisability = false;
  bool _textFilterVisability = false;

  List RowahList = [];
  List<String> mainFilterList = <String>[
    'الإنفرادات',
    'الإتفاق',
    'الاختلافات',
    'بالكلمات الفرشية'
  ];

  showHideoptions(int index) {
    setState(() {
      if (index == 0) {
        _firstRawyFilterVisability = true;
        _secondRawyFilterVisability = false;
        _textFilterVisability = false;
      } else if (index == 1 || index == 2) {
        _firstRawyFilterVisability = true;
        _secondRawyFilterVisability = true;
        _textFilterVisability = false;
      } else if (index == 3) {
        _secondRawyFilterVisability = false;
        _textFilterVisability = true;
        _firstRawyFilterVisability = false;
      }
    });
  }

  Widget _mainFilter(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 10,
        //height:70 ,//MediaQuery.of(context).size.height
        //color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Color(0xff22160B),
            shape: BoxShape.rectangle,
            // border:Border.all( width: 8.0, color: Colors.white),
            borderRadius: BorderRadius.circular(1)),
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,

          style: TextStyle(
              color: Colors.brown[100],
              fontSize: 25,
              fontWeight: FontWeight.bold),

          dropdownColor: Color(0xff22160B),
          // underline: Container(
          //   height: 2,
          //   color: Colors.white,
          // ),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
              showHideoptions(int.parse(dropdownValue));
            });
          },
          isExpanded: true,
          items: mainFilterList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: mainFilterList.indexOf(value).toString(),
              child: Text(
                value,
                style: TextStyle(
                    color: Colors.brown[100],
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            );
          }).toList(),
        ));
  }

  Widget _firstRawyFilter(BuildContext context) {
    return Visibility(
      visible: _firstRawyFilterVisability,
      child: Container(
          width: MediaQuery.of(context).size.width - 10,
          //height:70 ,//MediaQuery.of(context).size.height
          //color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Color(0xff22160B),
              shape: BoxShape.rectangle,
              // border:Border.all( width: 8.0, color: Colors.white),
              borderRadius: BorderRadius.circular(1)),
          child: DropdownButton<String>(
            value: dropdpwnRowahFirstValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,

            style: TextStyle(
                color: Colors.brown[100],
                fontSize: 25,
                fontWeight: FontWeight.bold),

            dropdownColor: Color(0xff22160B),
            // underline: Container(
            //   height: 2,
            //   color: Colors.white,
            // ),
            onChanged: (String? newValue) {
              setState(() {
                dropdpwnRowahFirstValue = newValue!;
              });
            },
            isExpanded: true,
            items: RowahList.map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value: value['id'].toString(), //value['rawy_name'],
                child: Text(
                  value['rawy_name'],
                  style: TextStyle(
                      color: Colors.brown[100],
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                  textWidthBasis: TextWidthBasis.longestLine,
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _secondRawyFilter(BuildContext context) {
    return Visibility(
        visible: _secondRawyFilterVisability,
        child: Container(
            width: MediaQuery.of(context).size.width - 10,
            //height:70 ,//MediaQuery.of(context).size.height
            //color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(0xff22160B),
                shape: BoxShape.rectangle,
                // border:Border.all( width: 8.0, color: Colors.white),
                borderRadius: BorderRadius.circular(1)),
            child: DropdownButton<String>(
              value: dropdpwnRowahSecondValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,

              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 25,
                  fontWeight: FontWeight.bold),

              dropdownColor: Color(0xff22160B),
              // underline: Container(
              //   height: 2,
              //   color: Colors.white,
              // ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdpwnRowahSecondValue = newValue!;
                });
              },
              isExpanded: true,
              items: RowahList.map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value['id'].toString(),
                  child: Text(
                    value['rawy_name'],
                    style: TextStyle(
                        color: Colors.brown[100],
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                );
              }).toList(),
            )));
  }

  Widget _textFilter(BuildContext context) {
    return Visibility(
        visible: _textFilterVisability,
        child: Container(
            width: MediaQuery.of(context).size.width - 10,
            //height:70 ,//MediaQuery.of(context).size.height
            //color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(0xff22160B),
                shape: BoxShape.rectangle,
                // border:Border.all( width: 8.0, color: Colors.white),
                borderRadius: BorderRadius.circular(1)),
            child: TextField()));
  }

  Widget _filteredList(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {},
          child: new Card(
            color: Color(0xff22160B),
            child: new Text(
              "اختبار  " + index.toString(),
              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
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
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.brown[100],
                      fontWeight: FontWeight.bold)),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff22160B),
          title: Text("الفرشيات",
              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold)),
        ),
//////////////////BODY///////////////
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xff22160B),
              image: DecorationImage(
                image: AssetImage("assets/images/islam.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 5,
                ),
                _mainFilter(context),
                Container(
                  height: 5,
                ),
                _firstRawyFilter(context),
                Container(
                  height: 5,
                ),
                _secondRawyFilter(context),
                Container(
                  height: 5,
                ),
                _textFilter(context),
                Expanded(
                    child:
                        SizedBox(height: 200.0, child: _filteredList(context)))
              ],
            )));
  }
}
