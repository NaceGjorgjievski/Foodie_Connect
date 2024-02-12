import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Pages/home_page.dart';
import 'package:foodie_connect/Pages/login_register_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage>{
  bool refresh = false;
  User? user = FireBaseService().currentUser;
  final int _currentIndex = 2;
  String imageUrl = "";



  @override
  void initState() {
    super.initState();
    print("I AM IN PROFILE PAGE AND THE USER IS ${user!.email!}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserInfo();
      setState(() {
      });
    });

  }

  Future<void>getUserInfo() async{
    Map<String,String> userInfo = await FireBaseService().getUserInfo(user!.email!);
    _controllerUsername = TextEditingController(text: userInfo['username']);
    _controllerEmail = TextEditingController(text: userInfo['email']);
    _controllerPassword = TextEditingController(text: userInfo['password']);
    imageUrl = userInfo['profileImage']!;

    print(imageUrl);
  }

  Uint8List? _image;
  File? selectedIMage;

  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();


  // Sign-out User
  Future<void> signOut() async {
    await FireBaseService().signOut();
    setState(() {
      user = null;
    });
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage())
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:const Color(0xFFFF4B3A),
      ),
      onPressed: signOut,
      child: const Text('Одјави се'),
    );
  }

  Future<void> updateProfile() async{
    await FireBaseService().update(_controllerUsername.text,_controllerPassword.text,_controllerEmail.text,_image);
  }

  Widget _updateButton(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
      ),
      onPressed: updateProfile,
      child: const Text('Ажурирај го профилот'),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.blue[100],
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //Gallery
  Future _pickImageFromGallery() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); //close the model sheet
  }

//Camera
  Future _pickImageFromCamera() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(radius: 100, backgroundImage: MemoryImage(_image!))
                        :  CircleAvatar(
                      radius: 100,
                      backgroundImage: imageUrl!="" ?
                      NetworkImage(
                          imageUrl
                      )
                      :
                      NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"
                      ),
                    ),
                    Positioned(
                        bottom: -0,
                        left: 140,
                        child: IconButton(
                          onPressed: (){
                            showImagePickerOption(context);
                          },
                          icon: const Icon(Icons.add_a_photo),
                        )),

                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    TextField(
                      controller: _controllerUsername,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: "Корисничко име",
                        labelStyle: TextStyle(color: Colors.black),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controllerEmail,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.black),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      style: const TextStyle(fontSize: 20),
                      controller: _controllerPassword,
                      decoration: const InputDecoration(
                        labelText: "Лозинка",
                        labelStyle: TextStyle(color: Colors.black),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _updateButton(),
                    const SizedBox(height: 30),
                    _signOutButton(),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          //Clicked Home item
          if(index == 0){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage())
            );
          }
          // Clicked Profile item
          if(index==2) {
            // If user is not Logged in go to Login Page
            if (user == null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage())
              );
            }
            // If user is Logged in go to Profile Page
            else {
              //TODO Naviate to profile page
            }
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFFF4B3A),
        iconSize: 35,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}