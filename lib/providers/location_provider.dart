import 'package:flutter/cupertino.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {

  double latitude;
  double longitude;
  bool permissionAllowed = false;
  var address, streetAddress;
  GeoCode geoCode = GeoCode();
  bool loading = false;

  Future<void> getCurrentPosition() async {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position != null) {

      this.latitude = position.latitude;
      this.longitude = position.longitude;

      try {
        final addresses = await geoCode.reverseGeocoding(latitude: this.latitude, longitude: this.longitude);
        this.address = "${addresses.streetAddress}, ${addresses.city}, ${addresses.region}, ${addresses.countryName} ${addresses.postal}";
        this.streetAddress = addresses.streetAddress;
        this.permissionAllowed = true;
        notifyListeners();
      } catch (e) {
        print(e);
      }
    } else {
      print("Permission not allowed");
    }
  }

  void onCameraMove(CameraPosition cameraPosition) async {
    this.latitude = cameraPosition.target.latitude;
    this.longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    try {
      final addresses = await geoCode.reverseGeocoding(latitude: this.latitude, longitude: this.longitude);
      this.address = "${addresses.streetAddress}, ${addresses.city}, ${addresses.region}, ${addresses.countryName} ${addresses.postal}";
      this.streetAddress = addresses.streetAddress;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}