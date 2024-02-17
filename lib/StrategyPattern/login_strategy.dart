import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie_connect/StrategyPattern/account_strategy.dart';
import '../Services/firebase_service.dart';
import 'package:flutter/material.dart';

class LoginStrategy implements AccountStrategy{
  final BuildContext context;
  final String email;
  final String password;

  LoginStrategy({
    required this.context,
    required this.email,
    required this.password,
  });

  @override
  void action() async{
    try {
      await signIn();
      User? user = FireBaseService().currentUser;
      Navigator.pop(context, user);
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }


  Future<void> signIn() async{
    await FireBaseService().signInWithEmailAndPassword(
        email: email, password: password);
  }
}