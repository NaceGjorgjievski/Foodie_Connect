import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie_connect/Models/restaurant.dart';

class FireBaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
    }
    // Adding user to database
    if(user != null){
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'password': password,
        'favourites': List<String>.empty(growable: true),
      });
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> createRestaurant({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String imageUri,
  }) async{
    try{
      await _firestore.collection('restaurant').add({
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'imageUri': imageUri,
      });

    } on FirebaseAuthException catch (e){
      rethrow;
    }
  }

  Future<bool> isRestaurantInDatabase(String id) async{
    final CollectionReference restaurantCollection = _firestore.collection('restaurant');

    QuerySnapshot querySnapshot = await restaurantCollection.where('id', isEqualTo: id).get();

    if(querySnapshot.docs.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  Future<Restaurant> getRestaurant(id) async{
    final CollectionReference restaurantCollection = _firestore.collection('restaurant');

    QuerySnapshot querySnapshot = await restaurantCollection.
      where('id', isEqualTo: id).limit(1).get();


    Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;
    return Restaurant(
      id: id,
      name: data['name'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      imageUri: data['imageUri'],
    );
  }


  Future<void> addComment({
    required String restaurantId,
    required String username,
    required String content,
    required DateTime timestamp,
  }) async {
    try {
      final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

      await commentsCollection.add({
        'restaurantId': restaurantId,
        'username': username,
        'content': content,
        'timestamp': timestamp,
      });

      print('Comment added successfully.');
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Error adding comment');
    }
  }

  Future<void> addRestaurantToFavourite(String email, String restaurantId) async{
    final CollectionReference users = _firestore.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
      List<String> favourites = List<String>.from(data['favourites']);
      favourites.add(restaurantId);
      await documentSnapshot.reference.update({'favourites': favourites});
    }
  }

  Future<List<Restaurant>> getFavouriteRestaurants(String email) async{
    final CollectionReference users = _firestore.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
      List<String> favouritesIds = List<String>.from(data['favourites']);

      List<Restaurant> favourites = [];

      for(var i=0;i<favouritesIds.length;i++){
        Restaurant restaurant = await getRestaurant(favouritesIds[i]);
        favourites.add(restaurant);
      }

      return favourites;
    }
    return [];
  }

  Future<bool> isRestaurantFavourite(String email,String restaurantId) async {
    final CollectionReference users = _firestore.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
      List<String> favouritesIds = List<String>.from(data['favourites']);

      for(var i=0;i<favouritesIds.length;i++){
        print("In Favourite ${favouritesIds[i]}");
      }

      print("Search for$restaurantId");

      if(favouritesIds.contains(restaurantId)){
        return true;
      }
    }
    return false;
  }

  Future<void> removeFavourite(String email, String restaurantId) async{
    final CollectionReference users = _firestore.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
      List<String> favourites = List<String>.from(data['favourites']);
      favourites.remove(restaurantId);
      await documentSnapshot.reference.update({'favourites': favourites});
    }
  }

}