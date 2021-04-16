// Created by Antonie Dev
/*
I Gusti Nyoman Anton Surya Diputra
1915051027
PTI 4 A

 */

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth ;
import 'package:page_transition/page_transition.dart';
import 'package:tingting_chat2/screen/chat_screen.dart';
import 'package:tingting_chat2/screen/register.dart';

import 'const/const.dart';
import 'firebase_utils/firebase_utils.dart';
import 'model/user_model.dart';
import 'utils/utils.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp(app:app)));
}



class MyApp extends StatelessWidget {

  FirebaseApp app;

  MyApp({this.app});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      onGenerateRoute: (settings){
        switch(settings.name)
        {
          case '/register' :
            return PageTransition(
                child: RegisterScreen(app:app, user:FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);
            break;
          case '/detail' :
            return PageTransition(
                child: DetailScreen(app:app, user:FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);
            break;

            default: return null;
        }
      },
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // Try running your application with "flutter run". You'll see the
      //   // application has a blue toolbar. Then, without quitting the app, try
      //   // changing the primarySwatch below to Colors.green and then invoke
      //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //   // Notice that the counter didn't reset back to zero; the application
      //   // is not restarted.
      //   primarySwatch: Colors.green,
      //   // This makes the visual density adapt to the platform that you run
      //   // the app on. For desktop platforms, the controls will be smaller and
      //   // closer together (more dense) than on mobile platforms.
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: MyHomePage(title: 'Chat App',app:app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final FirebaseApp app;

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

  DatabaseReference _peopleRef, _chatListRef;
  FirebaseDatabase database;

  bool isUserInit = false;

  UserModel userLogged;

  final List<Tab> tabs = <Tab>[
    Tab(icon:Icon(Icons.chat),text: "Pesan"),
    Tab(icon:Icon(Icons.people), text: "Teman")
  ];

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);

    database = FirebaseDatabase(app: widget.app);
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      processLogin(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF075F55),
          title: Text(
            'kabarKu',
            style:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        bottom: new TabBar(
          isScrollable: false,
          unselectedLabelColor: Colors.black45,
          labelColor: Colors.white,
          tabs: tabs,
          controller: _tabController,
        )
      ),
      body: isUserInit
          ? TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          if(tab.text == 'Pesan')
             return loadChatList(database, _chatListRef);
          else
            return loadPeople(database,_peopleRef);
        }).toList())
          :
          Center(
            child: CircularProgressIndicator(),
          ),
    );
  }

  void processLogin(BuildContext context) async
  {
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    if(user == null)
    { // if user not login
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((fbUser) async {
           //refresh state
      await _checkLoginState(context);
      }).catchError((e){
        if(e is PlatformException)
          {
            if(e.code == FirebaseAuthUi.kUserCancelledError)
              showOnlySnackBar(context,'User cancelled login!');
            else
              showOnlySnackBar(context,'${e.message ?? 'Error!' }');
          }
      });
    }
    else // User sudah login
      await _checkLoginState(context);
  }

  Future<FirebaseAuth.User> _checkLoginState(BuildContext context) async
  {
    if(FirebaseAuth.FirebaseAuth.instance.currentUser != null)
      {
        FirebaseAuth.FirebaseAuth.instance.currentUser
            .getIdToken()
            .then((token) async{
            _peopleRef = database.reference().child(PEOPLE_REF);

            _chatListRef = database
            .reference()
            .child(CHATLIST_REF)
            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid);

            //Load Information
          _peopleRef.child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
            .once()
            .then((snapshot){
              if(snapshot != null && snapshot.value != null)
                {
                  setState(() {
                    //userLogged = UserModel.fromJson(json.decode(json.encode(snapshot.value)));
                    isUserInit = true;
                  });
                }
              else
                {
                  setState(() {
                    isUserInit = true;
                  });
                  Navigator.pushNamed(context, "/register");
                }
          });
        });
      }
    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }

}
