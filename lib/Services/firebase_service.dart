import 'dart:collection';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Models/comments.dart';

class FireBaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        'profileImage': '',
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


  Future<Comment> addComment({
    required String restaurantId,
    required String username,
    required String content,
    required DateTime timestamp,
    Uint8List? file
  }) async {
    try {
      String imageUrl = '';
      if(file != null){
        String path = 'commentImages/' + username + timestamp.toString();
        imageUrl = await uploadImageToStorage(path, file);
      }

      final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

      await commentsCollection.add({
        'restaurantId': restaurantId,
        'username': username,
        'content': content,
        'timestamp': timestamp,
        'image': imageUrl,
      });
      
      print('Comment added successfully.');
      return Comment(id: 'id',
          content: content,
          restaurantId: restaurantId,
          username: username,
          timestamp: timestamp,
          image: imageUrl);
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Error adding comment');
    }
  }

  Future<List<Comment>> getCommentsForRestaurant(String restaurantId) async{
    try {
      final CollectionReference commentsCollection = _firestore.collection('comments');
      QuerySnapshot querySnapshot = await commentsCollection.where('restaurantId', isEqualTo: restaurantId).get();

      List<Comment> comments = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Comment(
          id: doc.id,
          content: data['content'],
          restaurantId: data['restaurantId'],
          username: data['username'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          image: data['image'] ?? '',
        );
      }).toList();

      return comments;
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Error fetching comments');
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

  Future<Map<String,String>>getUserInfo(String email) async {
    final CollectionReference users = _firestore.collection('users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

    if(querySnapshot.docs.isNotEmpty){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
      Map<String,String>userInfo = {
        'username': data['username'],
        'password' : data['password'],
        'email': email,
        'profileImage': data['profileImage'],
      };
      return userInfo;
    }
    return {};
  }

  Future<void> update(String username, String password, String email, Uint8List? file) async{
    try{
      await currentUser!.updateEmail(email);
      await currentUser!.updatePassword(password);

      final CollectionReference users = _firestore.collection('users');
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: currentUser!.email!).get();




      if(querySnapshot.docs.isNotEmpty){
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
        if(file != null){
          String imageUrl = await uploadImageToStorage(username, file);
          await documentSnapshot.reference.update({'profileImage': imageUrl});
        }
        await documentSnapshot.reference.update({'username': username,'email': email.toLowerCase(), 'password': password});
      }
    }
    catch(err){
      print(err);
    }
  }

  Future<String> uploadImageToStorage(String name, Uint8List file) async{
    Reference ref = _storage.ref().child(name);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}