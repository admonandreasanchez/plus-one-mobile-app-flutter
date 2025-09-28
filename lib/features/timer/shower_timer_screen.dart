// lib/features/timer/shower_timer_screen.dart
import 'dart:async';
import 'dart:ui' as ui; // <- para el blur
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:plusone/services/firestore_service.dart';

class ShowerTimerScreen extends StatefulWidget {
  const ShowerTimerScreen({super.key});

  @override
  State<ShowerTimerScreen> createState() => _ShowerTimerScreenState();
}

class _ShowerTimerScreenState extends State<ShowerTimerScreen> {
  final Stopwatch _sw = Stopwatch();
  Timer? _tick;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController =
    VideoPlayerController.asset('assets/videos/shower_and_river.mp4')
      ..setLooping(true)
      ..setVolume(0) // autoplay en Web
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  void _start() {
    _sw.start();
    _tick ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _stop() async {
    _sw.stop();
    _tick?.cancel();
    _tick = null;
    setState(() {});

    final elapsedSeconds = (_sw.elapsedMilliseconds / 1000).round();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar tiempo de ducha'),
        content: Text('¿Confirmas que tu ducha duró $elapsedSeconds segundos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, guardar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await FirestoreService().logShower(elapsedSeconds);
      if (!mounted) return;

      final msg = result.improved
          ? '¡Mejoraste tu marca! +${result.pointsGained} puntos. Nuevo baseline: ${_format((result.newBaseline ?? elapsedSeconds) * 1000)}'
          : 'Tiempo guardado: ${_format(elapsedSeconds * 1000)}';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  void _reset() {
    _sw.reset();
    setState(() {});
  }

  String _format(int ms) {
    final seconds = (ms / 1000).floor();
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 480;
        final elapsed = _format(_sw.elapsedMilliseconds);

        return Scaffold(
          appBar: AppBar(title: const Text('Cronómetro de ducha')),
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (_videoController.value.isInitialized) ...[
                // Capa 1: fondo cover (se recorta), solo para rellenar
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
                // Capa 2: blur al fondo para que no distraiga
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: const SizedBox(),
                  ),
                ),
                // Capa 3: el video principal SIN recortes (letterbox)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ] else
                const Center(child: CircularProgressIndicator()),

              // Overlay para contraste del contenido
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.30)),
              ),

              // Contenido (cronómetro + botones)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                elapsed,
                                style: TextStyle(
                                  fontSize: isNarrow ? 48 : 64,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: isNarrow ? double.infinity : 140,
                                  child: FilledButton(
                                    onPressed: _start,
                                    child: const Text('Iniciar'),
                                  ),
                                ),
                                SizedBox(
                                  width: isNarrow ? double.infinity : 140,
                                  child: FilledButton(
                                    onPressed: _stop,
                                    child: const Text('Detener'),
                                  ),
                                ),
                                SizedBox(
                                  width: isNarrow ? double.infinity : 140,
                                  child: OutlinedButton(
                                    onPressed: _reset,
                                    child: const Text('Reiniciar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
