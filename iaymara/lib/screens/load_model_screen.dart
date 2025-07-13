import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../utils/shared_prefs.dart';

class LoadModelScreen extends StatefulWidget {
  static const routeName = '/load_model';
  const LoadModelScreen({super.key});

  @override
  State<LoadModelScreen> createState() => _LoadModelScreenState();
}

class _LoadModelScreenState extends State<LoadModelScreen> {
  Future<void> _pickModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tflite', 'bin', 'gguf'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await Prefs.saveModelPath(path);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(modelPath: path, initialMessages: []),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar modelo')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Buscar modelo'),
          onPressed: _pickModel,
        ),
      ),
    );
  }
}
