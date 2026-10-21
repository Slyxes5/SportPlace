import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada user yang login.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna'), centerTitle: true),
      body: Column(
        children: [
          // Header Profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName ?? 'Nama Tidak Ditemukan',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // Content Profil
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // User ID
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.verified_user,
                      color: Colors.purple,
                    ),
                    title: const Text('User ID'),
                    subtitle: Text(user.uid),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profil dan Ubah Password
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('Edit Profil'),
                    onTap: () {
                      // Tambahkan logika untuk edit profil
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Riwayat Booking (bisa link ke daftar booking atau riwayat)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.orange),
                    title: const Text('Riwayat Booking'),
                    onTap: () {
                      // Navigasi ke booking list
                      Navigator.pushNamed(context, '/booking');
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
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
        ],
      ),
    );
  }
}
