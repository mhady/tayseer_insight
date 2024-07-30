import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text('الإعدادات',
            style: TextStyle(
                color: Colors.brown[100],
                fontSize: 23.0,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff22160B),
          image: DecorationImage(
            image: AssetImage("assets/images/islam.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new ButtonTheme(
                    height: 70.0,
                    minWidth: 170.0,
                    child: TextButton(
                      autofocus: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, 'qare2Settings');
                      },
                      child: Text("تغيير القارئ",
                          style: TextStyle(fontSize: 27.0)),
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
                  new ButtonTheme(
                    height: 70.0,
                    minWidth: 170.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, 'tafseerSettings');
                      },
                      child: Text("تغيير التفسير",
                          style: TextStyle(fontSize: 27.0)),
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

                  ////////////
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new ButtonTheme(
                    height: 70.0,
                    minWidth: 170.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, 'shwahedSettings');
                      },
                      child:
                          Text("ضبط الشواهد", style: TextStyle(fontSize: 27.0)),
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
                ],
              ),
            )

            ///
          ],
        ),
      ),
    );
  }
}
