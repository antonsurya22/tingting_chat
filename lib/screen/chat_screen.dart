
import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:tingting_chat2/const/const.dart';
import 'package:tingting_chat2/model/chat_info.dart';
import 'package:tingting_chat2/model/chat_message.dart';
import 'package:tingting_chat2/state/state_manager.dart';
import 'package:tingting_chat2/utils/utils.dart';
import 'package:tingting_chat2/widgets/bubble.dart';

class DetailScreen extends ConsumerWidget
{
  DetailScreen({this.app, this.user});
  FirebaseApp app;
  User user;

  DatabaseReference offsetRef, chatRef;
  FirebaseDatabase database;

  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, watch) {
    var friendUser = watch(chatUser).state;
    return Scaffold(
      appBar: AppBar( backgroundColor: Color(0xFF075F55), centerTitle: true,
      title: Text('${friendUser.firstName} ${friendUser.lastName}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: (){
              aboutDialogOpen(context);
            },
          ),
        ],
      ),
        body: SafeArea(
          child: Container(
            color: Color(0xFFECE5DD),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Expanded(
                  flex: 8,
                  child: friendUser.uid != null ? FirebaseAnimatedList(
                      controller: _scrollController,
                      sort: (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key),
                      reverse: true,
                      query: loadChatContent(context, app),
                      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                        var chatContent = ChatMessage.fromJson(
                          json.decode(json.encode(snapshot.value)));

                        return SizeTransition(sizeFactor: animation,
                        child: chatContent.picture ? chatContent.senderId == user.uid ? bubbleImageFromUser(chatContent)
                        : bubbleImageFromFriend(chatContent) : chatContent.senderId == user.uid ? bubbleTextFromUser(chatContent) : bubbleTextFromFriend(chatContent) );
                      })  : Center(child: CircularProgressIndicator()),),
              SizedBox(height: 10),
              Expanded(
                  flex: 1,
                    //color: Colors.white,
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),

                      child: TextField(
                       keyboardType: TextInputType.multiline,
                       expands: true,
                       minLines: null,
                       maxLines: null,
                       controller: _textEditingController,
                       decoration: InputDecoration(hintText: 'Ketikan Pesan..', enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none),
                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none), contentPadding: EdgeInsets.only(left: 10, top: 15)),
                    ),),),
                    SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(color: Color(0xFF075F55), borderRadius: BorderRadius.circular(50),),
                    child: IconButton(icon: Icon(Icons.send, color: Colors.white,),
                    onPressed: () {
                      offsetRef.once()
                          .then((DataSnapshot snapshot){
                            var offset = snapshot.value as int;
                            var estimatedServerTimeInMs =
                                DateTime.now().millisecondsSinceEpoch + offset;

                            submitChat(context,estimatedServerTimeInMs);
                      });

                      //Auto Scroll Chat
                      autoScroll(_scrollController);

                    },),)
                  ],),
              ),
            ],),
          ),
          ),
        ),
    );
  }

  loadChatContent(BuildContext context, FirebaseApp app)
  {
    database = FirebaseDatabase(app:app);
    offsetRef = database.reference().child('.info/serverTimeOffset');
    chatRef = database.reference()
    .child(CHAT_REF)
    .child(getRoomId(user.uid, context.read(chatUser).state.uid))
    .child(DETAIL_REF);

    return chatRef;
  }

  void submitChat(BuildContext context, int estimatedServerTimeInMs)
  {
      ChatMessage chatMessage = ChatMessage();
      chatMessage.name = createName(context.read(userLogged).state);
      chatMessage.content = _textEditingController.text;
      chatMessage.timeStamp = estimatedServerTimeInMs;
      chatMessage.senderId = user.uid;


      // Load Pesan gambar dan text

    chatMessage.picture = false;
    submitChatToFirebase(context,chatMessage,estimatedServerTimeInMs);



}

  void submitChatToFirebase(BuildContext context, ChatMessage chatMessage, int estimatedServerTimeInMs)
  {
    chatRef.once().then((DataSnapshot snapshot){
      if(snapshot != null) // Jika user telah mengirimkan pesan
       // appendChat(context,chatMessage,estimatedServerTimeInMs);
      //else
        createChat(context,chatMessage,estimatedServerTimeInMs);
    });
  }

  void createChat(BuildContext context, ChatMessage chatMessage, int estimatedServerTimeInMs)
  {
    // Create chat info
    ChatInfo chatInfo = new ChatInfo(
      createId: user.uid,
      friendName: createName(context.read(chatUser).state),
      friendId: context.read(chatUser).state.uid,
      createName: createName(context.read(userLogged).state),
      lastMessage: chatMessage.picture ? "<Image>" : chatMessage.content,
      lastUpdate: DateTime.now().millisecondsSinceEpoch,
      createDate: DateTime.now().millisecondsSinceEpoch
    );

    //add to Firebase

    database
    .reference()
    .child(CHATLIST_REF)
    .child(user.uid)
    .child(context.read(chatUser).state.uid)
    .set(<String,dynamic>{
      'lastUpdate' : chatInfo.lastUpdate,
      'lastMessage' : chatInfo.lastMessage,
      'createId' : chatInfo.createId,
      'friendId' : chatInfo.friendId,
      'createName' : chatInfo.createName,
      'friendName' : chatInfo.friendName,
      'createDate' : chatInfo.createDate
    }).then((value){
      // Jika sukses, then
      database
          .reference()
          .child(CHATLIST_REF)
          .child(context.read(chatUser).state.uid)
          .child(user.uid)
          .set(<String,dynamic>{
        'lastUpdate' : chatInfo.lastUpdate,
        'lastMessage' : chatInfo.lastMessage,
        'createId' : chatInfo.createId,
        'friendId' : chatInfo.friendId,
        'createName' : chatInfo.createName,
        'friendName' : chatInfo.friendName,
        'createDate' : chatInfo.createDate
      }).then((value){
        // Membaca Pesan
        chatRef.push().set(<String,dynamic>{
          'uid':chatMessage.uid,
          'name':chatMessage.name,
          'content':chatMessage.content,
          'pictureLink':chatMessage.pictureLink,
          'picture':chatMessage.picture,
          'senderId':chatMessage.senderId,
          'timeStamp':chatMessage.timeStamp
        }).then((value){
          //Clear text content
          _textEditingController.text= '';

          //AutoScroll
          autoScrollReverse(_scrollController);
        })
            .catchError((e) => showOnlySnackBar(context,'Galat, tidak dapat mengirimkan pesan!'));
      })
          .catchError((e) => showOnlySnackBar(context, 'Error, tidak dapat memuat Friend List!'));
    })
    .catchError((e) => showOnlySnackBar(context, 'Error, tidak dapat memuat Pesan!'));
  }

  void appendChat(BuildContext context, ChatMessage chatMessage, int estimatedServerTimeInMs)
  {
    var update_data = Map<String,dynamic>();
    update_data['lastUpdate'] = estimatedServerTimeInMs;
    if(chatMessage.picture)
      update_data['lastMessage'] = '<Image>';
    else
      update_data['lastMessage'] = chatMessage.content;

    //Update message
    database.reference()
    .child(CHATLIST_REF)
    .child(user.uid) // Yours
    .child(context.read(chatUser).state.uid) // Friend
    .update(update_data)
    .then((value){

      database.reference()
          .child(CHATLIST_REF)
          .child(context.read(chatUser).state.uid) // friend
          .child(user.uid) // your message
          .update(update_data)
          .then((value){

            // Add to Chat
         chatRef.push().set(<String,dynamic>{
          'uid':chatMessage.uid,
          'name':chatMessage.name,
          'content':chatMessage.content,
          'pictureLink':chatMessage.pictureLink,
          'picture':chatMessage.picture,
          'senderId':chatMessage.senderId,
          'timeStamp':chatMessage.timeStamp
        }).then((value){
          //Clear text content
          _textEditingController.text= '';

          //AutoScroll
          autoScrollReverse(_scrollController);
        })
            .catchError((e) => showOnlySnackBar(context,'Galat, tidak dapat mengirimkan pesan!'));



      })
          .catchError((e) => showOnlySnackBar(context, 'Tidak dapat memuat Friend List!'));

    })
    .catchError((e) => showOnlySnackBar(context, 'Tidak dapat memuat isi pesan!'));

  }
}