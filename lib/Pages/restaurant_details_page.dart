import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Models/comments.dart';
import '../Services/firebase_service.dart';
import 'home_page.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:foodie_connect/Pages/foreward_page.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  //final List<Comment> comments;

  const RestaurantDetailsPage({Key? key, required this.restaurant,/* required this.comments*/}) : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  List<Comment> _comments = [];
  User? user = FireBaseService().currentUser;
  bool isFavourite = false;

  Uint8List? _image;
  File? selectedIMage;

  @override
  void initState() {
    super.initState();
    getComments(widget.restaurant.id);
    if(user != null){
      isRestaurantFavourite(user!.email!,widget.restaurant.id);
    }
  }

  Future<void>getComments(String id) async{
    List<Comment> comments = await FireBaseService().getCommentsForRestaurant(id);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> isRestaurantFavourite(String email, String restaurantId) async{
    bool tmp = await FireBaseService().isRestaurantFavourite(email, restaurantId);
    setState(() {
      isFavourite = tmp;
    });
  }

  Future<void> addToFavourite() async {
    if (user != null && user!.email != null) {
      await FireBaseService().addRestaurantToFavourite(user!.email!, widget.restaurant.id);
      setState(() {
        isFavourite = true;
      });
    }
  }

  Future<void> removeFavourite() async {
    if (user != null && user!.email != null) {
      await FireBaseService().removeFavourite(user!.email!, widget.restaurant.id);
    }
    setState(() {
      isFavourite = false;
    });
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
                            Text("Галерија")
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
                            Text("Камера")
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      size: 34.0,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Handle menu icon press
                    },
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                      shadows: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: !isFavourite ? const Icon(
                          Icons.favorite_border,
                          size: 34.0,
                          color: const Color(0xFFFF4B3A),
                        )
                        :
                        Icon(
                          Icons.favorite,
                          size: 34.0,
                          color: const Color(0xFFFF4B3A),
                        ),
                        onPressed: () {
                          if(!isFavourite){
                            addToFavourite();
                          }else{
                            removeFavourite();
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show restaurant image in a container with shadow
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.restaurant.imageUri,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Show restaurant name in the same container with shadow
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.restaurant.name,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Show comments
            const Text(
              'Comments:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  Comment comment = _comments[index];
                  String formattedTimestamp = DateFormat.yMMMd().add_jm().format(comment.timestamp);
                  return ListTile(
                    title: Text(comment.content),
                    subtitle: Text('By: ${comment.username} at: $formattedTimestamp'),
                    trailing: comment.image!='' ? GestureDetector(
                      onTap: () {
                        final imageProvider = Image.network(comment.image).image;
                        showImageViewer(context, imageProvider, doubleTapZoomable: true, swipeDismissible: true, onViewerDismissed: (){
                          setState(() {

                          });
                        });
                      },
                      child: Image.network(comment.image),
                    )  : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 125.0),
        child: SizedBox(
          // width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
                if (FirebaseAuth.instance.currentUser == null) {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForewardPage()),
                );}
                else{
              // Show a dialog with an input field for adding a comment
              String? newComment = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  String? commentText = '';
                  return SingleChildScrollView(
                    child: AlertDialog(
                      title: const Text('Add Comment'),
                      content: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Enter your comment'),
                            autofocus: true,
                            onChanged: (value) {
                              commentText = value;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton( onPressed: (){
                            showImagePickerOption(context);
                          }, child: Text("Додади фотографија")),
                          SizedBox(height: 20,),
                          if(_image != null)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                              ),
                            )
                          //CircleAvatar(radius: 50, backgroundImage: MemoryImage(_image!))

                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            if (commentText != null && commentText!.isNotEmpty) {

                              Navigator.of(context).pop();
                              try {
                                Comment curr = await FireBaseService().addComment(
                                  restaurantId: widget.restaurant.id,
                                  username: FirebaseAuth.instance.currentUser!.displayName ?? '',
                                  content: commentText ?? '',
                                  timestamp: DateTime.now(),
                                  file: _image,
                                );

                                setState(() {
                                  /*
                                  _comments.add(Comment(
                                    id: 'generated_id',
                                    content: commentText ?? '',
                                    restaurantId: widget.restaurant.id,
                                    username: FirebaseAuth.instance.currentUser!.displayName ?? '',
                                    timestamp: DateTime.now(),
                                    image:
                                  ));*/
                                  _comments.add(curr);
                                });
                              } catch (e) {
                                print('Error adding comment: $e');
                                // Handle error gracefully
                              }
                            }
                          },
                          child: const Text('Add'),
                        ),
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: Text('Cancel'))
                      ],

                    ),
                  );
                },
              );}
            },
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFFF4B3A), // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
            ),
            child: const Text(
              'Comment',
              style: TextStyle(
                fontWeight: FontWeight.bold, // Bold text
                fontSize: 16, // Font size
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Set current index as needed
        onTap: (index) {
          // Handle bottom navigation item taps
          if (index == 0) {
            // Handle Home tap
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 2) {
            // Handle Settings tap
            // Example navigation:
            Navigator.push(
              context,
              //TODO change the redirect
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Color(0xFFFF4B3A),
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