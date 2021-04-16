import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tingting_chat2/const/const.dart';
import 'package:tingting_chat2/model/user_model.dart';
import 'package:tingting_chat2/utils/utils.dart';

class RegisterScreen extends StatelessWidget {
  FirebaseApp app;
  User user;

  RegisterScreen({this.app,this.user});

  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF075F55),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Register User'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
             Row(
               children: [
                 Expanded(flex: 1, child: TextField(
                   keyboardType: TextInputType.name,
                   controller: _firstNameController,
                   decoration: InputDecoration(hintText: 'Nama Depan'),
                 ),),
                 SizedBox(width: 16,),
                 Expanded(flex: 1, child: TextField(
                   keyboardType: TextInputType.name,
                   controller: _lastNameController,
                   decoration: InputDecoration(hintText: 'Nama Belakang'),
                 ),),
               ],),
              TextField(
                readOnly: true,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                decoration: InputDecoration(hintText: user.phoneNumber ?? 'Null'),
              ),
              ElevatedButton(
                onPressed: (){
                  if(_firstNameController == null || _firstNameController.text.isEmpty)
                    showOnlySnackBar(context, 'Lengkapi Form Nama Depan!');
                  else if(_lastNameController == null || _lastNameController.text.isEmpty)
                    showOnlySnackBar(context, 'Lengkapi Form Nama Belakang!');
                  else{
                     UserModel userModel = new UserModel(
                       firstName: _firstNameController.text,
                       lastName: _lastNameController.text,
                       phone: user.phoneNumber
                     );

                     //Submit form data to Firebase

                    FirebaseDatabase(app:app)
                     .reference()
                     .child(PEOPLE_REF)
                     .child(user.uid)
                     .set(<String,dynamic>{
                       'firstName': userModel.firstName,
                       'lastName' : userModel.lastName,
                       'phone'    : userModel.phone
                     })
                     .then((value){
                      showOnlySnackBar(context, 'Proses Daftar Berhasil!');
                      Navigator.pop(context);
                     }).catchError((e) => showOnlySnackBar(context, e ?? 'Galat, Ulangi Lagi!'));
                  }
                }, child: Text('Register', style: TextStyle(color: Colors.white)
              )),
            ],
          ),
        ),
     );
  }
}