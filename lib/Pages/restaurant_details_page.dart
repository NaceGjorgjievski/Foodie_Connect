import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Models/comments.dart';
import '../Services/firebase_service.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'package:intl/intl.dart';
import 'package:foodie_connect/Pages/foreward_page.dart';


class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  final List<Comment> comments;

  const RestaurantDetailsPage({Key? key, required this.restaurant, required this.comments}) : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  List<Comment> _comments = [];
  User? user = FireBaseService().currentUser;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
    if(user != null){
      isRestaurantFavourite(user!.email!,widget.restaurant.id);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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

                  return AlertDialog(
                    title: const Text('Add Comment'),
                    content: SingleChildScrollView(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Enter your comment'),
                        onChanged: (value) {
                          commentText = value;
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                        if (commentText != null && commentText!.isNotEmpty) {

                        Navigator.of(context).pop();
                          try {
                            await FireBaseService().addComment(
                              restaurantId: widget.restaurant.id,
                              username: FirebaseAuth.instance.currentUser!.displayName ?? '',
                              content: commentText ?? '',
                              timestamp: DateTime.now(),
                            );
                            setState(() {
                              _comments.add(Comment(
                                id: 'generated_id',
                                content: commentText ?? '',
                                restaurantId: widget.restaurant.id,
                                username: FirebaseAuth.instance.currentUser!.displayName ?? '',
                                timestamp: DateTime.now(),
                              ));
                            });
                          } catch (e) {
                            print('Error adding comment: $e');
                            // Handle error gracefully
                          }
                        }
                        },
                        child: const Text('Add'),
                      ),
                    ],

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