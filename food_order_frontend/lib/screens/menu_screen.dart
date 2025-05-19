import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu.dart';
import '../services/menu_service.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Menu>> _menuList;

  @override
  void initState() {
    super.initState();
    _menuList = MenuService.fetchMenus();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _orderViaWhatsApp(Menu menu) async {
    final text = Uri.encodeComponent(
      'Halo, saya ingin memesan menu berikut:\n\n'
      '🍽️ *Nama Menu* : ${menu.name}\n'
      '📝 *Deskripsi* : ${menu.description?.isNotEmpty == true ? menu.description : "-"}\n'
      '💰 *Harga*     : Rp ${menu.price}\n\n'
      'Terima kasih!',
    );

    final uri = Uri.parse('https://wa.me/6282257359171?text=$text');

    if (await canLaunchUrl(uri)) {
      if (!mounted) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '🍽️ Daftar Menu',
          style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.cyanAccent),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Menu>>(
        future: _menuList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('❌ Terjadi kesalahan: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('🚫 Tidak ada menu tersedia',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final menus = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    menu.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (menu.description != null && menu.description!.isNotEmpty)
                        Text('📝 ${menu.description!}',
                            style: const TextStyle(color: Colors.white70)),
                      Text('💰 Rp ${menu.price}',
                          style: const TextStyle(color: Colors.cyanAccent)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.send, color: Colors.cyanAccent),
                    onPressed: () => _orderViaWhatsApp(menu),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}