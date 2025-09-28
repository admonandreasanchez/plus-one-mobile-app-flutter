import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plusone/config/routes.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _loading = false;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/turtle.mp4')
      ..setLooping(true)
      ..setVolume(0) // Web: autoplay requiere muted
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pass.text.trim() != _confirm.text.trim()) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
      // Opcional: verificación por correo
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;
      // Vuelve al login o usa tu AuthGate para seguir flujo
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _humanizeAuthError(e));
    } catch (e) {
      setState(() => _error = 'Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _humanizeAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido.';
      case 'email-already-in-use':
        return 'Ese email ya está registrado.';
      case 'weak-password':
        return 'Contraseña muy débil (mín. 6 caracteres).';
      case 'operation-not-allowed':
        return 'Método de inicio deshabilitado en Firebase.';
      case 'network-request-failed':
        return 'Problema de red. Verifica tu conexión.';
      default:
        return 'Error: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de video
          if (_videoController.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Capa de oscurecido para contraste
          Container(color: Colors.black.withOpacity(0.4)),

          // Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16, 24, 16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Crear cuenta',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _pass,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _confirm,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),

                      // Botón principal: Crear cuenta
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                        style: FilledButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                          Colors.greenAccent.shade400, // resalta
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Crear cuenta'),
                      ),

                      const SizedBox(height: 12),

                      // Botón secundario: Ir a iniciar sesión
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.signIn,
                                  (_) => false,
                            ),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
