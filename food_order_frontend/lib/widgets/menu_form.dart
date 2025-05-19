import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import '../models/menu.dart';

class MenuForm extends StatefulWidget {
  final Menu? menu;
  final VoidCallback onSaved;

  const MenuForm({super.key, this.menu, required this.onSaved});

  @override
  State<MenuForm> createState() => _MenuFormState();
}

class _MenuFormState extends State<MenuForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _nameController.text = widget.menu!.name;
      _priceController.text = widget.menu!.price.toString();
      _descriptionController.text = widget.menu!.description ?? '';
      _imageController.text = widget.menu!.image ?? '';
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = int.tryParse(_priceController.text.trim()) ?? 0;
      final description = _descriptionController.text.trim();
      final image = _imageController.text.trim();

      bool success;
      if (widget.menu == null) {
        success = await MenuService.createMenu(
          name,
          price,
          description: description,
          image: image,
        );
      } else {
        success = await MenuService.updateMenu(
          widget.menu!.id,
          name,
          price,
          description: description,
          image: image,
        );
      }

      if (!mounted) return;

      if (success) {
        widget.onSaved();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Gagal menyimpan data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.menu == null ? '➕ Tambah Menu' : '✏️ Edit Menu',
        style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(_nameController, 'Nama Makanan', isRequired: true),
              const SizedBox(height: 10),
              _buildInput(_priceController, 'Harga', isNumber: true, isRequired: true),
              const SizedBox(height: 10),
              _buildInput(_descriptionController, 'Deskripsi (opsional)'),
              const SizedBox(height: 10),
              _buildInput(_imageController, 'URL Gambar (opsional)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
          child: const Text('Simpan', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {bool isNumber = false, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyan),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}