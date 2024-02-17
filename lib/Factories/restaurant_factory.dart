import 'package:foodie_connect/Models/restaurant.dart';
import '../Services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantFactory {
  static Future<List<Restaurant>> createRestaurants({
    required List<dynamic> places
  }) async {
    List<Restaurant> restaurants = [];
    for (var place in places) {
      var id = place['name'];
      final name = place['displayName']['text'];
      final latitude = place['location']['latitude'];
      final longitude = place['location']['longitude'];
      final image = place['photos'][0]['name'];

      var isInDb = await FireBaseService().isRestaurantInDatabase(id);
      if (!isInDb) {
        final imageUri = await fetchPhoto(image);
        Restaurant restaurant = await FireBaseService().createRestaurant(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            imageUri: imageUri);

        restaurants.add(restaurant);
      }else{
        Restaurant restaurant = await FireBaseService().getRestaurant(id);
        restaurants.add(restaurant);
      }
    }
    return restaurants;
  }

  static Future<String> fetchPhoto(String name)async {
    final apiKey = "AIzaSyA8RTRGVvvPIuuqNnlfFSMVRb7L8CgvEdY";
    final url = "https://places.googleapis.com/v1/$name/media?key=$apiKey&maxHeightPx=300&maxWidthPx=220&skipHttpRedirect=true";
    String photoUri = "";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        photoUri = data['photoUri'];
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return photoUri;
  }
}