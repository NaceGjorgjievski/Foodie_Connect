import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Pages/foreward_page.dart';
import 'package:foodie_connect/Pages/login_register_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage>{

  User? user = FireBaseService().currentUser;

  // Sign-out User
  Future<void> signOut() async {
    await FireBaseService().signOut();
    setState(() {
      user = null;
    });
  }

  Widget _title() {
    return const Text('Foodie Connect');
  }

  Widget _userUid() {
    return Text(user?.email ?? '');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  // Comment Button
  Widget _commentButton(){
    return ElevatedButton(
        onPressed: () async {

          //If user is not logged in
          if(user == null){
            final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForewardPage())
            );

            if(result != null){
              setState(() {
                user = result;
              });
            }
          }

          //TODO: Comment Functionality
          else{
            print('Logged in');
          }


        },
        child: const Text("Comment")
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B3A),
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
            _commentButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
