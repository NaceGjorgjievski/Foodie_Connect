import 'package:foodie_connect/Models/restaurant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerFactory {
  static Marker createMarker({
    required Restaurant restaurant,
    required String markerId,
    required LatLng position,
    required onMarkerTap,
    String? title,
    String? snippet,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
        title: title ?? '',
        snippet: snippet ?? '',
      ),
      onTap: (){
        onMarkerTap(markerId, restaurant);
      }
    );
  }

}