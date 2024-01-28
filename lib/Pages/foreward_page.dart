import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Pages/login_register_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';

class ForewardPage extends StatefulWidget {
  const ForewardPage({Key? key}) : super(key: key);

  @override
  State<ForewardPage> createState() => _ForewardPageState();
}


class _ForewardPageState extends State<ForewardPage>{

  User? user = FireBaseService().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4B3A),
      body: Container(
        padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
        child: user!=null ? null : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child:  Image.asset(
                      'assets/images/logo.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 40.0,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Заедно во', style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),),
                  Text('вкусниот свет!', style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                  ),),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 40),
                alignment: Alignment.centerLeft,
                child:   SingleChildScrollView( // Use SingleChildScrollView
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/people.png',
                        width: 380,
                        height: 370,
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () async{
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage())
                  );

                  if(result != null){
                    setState(() {
                      user = result;
                    });
                  }

                  Navigator.pop(context, user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF4B3A),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Најави се',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )


          ],
        ),
      )
    );
  }
}
