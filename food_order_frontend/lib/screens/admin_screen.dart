import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../services/menu_service.dart';
import '../widgets/menu_form.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Menu>> _menus;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  void _loadMenus() {
    setState(() {
      _menus = MenuService.fetchMenus();
    });
  }

  void _deleteMenu(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF121230),
        title: const Text('⚠️ Konfirmasi',
            style: TextStyle(color: Colors.cyanAccent)),
        content: const Text(
          'Yakin ingin menghapus menu ini?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await MenuService.deleteMenu(id);
      if (!mounted) return;
      if (success) _loadMenus();
    }
  }

  void _openForm({Menu? menu}) {
    showDialog(
      context: context,
      builder: (_) => MenuForm(menu: menu, onSaved: _loadMenus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text(
          '🛠️ Panel Admin',
          style:
              TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.cyanAccent),
            onPressed: () => _openForm(),
            tooltip: 'Tambah Menu',
          ),
        ],
      ),
      body: FutureBuilder<List<Menu>>(
        future: _menus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('❌ Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent)),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(menu.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Rp ${menu.price}',
                              style:
                                  const TextStyle(color: Colors.cyanAccent)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                      onPressed: () => _openForm(menu: menu),
                      tooltip: 'Edit Menu',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteMenu(menu.id),
                      tooltip: 'Hapus Menu',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
