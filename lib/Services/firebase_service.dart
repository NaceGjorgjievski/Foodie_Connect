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

    // Adding user to database
    if(user != null){
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'password': password
      });
    }
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



  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}