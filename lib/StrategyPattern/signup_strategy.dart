import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie_connect/StrategyPattern/account_strategy.dart';
import '../Services/firebase_service.dart';
import 'package:flutter/material.dart';

class RegisterStrategy implements AccountStrategy{
  final BuildContext context;
  final String username;
  final String email;
  final String password;

  RegisterStrategy({
    required this.context,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  void action() async{
    try {
      await register();
      User? user = FireBaseService().currentUser;
      Navigator.pop(context, user);
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  Future<void> register() async{
    await FireBaseService().createUserWithEmailAndPassword(
        username: username,
        email: email,
        password: password);
  }


}