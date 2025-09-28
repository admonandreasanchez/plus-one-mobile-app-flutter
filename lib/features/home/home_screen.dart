import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plusone/config/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _emojiForAnimal(String animal) {
    switch (animal) {
      case 'turtle': return '🐢';
      case 'hummingbird': return '🐦';
      case 'eagle': return '🦅';
      case 'salamander': return '🦎';
      default: return '✨';
    }
  }

  String _labelForAnimal(String animal) {
    switch (animal) {
      case 'turtle': return 'Tortuga';
      case 'hummingbird': return 'Colibrí';
      case 'eagle': return 'Águila';
      case 'salamander': return 'Salamandra';
      default: return animal;
    }
  }

  /// Nueva función con breve descripción (máx. 20 palabras)
  String _descriptionForAnimal(String animal) {
    switch (animal) {
      case 'turtle':
        return 'Animal de agua, símbolo de paciencia y protección, conecta con calma y resistencia.';
      case 'hummingbird':
        return 'Animal de aire, mensajero de alegría y energía, representa ligereza y vitalidad.';
      case 'eagle':
        return 'Animal de fuego y aire, símbolo de visión, fuerza y poder espiritual que guía hacia lo alto.';
      case 'salamander':
        return 'Animal de tierra y fuego, ligado a la transformación, resistencia y energía interior.';
      default:
        return 'Un espíritu guía que refleja tu conexión con la naturaleza.';
    }
  }

  String _formatSeconds(int? seconds) {
    if (seconds == null) return '—';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snap.data!.data() ?? {};
        final animal = (data['animal'] ?? '—') as String;
        final baseline = data['baselineSeconds'] as int?;
        final points = (data['points'] ?? 0) as int;

        return Scaffold(
          appBar: AppBar(title: const Text('Tu progreso')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Tu animal espiritual',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_labelForAnimal(animal)} ${_emojiForAnimal(animal)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _descriptionForAnimal(animal),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiempo base de ducha:'),
                        Text(
                          _formatSeconds(baseline),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Puntos acumulados:'),
                        Text(
                          '$points ⭐',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.showerTimer),
                  child: const Text('Registrar nueva ducha 🚿'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
