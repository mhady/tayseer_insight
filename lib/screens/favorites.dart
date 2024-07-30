import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subpage.dart';
import 'package:tayseer_insight/globals.dart';

class Favorites extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FavoritesPageState();
  }
}

class FavoritesPageState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  String? firstsharedFavorite;
  String? secondsharedFavorite;
  String? thirdsharedFavorite;
  String? fourthsharedFavorite;
  String? fifthsharedFavorite;
  String? soraNumber;
  String? ayaNumber;

  TextEditingController favoriteOne = new TextEditingController();
  TextEditingController favoriteTwo = new TextEditingController();
  TextEditingController favoriteThree = new TextEditingController();
  TextEditingController favoriteFour = new TextEditingController();
  TextEditingController favoriteFive = new TextEditingController();

  String format(String soraNumber) {
    int n = int.parse(soraNumber);
    String r = '';
    if (n <= 9)
      r = "00" + n.toString();
    else if (n > 9 && n <= 99)
      r = "0" + n.toString();
    else if (n > 99) r = n.toString();
    return r;
  }

//////////////////////////GET FAVORITES FROM SHARED PREFERENCES////////////////////////
  getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getStringList('favorite1'));
    // print(prefs.getStringList('favorite1')![2]);
    if (prefs.getStringList('favorite1') == null) {
      firstsharedFavorite = "المفضلة الأولى";
    } else {
      firstsharedFavorite = prefs.getStringList('favorite1')![2];
    }
    if (prefs.getStringList('favorite2') == null) {
      secondsharedFavorite = "المفضلة الثانية";
    } else {
      secondsharedFavorite = prefs.getStringList('favorite2')![2];
    }
    if (prefs.getStringList('favorite3') == null) {
      thirdsharedFavorite = "المفضلة الثالثة";
    } else {
      thirdsharedFavorite = prefs.getStringList('favorite3')![2];
    }
    if (prefs.getStringList('favorite4') == null) {
      fourthsharedFavorite = "المفضلة الرابعة";
    } else {
      fourthsharedFavorite = prefs.getStringList('favorite4')![2];
    }
    if (prefs.getStringList('favorite5') == null) {
      fifthsharedFavorite = "المفضلة الخامسة";
    } else {
      fifthsharedFavorite = prefs.getStringList('favorite5')![2];
    }
    setState(() {
      favoriteOne.text = firstsharedFavorite!;
      favoriteTwo.text = secondsharedFavorite!;
      favoriteThree.text = thirdsharedFavorite!;
      favoriteFour.text = fourthsharedFavorite!;
      favoriteFive.text = fifthsharedFavorite!;
    });
  }

//////////////////////////PLAY FAVORITES FROM SHARED PREFERENCES////////////////////////
  void playFirstfavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite1') != null) {
      soraNumber = this.format(prefs.getStringList('favorite1')![0]);
      ayaNumber = this.format(prefs.getStringList('favorite1')![1]);
      print(soraNumber);
      print(ayaNumber);
      AyaSoraNumber as = new AyaSoraNumber(aya: ayaNumber!, sora: soraNumber!);
      Navigator.pushNamed(context, 'subPage', arguments: as);
    }
  }

  void playSecondfavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite2') != null) {
      soraNumber = this.format(prefs.getStringList('favorite2')![0]);
      ayaNumber = this.format(prefs.getStringList('favorite2')![1]);
      print(soraNumber);
      print(ayaNumber);
      AyaSoraNumber as = new AyaSoraNumber(aya: ayaNumber!, sora: soraNumber!);
      Navigator.pushNamed(context, 'subPage', arguments: as);
    }
  }

  void playThirdfavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite3') != null) {
      soraNumber = this.format(prefs.getStringList('favorite3')![0]);
      ayaNumber = this.format(prefs.getStringList('favorite3')![1]);
      print(soraNumber);
      print(ayaNumber);
      AyaSoraNumber as = new AyaSoraNumber(aya: ayaNumber!, sora: soraNumber!);
      Navigator.pushNamed(context, 'subPage', arguments: as);
    }
  }

  void playFourthfavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite4') != null) {
      soraNumber = this.format(prefs.getStringList('favorite4')![0]);
      ayaNumber = this.format(prefs.getStringList('favorite4')![1]);
      print(soraNumber);
      print(ayaNumber);
      AyaSoraNumber as = new AyaSoraNumber(aya: ayaNumber!, sora: soraNumber!);
      Navigator.pushNamed(context, 'subPage', arguments: as);
    }
  }

  void playFifthfavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite5') != null) {
      soraNumber = this.format(prefs.getStringList('favorite5')![0]);
      ayaNumber = this.format(prefs.getStringList('favorite5')![1]);
      print(soraNumber);
      print(ayaNumber);
      AyaSoraNumber as = new AyaSoraNumber(aya: ayaNumber!, sora: soraNumber!);
      Navigator.pushNamed(context, 'subPage', arguments: as);
    }
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
                style: TextStyle(fontSize: 16.0, color: Colors.brown[100])),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff22160B),
        title: Text('المفضلات',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 5.0),
         child: Container(
            width: double.infinity,
            child:  Wrap(
            
              spacing:20, // gap between adjacent chips
              runSpacing: 20.0, // gap between lines
              // alignment: WrapAlignment.spaceEvenly,
              children: <Widget>[
                // GridView.count(
                //       primary: false,
                //       crossAxisSpacing: 5,
                //       mainAxisSpacing: 5,
                //       padding: const EdgeInsets.all(5),
                //       crossAxisCount: 1,
                //       childAspectRatio: MediaQuery.of(context).size.height/150 ,
                // children: <Widget>[
//////////////////FIRST FAVORITE BUTTON///////////////
                Container(
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      autofocus: true,
                      onPressed: () {
                        playFirstfavorite();
                      },
                      child: Text(favoriteOne.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 23.0,
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
                ),
//////////////////SECOND FAVORITE BUTTON///////////////
                Container(
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        playSecondfavorite();
                      },
                      child: Text(favoriteTwo.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 23.0,
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
                ),
//////////////////THIRD FAVORITE BUTTON///////////////
                Container(
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        playThirdfavorite();
                      },
                      child: Text(favoriteThree.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 23.0,
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
                ),
//////////////////FOURTH FAVORITE BUTTON///////////////
                Container(
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        playFourthfavorite();
                      },
                      child: Text(favoriteFour.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 23.0,
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
                ),
//////////////////FIFTH FAVORITE BUTTON///////////////
                Container(
                  child: new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        playFifthfavorite();
                      },
                      child: Text(favoriteFive.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 23.0,
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
                ),
              ]),
        )
        ),
      ),
    );
  }
}
