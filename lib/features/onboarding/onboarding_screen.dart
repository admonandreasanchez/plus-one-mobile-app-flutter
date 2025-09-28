// lib/features/onboarding/onboarding_screen.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plusone/services/firestore_service.dart';
import 'package:plusone/config/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selected; // 'turtle' | 'hummingbird' | 'eagle' | 'salamander'
  bool _saving = false;

  late VideoPlayerController _bgVideo;

  @override
  void initState() {
    super.initState();
    _bgVideo = VideoPlayerController.asset('assets/videos/4animals_onboarding.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _bgVideo.play();
      });
  }

  @override
  void dispose() {
    _bgVideo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _saving = true);

    try {
      await FirestoreService()
          .setUserAnimal(_selected!)
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.missionIntro,
            (_) => false,
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin conexión. Se guardará cuando vuelva el internet.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.missionIntro, (_) => false);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Firebase: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _animalCard(String keyName, String label, String legend, String element, String asset) {
    final selected = _selected == keyName;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selected = keyName),
      child: Card(
        elevation: selected ? 6 : 0,
        color: Colors.white.withOpacity(0.06),
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? Colors.greenAccent.shade400 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  cacheWidth: 512,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Elemento: $element",
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                legend,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      (
      'turtle',
      'Tortuga',
      'Calma persistente y enfoque; avanza constante. Protege océanos reduciendo consumo de agua diaria en casa.',
      'Agua',
      'assets/images/turtle_stage1_optimized.webp'
      ),
      (
      'eagle',
      'Águila',
      'Visión amplia y fuerza; vuela alto. Inspira a otros cuidando aire limpio y reduciendo emisiones cotidianas.',
      'Aire',
      'assets/images/eagle_stage1_optimized.webp'
      ),
      (
      'hummingbird',
      'Colibrí',
      'Ligero y persistente; pequeños cambios transforman. Planta árboles, cuida suelos fértiles y promueve conexión con la tierra.',
      'Tierra',
      'assets/images/hummingbird_stage1_optimized.webp'
      ),
      (
      'salamander',
      'Salamandra',
      'Resiliente y transformador; resurge del cambio. Dúchate corto, apaga grifos, optimiza energía en casa siempre.',
      'Fuego',
      'assets/images/salamander_stage1_optimized.webp'
      ),
    ];

    return Scaffold(
      appBar:AppBar(
        toolbarHeight: kToolbarHeight * 1.30,
        title: Text(
          'Elige tu Animal',
          style: GoogleFonts.pacifico(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_bgVideo.value.isInitialized) ...[
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _bgVideo.value.size.width,
                  height: _bgVideo.value.size.height,
                  child: VideoPlayer(_bgVideo),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox(),
              ),
            ),
            Center(
              child: AspectRatio(
                aspectRatio: _bgVideo.value.aspectRatio,
                child: VideoPlayer(_bgVideo),
              ),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),

          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final crossAxisCount = isNarrow ? 1 : 2;
                final maxWidth = constraints.maxWidth.clamp(0, 1000.0).toDouble();

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                      child: Column(
                        children: [
                        Text(
                        'El animal que elijas definirá tus primeros retos, tu evolución visual '
                        'y la liga a la que pertenecerás dentro de PlusOne.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 3 / 4,
                              ),
                              itemCount: items.length,
                              itemBuilder: (_, i) =>
                                  _animalCard(items[i].$1, items[i].$2, items[i].$3, items[i].$4, items[i].$5),
                            ),
                          ),

                          // ✅ Botón con fondo blanco
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: FilledButton(
                                onPressed: (_saving || _selected == null) ? null : _save,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.greenAccent.shade400,
                                  foregroundColor: Colors.black,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text('Continuar'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
