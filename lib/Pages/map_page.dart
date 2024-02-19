import 'package:flutter/material.dart';
import 'package:foodie_connect/Factories/marker_factory.dart';
import 'package:foodie_connect/Models/restaurant.dart';
import 'package:foodie_connect/Pages/restaurant_details_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {

  final List<Restaurant> restaurants;
  final Position? myPosition;

  const MapPage({Key? key, required this.restaurants, required this.myPosition}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _markers = widget.restaurants.map((r){
      return MarkerFactory.createMarker(
        restaurant: r,
        markerId: r.id,
        position: LatLng(r.latitude, r.longitude),
        title: r.name,
        onMarkerTap: _handleMarkerTap,
      );
    }).toList();
    if(widget.myPosition != null){
      _markers.add(MarkerFactory.createMyLocationMarker(onMarkerTap: _myLocationTap,position: LatLng(widget.myPosition!.latitude, widget.myPosition!.longitude)));
    }
  }


  static const _initialCameraPosition = CameraPosition(
    target: LatLng(42.00443918426004, 21.409539069200985),
    zoom: 11.5,
  );

  bool isTapped = false;
  Restaurant? selectedRestaurant;

  void _handleMarkerTap(String id, Restaurant r){
    setState(() {
      isTapped = true;
      selectedRestaurant = r;
    });
  }

  void _myLocationTap(){
    setState(() {
      isTapped = false;
    });
  }

  Widget _buildRestaurantCard(){
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsPage(restaurant: selectedRestaurant!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
        ),
        margin: const EdgeInsets.only(top: 20,left: 20,right: 20),
        padding: const EdgeInsets.only(top:20,bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(selectedRestaurant!.imageUri,width: 100,height: 100,fit: BoxFit.cover,),
            ),
            Text(selectedRestaurant!.name, style: const TextStyle(fontSize: 20),)
          ],
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 34.0,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Container(
                padding: const EdgeInsets.all(12),
                height: 400,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GoogleMap(
                    initialCameraPosition: _initialCameraPosition,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: Set.from(_markers),
                  ),
                )
            ),
            if(isTapped)
              _buildRestaurantCard()

          ],
        )

    );
  }
}