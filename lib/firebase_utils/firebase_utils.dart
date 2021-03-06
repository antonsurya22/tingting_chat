import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tingting_chat2/const/const.dart';
import 'package:tingting_chat2/model/chat_info.dart';
import 'package:tingting_chat2/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tingting_chat2/state/state_manager.dart';
import 'package:tingting_chat2/utils/time.dart';
import 'package:tingting_chat2/utils/utils.dart';


Widget  loadChatList(FirebaseDatabase database, DatabaseReference chatListRef)
{
  return StreamBuilder(
      stream: chatListRef.onValue,
      builder: (BuildContext context, AsyncSnapshot<Event> snapshot){
        if(snapshot.hasData)
        {
          List<ChatInfo> chatInfos = new List<ChatInfo>();
          Map<dynamic,dynamic> values = snapshot.data.snapshot.value;

          if(values != null)
          {
            values.forEach((key, value){
              var chatInfo = ChatInfo.fromJson(json.decode(json.encode(value)));
              chatInfos.add(chatInfo);
            });
          }

          return ListView.builder(
            itemCount: chatInfos.length,
            itemBuilder: (context,index){
              var displayName = FirebaseAuth.FirebaseAuth
                  .instance.currentUser.uid == chatInfos[index].createId ?
                  chatInfos[index].friendName : chatInfos[index].createName;
              return Consumer(builder: (context, watch,_){
                return GestureDetector(onTap : (){
                  database.reference()
                  .child(PEOPLE_REF)
                  .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid ==
                chatInfos[index].createId ? chatInfos[index].friendId : chatInfos[index].createId)
                .once().then((DataSnapshot snapshot){
                    if(snapshot != null)
                      {
                        UserModel userModel = UserModel.fromJson(json.decode(json.encode(snapshot.value)));
                        userModel.uid = snapshot.key;

                        context.read(chatUser).state = userModel; //Chat Friend User

                        //Load Current User
                        database.reference().child(PEOPLE_REF)
                            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
                            .once().then((value){
                          UserModel currentUserModel = UserModel.fromJson(json.decode(json.encode(value.value)));
                          currentUserModel.uid = value.key;
                          context.read(userLogged).state = currentUserModel;
                          Navigator.pushNamed(context, "/detail");
                        })
                            .catchError((e) => showOnlySnackBar(context, 'Galat memuat halaman!'));
                      }
                  });
                }, child: Column(
                  children: [
                    Text('${TimeAgo.timeAgoSinceDate(chatInfos[index].lastUpdate)}'),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[
                          Random().nextInt(Colors.primaries.length)
                        ],
                        child: Text('${displayName.substring(0,1)}',
                        style: TextStyle(color: Colors.white) ),
                      ),
                      title: Text('$displayName'),
                      subtitle: Text('${chatInfos[index].lastMessage}',),
                      isThreeLine: true,
                    ),
                    Divider(thickness: 2,)
                  ],
                ),);
              });
            },
          );
        }
        else
        {
          return Center(child: CircularProgressIndicator(),);
        }
      });

}

Widget loadPeople(FirebaseDatabase database, DatabaseReference _peopleRef)
{
  return StreamBuilder(
      stream: _peopleRef.onValue,
      builder: (context,snapshot){
        if(snapshot.hasData)
        {
          List<UserModel> userModels = new List<UserModel>();
          Map<dynamic,dynamic> values = snapshot.data.snapshot.value;
          values.forEach((key, value){
            if(key != FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
            {
              var userModel = UserModel.fromJson(json.decode(json.encode(value)));
              userModel.uid = key;
              userModels.add(userModel);
            }
          });
          return ListView.builder(
            itemCount: userModels.length,
            itemBuilder: (context,index){
              return GestureDetector(
                onTap: () {

                  //Load Current User
                  database.reference().child(PEOPLE_REF)
                      .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
                      .once().then((value){
                    UserModel currentUserModel = UserModel.fromJson(json.decode(json.encode(value.value)));
                    currentUserModel.uid = value.key;


                    context.read(userLogged).state = currentUserModel;
                    context.read(chatUser).state = userModels[index];
                    Navigator.pushNamed(context, "/detail");
                  })
                      .catchError((e) => showOnlySnackBar(context, 'Galat memuat halaman!'));

                  
                },
                child: Column(children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.primaries[
                      Random().nextInt(Colors.primaries.length)
                      ],
                      child: Text('${userModels[index].firstName.substring(0,1)}',
                          style: TextStyle(color: Colors.white)),),
                    title: Text('${userModels[index].firstName} ${userModels[index].lastName}',
                      style: TextStyle(color: Colors.black),),
                    subtitle:  Text('${userModels[index].phone}',
                      style: TextStyle(color: Colors.black),),
                  ),
                  Divider(thickness: 2),
                ],),
              );
            },
          );
        }
        else return Center(child: CircularProgressIndicator(),);
      });

}

