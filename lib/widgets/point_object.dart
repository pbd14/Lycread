import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointObject {
  final Widget child;
  final LatLng location;

  PointObject({this.child, this.location});
}
