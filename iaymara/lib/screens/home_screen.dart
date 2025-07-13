import 'package:flutter/material.dart';
import 'package:iaymara/screens/chat_screen_mat.dart';
import 'package:iaymara/screens/chat_screen_plants.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _card({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage('assets/images/icono.png'),
                ),
                const SizedBox(height: 8),
                Text(
                  'IAymara',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Menú principal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _card(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                _card(
                  icon: Icons.language,
                  label: 'Chat Aymara',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChatScreen(modelPath: '', initialMessages: []),
                    ),
                  ),
                ),
                _card(
                  icon: Icons.nature,
                  label: 'Chat cuidado de plantas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatScreenPlants(
                        modelPath: '',
                        initialMessages: [],
                      ),
                    ),
                  ),
                ),
                _card(
                  icon: Icons.video_chat_sharp,
                  label: 'Chat experto en matematicas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatScreenMat(
                        modelPath: '',
                        initialMessages: [],
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
