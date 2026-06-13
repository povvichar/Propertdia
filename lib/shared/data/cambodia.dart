import 'package:latlong2/latlong.dart';

/// A Cambodian province / capital with an approximate centre point
/// (used to recentre the map picker).
class CambodiaProvince {
  const CambodiaProvince(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;

  LatLng get center => LatLng(lat, lng);
}

/// Geographic centre of Cambodia — default map-picker view.
const kCambodiaCenter = LatLng(12.5657, 104.9910);

/// All 25 provinces/capital, popular ones first then alphabetical.
const kCambodiaProvinces = <CambodiaProvince>[
  CambodiaProvince('Phnom Penh', 11.5564, 104.9282),
  CambodiaProvince('Siem Reap', 13.3633, 103.8564),
  CambodiaProvince('Preah Sihanouk', 10.6270, 103.5220),
  CambodiaProvince('Battambang', 13.0957, 103.2022),
  CambodiaProvince('Kandal', 11.4750, 104.9300),
  CambodiaProvince('Kampot', 10.6104, 104.1810),
  CambodiaProvince('Kep', 10.4831, 104.3169),
  CambodiaProvince('Banteay Meanchey', 13.7894, 102.9896),
  CambodiaProvince('Kampong Cham', 11.9934, 105.4636),
  CambodiaProvince('Kampong Chhnang', 12.2505, 104.6660),
  CambodiaProvince('Kampong Speu', 11.4530, 104.5209),
  CambodiaProvince('Kampong Thom', 12.7110, 104.8887),
  CambodiaProvince('Koh Kong', 11.6153, 102.9838),
  CambodiaProvince('Kratie', 12.4881, 106.0188),
  CambodiaProvince('Mondulkiri', 12.4470, 107.1880),
  CambodiaProvince('Oddar Meanchey', 14.1810, 103.5160),
  CambodiaProvince('Pailin', 12.8489, 102.6090),
  CambodiaProvince('Preah Vihear', 13.8079, 104.9802),
  CambodiaProvince('Prey Veng', 11.4849, 105.3250),
  CambodiaProvince('Pursat', 12.5388, 103.9192),
  CambodiaProvince('Ratanakiri', 13.7394, 106.9873),
  CambodiaProvince('Stung Treng', 13.5259, 105.9683),
  CambodiaProvince('Svay Rieng', 11.0879, 105.7993),
  CambodiaProvince('Takeo', 10.9908, 104.7850),
  CambodiaProvince('Tboung Khmum', 11.9038, 105.8620),
];

/// Province names for chip selectors.
final List<String> kProvinceNames = [
  for (final p in kCambodiaProvinces) p.name,
];

/// Centre of a named province, or Cambodia's centre if unknown.
LatLng provinceCenter(String? name) {
  if (name == null) return kCambodiaCenter;
  for (final p in kCambodiaProvinces) {
    if (p.name == name) return p.center;
  }
  return kCambodiaCenter;
}

/// `11.5564, 104.9282` style label for a coordinate.
String formatLatLng(LatLng p) =>
    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';
