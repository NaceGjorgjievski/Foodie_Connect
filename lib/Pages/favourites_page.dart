import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Pages/home_page.dart';
import 'package:foodie_connect/Pages/login_register_page.dart';
import 'package:foodie_connect/Pages/profile_page.dart';
import 'package:foodie_connect/Pages/restaurant_details_page.dart';
import 'package:foodie_connect/Services/firebase_service.dart';


class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesState();
}

class _FavouritesState extends State<FavouritesPage>{

  User? user = FireBaseService().currentUser;
  final int _currentIndex = 1;
  List<Restaurant> restaurants = [];


  @override
  void initState(){
    super.initState();
    if(user != null){
      getFavouriteRestaurants(user!.email!);
    }
  }

  Future<void> getFavouriteRestaurants(String email) async {
    List<Restaurant>rs = await FireBaseService().getFavouriteRestaurants(email);
    setState(() {
      restaurants = rs;
    });
  }

  Widget buildCard(BuildContext context, Restaurant restaurant) => GestureDetector(
    onTap: () async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsPage(restaurant: restaurant),
        ),
      );
    },
    child: Container(
      width: 250,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 10, // Blur radius
            offset: const Offset(0, 3), // Offset from the top-left corner
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                restaurant.imageUri,
                width: 220,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 30,right: 30,left: 30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Омилени ресторани", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              Container(
                margin: const EdgeInsets.only(top: 40),
                height: 500,
                width: 500,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(12),
                  itemCount: restaurants.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 30);
                  },
                  itemBuilder: (context, index) {
                    return buildCard(context,restaurants[index]);
                  },
                ),
              ),
            ]
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          //Clicked Home item
          if(index == 0){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage())
            );
          }
          if(index == 1){
            if (user != null){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavouritesPage())
              );
            }
          }
          if(index==2) {
            // If user is not Logged in go to Login Page
            if (user == null) {
              var returnedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage())
              );
              setState(() {
                user = returnedUser;
              });
            }
            // If user is Logged in go to Profile Page
            else {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage())
              );
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
