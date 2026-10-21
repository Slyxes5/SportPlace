import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const BookingScreen({super.key, required this.place});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  List<String> selectedSlots = [];
  bool isSubmitting = false;
  List<String> bookedTimes = [];

  final List<String> timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchBookedTimes();
  }

  // Format tanggal
  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Select Date
  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlots = [];
      });
      fetchBookedTimes();
    }
  }

  // Fetch booked times for the selected date
  Future<void> fetchBookedTimes() async {
    if (selectedDate == null) return;

    final dateStr =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";
    final snapshot =
        await FirebaseFirestore.instance
            .collection('bookings')
            .where('placeId', isEqualTo: widget.place['placeId'])
            .where('date', isEqualTo: dateStr)
            .where('status', isEqualTo: 'approved')
            .get();

    List<String> allBooked = [];
    for (var doc in snapshot.docs) {
      final times = doc['times'];
      if (times is List) {
        allBooked.addAll(List<String>.from(times));
      } else if (times is String) {
        allBooked.add(times);
      }
    }

    setState(() {
      bookedTimes = allBooked;
    });
  }

  // Submit booking request
  Future<void> submitBooking() async {
    if (selectedDate == null || selectedSlots.isEmpty) return;

    setState(() => isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    final dateStr =
        "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

    // Check for booking conflicts
    final snapshot =
        await FirebaseFirestore.instance
            .collection('bookings')
            .where('placeId', isEqualTo: widget.place['placeId'])
            .where('date', isEqualTo: dateStr)
            .where('status', isEqualTo: 'approved')
            .get();

    List<String> allBooked = [];
    for (var doc in snapshot.docs) {
      final times = doc['times'];
      if (times is List) {
        allBooked.addAll(List<String>.from(times));
      } else if (times is String) {
        allBooked.add(times);
      }
    }

    final conflict = selectedSlots.any((slot) => allBooked.contains(slot));
    if (conflict) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beberapa slot sudah dibooking, pilih slot lain.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user?.uid,
      'userEmail': user?.email,
      'placeId': widget.place['placeId'] ?? '',
      'placeName': widget.place['name'],
      'date': dateStr,
      'times': selectedSlots,
      'status': 'pending',
    });

    setState(() => isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan berhasil dikirim!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeName = widget.place['name'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Tempat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tempat: $placeName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Pilih Tanggal
            ElevatedButton.icon(
              onPressed: selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : 'Tanggal: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pilih Jam
            const Text(
              'Pilih Jam:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (selectedDate == null)
              const Text('Pilih tanggal terlebih dahulu.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    timeSlots.map((slot) {
                      final isBooked = bookedTimes.contains(slot);
                      final isSelected = selectedSlots.contains(slot);

                      return GestureDetector(
                        onTap:
                            isBooked
                                ? null // Jangan biarkan slot yang sudah dibooking bisa dipilih
                                : () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedSlots.remove(slot);
                                    } else {
                                      selectedSlots.add(slot);
                                    }
                                  });
                                },
                        child: Chip(
                          label: Text(slot),
                          backgroundColor:
                              isBooked
                                  ? Colors
                                      .grey
                                      .shade300 // Slot yang sudah dibooking berwarna abu
                                  : (isSelected
                                      ? Colors.blue.shade100
                                      : Colors.white),
                          labelStyle: TextStyle(
                            color:
                                isBooked
                                    ? Colors.grey
                                    : (isSelected
                                        ? Colors.white
                                        : Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
              ),

            const Spacer(),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isSubmitting || selectedSlots.isEmpty
                        ? null
                        : submitBooking,
                icon: const Icon(Icons.send),
                label:
                    isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Kirim Pemesanan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
