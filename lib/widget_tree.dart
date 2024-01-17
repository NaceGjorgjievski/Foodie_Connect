import 'package:flutter/material.dart';
import 'package:foodie_connect/Pages/home_page.dart';
import 'package:foodie_connect/Pages/login_register_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();

}
/*
class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FireBaseService().authStateChanges,
        builder: (context, snapshot) {
          return HomePage();
        },
    );
  }
}

 */

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FireBaseService().authStateChanges,
      builder: (context, snapshot) {
        return HomePage();
      },
    );
  }
}