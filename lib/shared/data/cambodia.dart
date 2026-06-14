import 'package:latlong2/latlong.dart';

/// Geographic centre of Cambodia — default map-picker view.
const kCambodiaCenter = LatLng(12.5657, 104.9910);

/// `11.5564, 104.9282` style label for a coordinate.
String formatLatLng(LatLng p) =>
    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
