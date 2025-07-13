import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatscreen.dart';

class LoadModelScreen extends StatefulWidget {
  const LoadModelScreen({Key? key}) : super(key: key);

  @override
  State<LoadModelScreen> createState() => _LoadModelScreenState();
}

class _LoadModelScreenState extends State<LoadModelScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedPath();
  }

  Future<void> _checkSavedPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('model_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      _navigateToChat(savedPath);
    }
  }

  Future<void> _pickModel() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecciona el archivo del modelo (.bin)',
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _savePath(path);
      _navigateToChat(path);
    }
  }

  Future<void> _savePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model_path', path);
  }

  void _navigateToChat(String path) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(modelPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargar modelo Gemma')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Para comenzar, selecciona tu archivo .bin del modelo Gemma',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Buscar modelo'),
                onPressed: _pickModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
