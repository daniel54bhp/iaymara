import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/pigeon.g.dart';

class ChatScreen extends StatefulWidget {
  final String modelPath;
  const ChatScreen({Key? key, required this.modelPath}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late InferenceModel _model;
  late InferenceChat _chat;
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  bool _isReady = false; // modelo cargado
  bool _typing = false; // bot escribiendo

  @override
  void initState() {
    super.initState();
    _initGemma();
  }

  Future<void> _initGemma() async {
    final gemma = FlutterGemmaPlugin.instance;
    final file = File(widget.modelPath);

    if (!file.existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El archivo del modelo no existe.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    await gemma.modelManager.setModelPath(widget.modelPath);
    _model = await gemma.createModel(
      modelType: ModelType.gemmaIt,
      preferredBackend: PreferredBackend.gpu,
      maxTokens: 1024,
      supportImage: false,
    );
    _chat = await _model.createChat(
      temperature: 0.8,
      randomSeed: 42,
      topK: 1,
      supportImage: false,
    );

    if (mounted) setState(() => _isReady = true);
  }

  Future<void> _sendMessage() async {
    if (!_isReady) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    if (mounted) {
      setState(() {
        _messages.add(Message.text(text: text, isUser: true));
        _typing = true;
      });
    }

    _chat.addQueryChunk(Message.text(text: text, isUser: true));

    String buffer = '';
    await for (final token in _chat.generateChatResponseAsync()) {
      buffer += token;
      if (!mounted) return; // widget desmontado
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

  @override
  void dispose() {
    _controller.dispose();
    if (_isReady) {
      _chat.session.close();
      _model.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userIcon = Image.asset(
      'assets/images/icono.png',
      width: 32,
      height: 32,
    );
    final botIcon = const Icon(Icons.smart_toy, size: 32);

    return Scaffold(
      appBar: AppBar(title: const Text('IAymara')),
      body: Column(
        children: [
          // Aviso mientras el modelo carga
          if (!_isReady)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Flexible(child: Text('Modelo no cargado')),
                ],
              ),
            ),

          // Lista de mensajes
          Expanded(
            child: _isReady
                ? ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final left = msg.isUser ? userIcon : botIcon;
                      final right = msg.isUser ? botIcon : userIcon;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: msg.isUser
                            ? [
                                Expanded(child: _bubble(msg)),
                                const SizedBox(width: 8),
                                right,
                              ]
                            : [
                                left,
                                const SizedBox(width: 8),
                                Expanded(child: _bubble(msg)),
                              ],
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Barra de progreso (cargando modelo / respuesta)
          if (!_isReady || _typing) const LinearProgressIndicator(),

          // Barra de entrada
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: _isReady && !_typing,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isReady ? Colors.purple : Colors.grey,
                    ),
                    onPressed: _isReady && !_typing ? _sendMessage : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // burbuja de chat
  Widget _bubble(Message m) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: m.isUser ? Colors.blue[200] : Colors.grey[300],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(m.text),
  );
}
