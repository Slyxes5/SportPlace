import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final lat = place["latitude"] ?? 0.0;
    final lng = place["longitude"] ?? 0.0;
    final name = place["name"] ?? "-";
    final category = place["category"] ?? "-";
    final price = place["price"] ?? 0;
    final address = place["address"] ?? "-";
    final imageUrl = place["imageUrl"] ?? "";

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text("Rp $price / jam", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Alamat: $address", style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Text(
                  "Lokasi di Map:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(center: LatLng(lat, lng), zoom: 16),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.sport_place',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
