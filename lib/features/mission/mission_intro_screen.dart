import 'package:flutter/material.dart';
import 'package:plusone/config/routes.dart';

class MissionIntroScreen extends StatelessWidget {
  const MissionIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu primera misión')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ilustración opcional
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/water_mission.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Misión: Ahorra agua en la ducha',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Hoy vamos a medir tu tiempo de ducha para establecer tu tiempo base (baseline). '
                    'Desde mañana intentarás bajarlo un poco. Si mejoras tu tiempo, ¡ganas puntos y tu animal evoluciona!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const _Bullet(text: 'Pulsa “Empezar ahora” para abrir el cronómetro.'),
              const _Bullet(text: 'La primera vez solo estableces tu baseline.'),
              const _Bullet(text: 'Cada mejora respecto al baseline suma puntos (+10).'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.showerTimer),
                child: const Text('Empezar ahora 🚿'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                      (_) => false,
                ),
                child: const Text('Ver luego, ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
