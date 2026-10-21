import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminBookingScreen extends StatefulWidget {
  const AdminBookingScreen({super.key});

  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  String selectedStatus = 'All';

  // Fungsi untuk admin mengonfirmasi booking
  Future<void> approveBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': 'approved',
          }); // Update status booking menjadi approved

      print("Booking approved successfully");
    } catch (e) {
      print("Error updating booking: $e");
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': status,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Booking berhasil di-$status')));
  }

  // Fungsi logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Arahkan kembali ke login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Booking List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout, // Logout ketika tombol ditekan
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .orderBy('date')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text('Tidak ada booking.'));
          }

          // Filter berdasarkan status
          final filteredBookings =
              bookings.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (selectedStatus == 'All') return true;
                return data['status'] == selectedStatus;
              }).toList();

          // Urutkan: pending di atas
          filteredBookings.sort((a, b) {
            final sa = (a.data() as Map)['status'] ?? '';
            final sb = (b.data() as Map)['status'] ?? '';
            if (sa == 'pending' && sb != 'pending') return -1;
            if (sa != 'pending' && sb == 'pending') return 1;
            return 0;
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items:
                          ['All', 'pending', 'approved', 'rejected'].map((
                            status,
                          ) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status[0].toUpperCase() + status.substring(1),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBookings.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final doc = filteredBookings[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final placeName = data['placeName'] ?? '-';
                    final date = data['date'] ?? '-';
                    final status = data['status'] ?? '-';
                    final userId = data['userId'] ?? '-';
                    final email = data['userEmail'] ?? '-';

                    final jam =
                        data['times'] != null
                            ? (data['times'] as List).join(' - ')
                            : (data['time'] ?? '-');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Tanggal: $date'),
                            Text('Jam: $jam'),
                            Text('User ID: $userId'),
                            Text('Email: $email'),
                            const SizedBox(height: 4),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color:
                                    status == 'approved'
                                        ? Colors.green
                                        : status == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (status == 'pending') ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () => updateBookingStatus(
                                          doc.id,
                                          'approved',
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Terima'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed:
                                        () => updateBookingStatus(
                                          doc.id,
                                          'rejected',
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Tolak'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
