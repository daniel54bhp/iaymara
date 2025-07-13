import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // elegir / tomar foto :contentReference[oaicite:3]{index=3}
import '../utils/shared_prefs.dart'; // helper creado arriba
import 'package:path_provider/path_provider.dart'; // opcional para copiar foto

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  String? _photoPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _firstCtrl.text = await Prefs.getFirstName() ?? '';
    _lastCtrl.text = await Prefs.getLastName() ?? '';
    _photoPath = await Prefs.getPhotoPath();
    if (mounted) setState(() {});
  }

  /* ---------- elegir imagen ---------- */
  Future<void> _selectPhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    ); // image_picker usage :contentReference[oaicite:4]{index=4}
    if (picked == null) return;

    // Guardamos una copia en el directorio de la app
    final appDir = await getApplicationDocumentsDirectory();
    final copied = await File(
      picked.path,
    ).copy('${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await Prefs.setPhotoPath(copied.path);
    setState(() => _photoPath = copied.path);
  }

  /* ---------- guardar texto ---------- */
  Future<void> _save() async {
    await Prefs.setFirstName(_firstCtrl.text.trim());
    await Prefs.setLastName(_lastCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /* ---- foto de perfil redonda ---- */
            Stack(
              children: [
                CircleAvatar(
                  // API oficial :contentReference[oaicite:5]{index=5}
                  radius: 60,
                  backgroundImage: _photoPath != null
                      ? FileImage(File(_photoPath!))
                      : null,
                  child: _photoPath == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: _selectPhoto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            /* ---- nombres ---- */
            TextField(
              controller: _firstCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            /* ---- apellidos ---- */
            TextField(
              controller: _lastCtrl,
              decoration: const InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }
}
