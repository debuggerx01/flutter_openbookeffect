import 'package:flutter/material.dart';
import 'package:flutter_openbookeffect/SV.dart';

class NewPage extends StatefulWidget {
  

  @override
  NewPageState createState() => new NewPageState();

  NewPage(Key key) :super(key: key);
}

class NewPageState extends State<NewPage> {
  bool isHide = false;
  void hide(bool hide) {
    setState(() {
      isHide = hide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SizedBox.expand(
        child: new Stack(
          children: <Widget>[
            new Image(
              image: new AssetImage('images/parchment.png'),
            ),
            new Center(
              child: new Text('第${SV.index}页面'),
            ),
          ],
        ),
      ),
    );
  }
}
