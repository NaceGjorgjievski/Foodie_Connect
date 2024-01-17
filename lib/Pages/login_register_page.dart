import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie_connect/Pages/home_page.dart';
import '../Services/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? user = FireBaseService().currentUser;
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FireBaseService().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      User? user = FireBaseService().currentUser;
      Navigator.pop(context, user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await FireBaseService().createUserWithEmailAndPassword(
          username: _controllerUsername.text,
          email: _controllerEmail.text,
          password: _controllerPassword.text);
      User? user = FireBaseService().currentUser;
      Navigator.pop(context, user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Foodie Connect');
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ) {

    if (isLogin && title == 'Корисничко име') {
      // Hide the username field when logging in
      return SizedBox.shrink();
    }

    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white,fontSize: 22.0),
      decoration: InputDecoration(
        labelText: title,
        hintStyle: TextStyle(color: Colors.white,),
        labelStyle: TextStyle(color: Colors.white,fontSize: 22),
        hoverColor: Colors.white,
        focusColor: Colors.white,

      ),
      obscureText: title == 'Лозинка',
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      onPressed:
      isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Најава' : 'Регистрирај се', style: const TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Немаш профил? Регистрирај се' : 'Имаш профил? Најави се', style: const TextStyle(
          fontSize: 16.0,

        ),
      ),
    );
  }

  Widget _topBox(){
    return Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          )
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 150,
                      ),
                    ],
                  ),
                   const Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Foodie",
                        style: TextStyle(
                            color: Color(0xFFFF4B3A),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "Connect",
                        style: TextStyle(
                            color: Color(0xFFFF4B3A),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  decoration: isLogin ? const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFFF4B3A),
                        width: 3.0,
                      )
                    )
                  ) : null,
                  child: const Text('Најaва', style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  decoration: isLogin==false ? const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFFF4B3A),
                            width: 3.0,
                          )
                      )
                  ) : null,
                  child: const Text('Регистрирај се', style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                )
              ],
            )
          ],
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4B3A),
      body:
        Container(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _topBox(),
                  Container(
                    width: 300,
                    padding: const EdgeInsets.only(
                        top: 50.0, // Adjust the left padding
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _entryField('Корисничко име', _controllerUsername),
                        _entryField('Е-mail', _controllerEmail),
                        _entryField('Лозинка', _controllerPassword),
                        _errorMessage(),
                        _submitButton(),
                        _loginOrRegisterButton(),
                      ],
                    ),
                  ),
                ],
              ),
            )
        ),
    );
  }
}