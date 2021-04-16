

import 'package:flutter_riverpod/all.dart';
import 'package:tingting_chat2/model/user_model.dart';

final chatUser = StateProvider((ref) => UserModel());
final userLogged = StateProvider((ref)=> UserModel());

