// ================= lib/screens/chat_screen.dart =================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../utils/shared_prefs.dart';

/* ───────────────── ChatScreen ───────────────── */
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required String modelPath,
    required List initialMessages,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /* Gemma */
  late InferenceModel _model;
  late InferenceChat _chat;

  final _messages = <Message>[];

  /* UI / estado */
  final _ctl = TextEditingController();
  bool _ready = false, _typing = false, _recording = false;
  String _status = 'Inicializando…';

  /* media / perfil */
  String? _userPhoto;
  final _speech = stt.SpeechToText();
  bool _micOk = false;
  final _picker = ImagePicker();

  /* ───────── ciclo de vida ───────── */
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _userPhoto = await Prefs.getPhotoPath();
    await Permission.microphone.request();
    await Permission.manageExternalStorage.request();
    _micOk = await _speech.initialize();

    await _findAndInitModel();
  }

  /* ───────── localizar modelo ───────── */
  Future<void> _findAndInitModel() async {
    final dir = Directory('/storage/emulated/0/moday');
    if (!await dir.exists()) {
      setState(() => _status = 'Carpeta /moday no encontrada.');
      return;
    }
    final file = dir.listSync().whereType<File>().firstWhere(
      (f) => f.path.endsWith('.task'),
      orElse: () => File(''),
    );
    if (file.path.isEmpty) {
      setState(() => _status = 'Modelo .task no encontrado.');
      return;
    }
    setState(
      () => _status = 'Modelo encontrado: ${file.uri.pathSegments.last}',
    );
    await _initGemma(file.path);
  }

  Future<void> _initGemma(String path) async {
    final gemma = FlutterGemmaPlugin.instance;
    await gemma.modelManager.setModelPath(path);

    _model = await gemma.createModel(
      modelType: ModelType.gemmaIt,
      preferredBackend: PreferredBackend.gpu,
      maxTokens: 2000,
      supportImage: true,
    );

    _chat = await _model.createChat(
      temperature: 0.8,
      randomSeed: 42,
      topK: 4,
      supportImage: true,
    );

    // contexto inicial
    await _chat.addQueryChunk(
      Message.text(
        isUser: false,
        text:
            'Saludaras en Aymara:	Nayaxa IAymara Satathwa, en español es Yo me llamo IAymara'
            'Dirás: Nayaxa aka aymara yatiqiriwa juttha. Yo vine a aprender aymara y ser tu Yatichiri.'
            'Fui re entrenado por el equipo funIA2 - Paulo Batuani - Andres Muñoz - Enrique Castillo - Jose Ayllon'
            'Si te llego a preguntar algun animal y su traduccion usa la siguiente lista: anu = perro, phisi = gato, wallpa = gallina, kanka = gallo, kalla = loro, pili = pato, wanku = conejo, uwija = oveja, wari = vicuña, waka = vaca, urqu waka = toro, qarwa = llama, allpachu = alpaca, ququruqu = gallo, wanaku = guanaco, qalakayu = burro, asnu = burro, qaqilu = caballo, khuchhi = chancho, chiwatu = cabra, qarwitu = cabra'
            'Aun tienes fallos y se te sigue alimentando con nuevos conocimientos del idioma Aymara',
      ),
    );

    setState(() {
      _ready = true;
      _status = 'Modelo cargado ✓';
    });
  }

  /* ───────── envío texto (stream) ───────── */
  Future<void> _send([String? override]) async {
    if (!_ready) return;
    final txt = override ?? _ctl.text.trim();
    if (txt.isEmpty) return;

    _ctl.clear();
    setState(() {
      _messages.add(Message.text(text: txt, isUser: true));
      _typing = true;
    });

    await _chat.addQueryChunk(Message.text(text: txt, isUser: true));

    String buffer = '';
    await for (final tok in _chat.generateChatResponseAsync()) {
      buffer += tok;
      if (!mounted) return;
      setState(() {
        if (_messages.last.isUser) {
          _messages.add(Message.text(text: buffer, isUser: false));
        } else {
          _messages.last = Message.text(text: buffer, isUser: false);
        }
      });
    }
    if (mounted) setState(() => _typing = false);
  }

  /* ───────── imágenes (stream) ───────── */
  void _imageSheet() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(c);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(c);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource src) async {
    if (!_ready) return;
    final picked = await _picker.pickImage(source: src);
    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();
    final userMsg = Message.withImage(
      text: '',
      imageBytes: bytes,
      isUser: true,
    );

    setState(() => _messages.add(userMsg));

    await _chat.addQueryChunk(userMsg);

    String buffer = '';
    await for (final tok in _chat.generateChatResponseAsync()) {
      buffer += tok;
      if (!mounted) return;
      setState(() {
        if (_messages.last.isUser) {
          _messages.add(Message.text(text: buffer, isUser: false));
        } else {
          _messages.last = Message.text(text: buffer, isUser: false);
        }
      });
    }
  }

  /* ───────── audio PTT ───────── */
  void _micStart(_) async {
    if (!_ready || !_micOk) return;
    setState(() => _recording = true);
    _speech.listen(
      localeId: 'es_ES',
      onResult: (r) => _ctl.text = r.recognizedWords,
    );
  }

  void _micEnd(_) async {
    if (!_recording) return;
    final txt = _ctl.text;
    _speech.stop();
    setState(() => _recording = false);
    await _send(txt);
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    final avatarUser = CircleAvatar(
      radius: 16,
      backgroundImage: _userPhoto != null ? FileImage(File(_userPhoto!)) : null,
      child: _userPhoto == null ? const Icon(Icons.person, size: 18) : null,
    );
    final avatarBot = const CircleAvatar(
      radius: 16,
      backgroundImage: AssetImage('assets/images/icono.png'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Chat IAymara')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _ready ? Colors.green[100] : Colors.red[100],
            padding: const EdgeInsets.all(8),
            child: Text(
              _status,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _ready
                ? ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: m.isUser
                            ? [
                                Expanded(child: _bubble(m)),
                                const SizedBox(width: 8),
                                avatarUser,
                              ]
                            : [
                                avatarBot,
                                const SizedBox(width: 8),
                                Expanded(child: _bubble(m)),
                              ],
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          if (!_ready || _typing || _recording) const LinearProgressIndicator(),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    splashRadius: 22,
                    onPressed: _ready ? _imageSheet : null,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctl,
                      enabled: _ready && !_typing && !_recording,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  GestureDetector(
                    onLongPressStart: _micStart,
                    onLongPressEnd: _micEnd,
                    child: Icon(
                      _recording ? Icons.mic : Icons.mic_none,
                      color: _ready ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _ready ? Colors.purple : Colors.grey,
                    ),
                    splashRadius: 22,
                    onPressed: _ready && !_typing && !_recording ? _send : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Message m) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: m.isUser ? Colors.blue[200] : Colors.grey[300],
      borderRadius: BorderRadius.circular(16),
    ),
    child: m.hasImage
        ? Image.memory(m.imageBytes!, width: 160, fit: BoxFit.cover)
        : Text(m.text),
  );

  @override
  void dispose() {
    _ctl.dispose();
    _speech.stop();
    if (_ready) {
      _chat.session.close();
      _model.close();
    }
    super.dispose();
  }
}
