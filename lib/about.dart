import 'package:flutter/material.dart';

class AboutRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF075F55),
        centerTitle: true,
        title: Text('Info'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Picture(),
            TextName(),
            ownClass(),
            RowCardOne(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //color: Colors.transparent,
        child: Container(
          height: 25,
          color: Color(0xFF075F55),
          alignment: Alignment.center,
          child: Text(
            'Pre-release version [experiemental].build3',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.white),
          ),
        ),
        //elevation: 0,
      ),
    );
  }
}

class Picture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        radius: 95,
        backgroundColor: Colors.greenAccent,
        child: CircleAvatar(
          radius: 90,
          backgroundImage: AssetImage('asset/chat_icon2.png'),
        ),
      ),
      margin: const EdgeInsets.only(top: 30.0),
    );
  }
}

class TextName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Antonie-Soenitra Dev',
        style: TextStyle(
          color: Color(0xFF075F55),
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      margin: const EdgeInsets.only(top: 20.0),
    );
  }
}


class ownClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Created with <3',
        style: TextStyle(
          color: Color(0xFF075F55),
          fontSize: 17,
        ),
        textAlign: TextAlign.center,
      ),
      margin: const EdgeInsets.only(top: 5.0),
    );
  }
}


class RowCardOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.green[50],
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          width: 150,
          margin: const EdgeInsets.only(top:20.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.cancel_outlined,
                    size: 50,
                    color: Color(0xFF075F55),
                  ),
                  Text(
                    'Pre-release',
                    style: TextStyle(color: Color(0xFF075F55), fontSize: 18),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.green[50],
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          width: 150,
          margin: const EdgeInsets.only(top: 20.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.contact_phone_outlined,
                    size: 50,
                    color: Color(0xFF075F55),
                  ),
                  Text(
                    'Bantuan',
                    style: TextStyle(color: Color(0xFF075F55), fontSize: 18),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );

  }
}



