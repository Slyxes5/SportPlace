import 'booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetailScreen({super.key, required this.place});

  void _openInGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = place['name'] ?? '-';
    final category = place['category'] ?? '-';
    final price = place['price'] ?? '-';
    final address = place['address'] ?? '-';
    final lat = place['latitude']?.toDouble() ?? 0.0;
    final lng = place['longitude']?.toDouble() ?? 0.0;
    final imageUrls = List<String>.from(place['imageUrls'] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📸 Gambar
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrls[index],
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // 🏷️ Nama dan kategori
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),

          const SizedBox(height: 16),

          // 💵 Harga
          Row(
            children: [
              const Icon(Icons.attach_money, size: 20),
              const SizedBox(width: 6),
              Text('Rp $price / jam', style: const TextStyle(fontSize: 16)),
            ],
          ),

          const SizedBox(height: 8),

          // 📍 Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(address, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🗺️ Map
          const Text(
            "Lokasi Tempat:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: LatLng(lat, lng),
                    zoom: 16,
                    maxZoom: 18,
                  ),
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
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _openInGoogleMaps(lat, lng),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🟦 Tombol Booking
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(place: place),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
