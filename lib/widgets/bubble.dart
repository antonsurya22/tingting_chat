
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tingting_chat2/model/chat_message.dart';
import 'package:tingting_chat2/utils/time.dart';


Widget bubbleTextFromUser(ChatMessage chatContent){
  return Column(
    children: [
      TimeAgo.isSameDay(chatContent.timeStamp) ? Container() : Text('${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)}',
      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54 ),),
      Bubble(
        margin: const BubbleEdges.only(top: 10.0),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightBottom,
        color: Color(0xFFAEFCBF),
        child: Text('${chatContent.content}',
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.right,),
      )
    ],
  );
}

Widget bubbleTextFromFriend(ChatMessage chatContent){
  return Column(children: [
      TimeAgo.isSameDay(chatContent.timeStamp) ? Container() : Text('${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)}',
      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54 ),),

      Bubble(
        margin: const BubbleEdges.only(top: 10.0),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftBottom,
        color: Color(0xFFFAFAFA),
        child: Text('${chatContent.content}',
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.left,),
  )

  ],);
}

Widget bubbleImageFromUser(ChatMessage chatContent){
  return Column(children: [
      TimeAgo.isSameDay(chatContent.timeStamp) ? Container() : Text('${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)}',
      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54 )),

     Bubble(
       margin: const BubbleEdges.only(top: 10.0),
       alignment: Alignment.topRight,
       nip: BubbleNip.rightBottom,
       color: Colors.black54,
       child: Column(children: [
       Image.network(chatContent.pictureLink),
       Text('${chatContent.content}',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.right,
        ),
       ],
      ),
     ),
   ],
  );
}

Widget bubbleImageFromFriend(ChatMessage chatContent){
  return Column(
    children: [
          TimeAgo.isSameDay(chatContent.timeStamp) ? Container() : Text('${TimeAgo.timeAgoSinceDate(chatContent.timeStamp)}',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54 )),

     Bubble(
        margin: const BubbleEdges.only(top: 10.0),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftBottom,
        color: Colors.yellow,
        child: Column(children: [
        Image.network(chatContent.pictureLink),
        Text('${chatContent.content}',
         style: TextStyle(color: Colors.black),
         textAlign: TextAlign.left,),
         ],)
        ),
       ],
     );
}

