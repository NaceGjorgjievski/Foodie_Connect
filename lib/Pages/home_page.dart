import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Pages/foreward_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage>{

  User? user = FireBaseService().currentUser;
  final TextEditingController _controllerSearch = TextEditingController();
  List<Restaurant> restaurants = [];
  int _currentIndex = 0;
  Position? currentPosition;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestLocationPermission();
      setState(() { });
    });
    //requestLocationPermission();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;
      if(currentPosition != null){
        fetchRestaurants();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
      status = await Permission.location.status;
    }

    if (status.isGranted) {
      // Location permission is granted, now get the current location
      getCurrentLocation();
    } else {
      print('Location permission denied.');
    }
  }

  void fetchRestaurants() async{
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null) {
      print('API key is missing in the .env file');
      return;
    }

    final url = 'https://places.googleapis.com/v1/places:searchNearby';
    final requestData = {
      "includedTypes": ["restaurant"],
      "maxResultCount": 5,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": currentPosition!.latitude, "longitude": currentPosition!.longitude},
          "radius": 500.0
        }
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName,places.name,places.location,places.photos',
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestData),
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse and handle the response data
        final responseData = jsonDecode(response.body);
        final places = responseData['places'] as List<dynamic>;
        for(var place in places){
          var id = place['name'];
          final name = place['displayName']['text'];
          final latitude = place['location']['latitude'];
          final longitude = place['location']['longitude'];
          final image = place['photos'][0]['name'];


          var isInDb = await FireBaseService().isRestaurantInDatabase(id);
          if(!isInDb){
            final imageUri = await fetchPhoto(image);
            await FireBaseService().createRestaurant(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                imageUri: imageUri);
          }

          Restaurant restaurant = await FireBaseService().getRestaurant(id);

          setState(() {
            restaurants.add(restaurant);
          });


        }
      } else {
        // Handle errors
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }

  }


  Future<String> fetchPhoto(String name)async {
    final apiKey = dotenv.env['API_KEY'];
    final url = "https://places.googleapis.com/v1/$name/media?key=$apiKey&maxHeightPx=300&maxWidthPx=220&skipHttpRedirect=true";
    String photoUri = "";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle the data as needed
        photoUri = data['photoUri'];
      } else {
        // Handle errors
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
    return photoUri;
  }




  // Sign-out User
  Future<void> signOut() async {
    await FireBaseService().signOut();
    setState(() {
      user = null;
    });
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
                    },
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.white, // Set the button color
                      shape: CircleBorder(), // Circular shape
                      shadows: [
                        BoxShadow(
                          color: Colors.black, // Shadow color
                          blurRadius: 4.0, // Spread of the shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.location_pin,
                          size: 34.0,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Add your button click logic here
                        },
                      ),
                    ),
                  )
                ],
              )
            ),

            Container(
                padding: const EdgeInsets.only(top: 50),
                child:const Row(
                    children: [Text("Каде ќе се јаде денес?", style: TextStyle(fontSize: 24)),]
                )
            ),
            Container(
                margin: const EdgeInsets.only(top: 20),
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,// Ensure TextField takes the remaining space
                        child: TextField(
                          controller: _controllerSearch,
                          decoration: InputDecoration(
                            labelText: 'Пребарувај',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0), // Set the border radius
                            ),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (text) {
                            // Handle the input text changes
                          },
                        ),
                      ),
                    ]


                )
            ),

            Container(
              margin: EdgeInsets.only(top: 40),
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: restaurants.length,
                separatorBuilder: (context,index){
                  return const SizedBox(width: 30,);
                },
                itemBuilder: (context,index){
                  return buildCard(restaurants[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // TODO: Add Navigation functionality
          setState(() {
            _currentIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFFF4B3A),
        iconSize: 35,
        items: [
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

Widget buildCard(Restaurant restaurant) => Container(
  width: 250,
  height: 400,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
      color: Colors.grey.withOpacity(0.3), // Shadow color
      spreadRadius: 5, // Spread radius
      blurRadius: 10, // Blur radius
      offset: Offset(0, 3), // Offset from the top-left corner
      ),
    ]
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(restaurant.imageUri,width: 220,height: 200,fit: BoxFit.cover,),
        )
      ),
      Text(restaurant.name, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),

    ],
  ),
);