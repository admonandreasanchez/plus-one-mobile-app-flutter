import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plusone/config/routes.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plusone/l10n/app_localizations.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const kBoxColor = Color(0xFFFBEDD3); // #fbedd3
  static const kAppBarColor = Color(0xFF2E7D32);

  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  String? _error;
  bool _loading = false;
  bool _obscure = true;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/turtle.mp4')
      ..setLooping(true)
      ..setVolume(0) // autoplay (especialmente en Web) requiere mute
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
    _emailFocus.dispose();
    _passFocus.dispose();
    _videoController.dispose();
    super.dispose();
  }

  String _localizedAuthError(BuildContext context, FirebaseAuthException e) {
    final t = AppLocalizations.of(context)!;
    switch (e.code) {
      case 'invalid-email':
        return t.err_auth_invalid_email;
      case 'user-not-found':
      case 'wrong-password':
        return t.err_auth_wrong_credentials;
      case 'too-many-requests':
        return t.err_auth_too_many_requests;
      default:
        return t.err_auth_generic;
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (_email.text.trim().isEmpty) {
      setState(() => _error = t.msg_enter_email);
      return;
    }
    if (_pass.text.trim().isEmpty) {
      setState(() => _error = t.msg_enter_password);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _localizedAuthError(context, e));
    } catch (_) {
      setState(() => _error = t.err_auth_generic);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final t = AppLocalizations.of(context)!;
    final email = _email.text.trim();

    if (email.isEmpty) {
      setState(() => _error = t.msg_enter_email);
      _emailFocus.requestFocus();
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.msg_reset_sent)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.msg_reset_sent)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isNarrow = w < 420;
        final isWide = w > 900;

        final maxCardWidth = isWide ? 520.0 : (isNarrow ? 360.0 : 420.0);
        final titleSize = isWide ? 40.0 : (isNarrow ? 28.0 : 34.0);
        final overlayOpacity = isWide ? 0.40 : 0.45;

        return Scaffold(
          extendBodyBehindAppBar: true, // el video pasa por detrás del AppBar
          backgroundColor: Colors.black, // fallback mientras inicializa el video
          appBar: AppBar(
            toolbarHeight: kToolbarHeight * 1.3, // 30% más alta (opcional)
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'PlusOne',
              style: GoogleFonts.pacifico(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fondo de video responsivo con blur y letterbox
                if (_videoController.value.isInitialized) ...[
                  // capa cover (evita bordes vacíos)
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
                  // blur suave
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: const SizedBox(),
                    ),
                  ),
                  // video con aspect ratio original (letterbox)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ] else
                  const Center(child: CircularProgressIndicator()),

                // Capa de contraste
                Container(color: Colors.black.withOpacity(overlayOpacity)),

                // Contenido
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        24,
                        16,
                        16 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxCardWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Center(
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromARGB(230, 255, 255, 255),
                                      Colors.transparent,
                                    ],
                                    radius: 0.9,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/plusone_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Título con “pastilla” #fbedd3
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: kBoxColor.withOpacity(0.90),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                      color: Colors.black.withOpacity(0.18),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  t.signin_title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.pacifico(
                                    fontSize: titleSize,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email (fondo #fbedd3)
                            TextField(
                              controller: _email,
                              focusNode: _emailFocus,
                              decoration: InputDecoration(
                                labelText: t.field_email,
                                labelStyle: const TextStyle(color: Colors.black87),
                                prefixIcon: const Icon(Icons.mail_outline),
                                prefixIconColor: Colors.black54,
                                filled: true,
                                fillColor: kBoxColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.28),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Colors.redAccent),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              onSubmitted: (_) =>
                                  FocusScope.of(context).requestFocus(_passFocus),
                            ),
                            const SizedBox(height: 12),

                            // Password (fondo #fbedd3)
                            TextField(
                              controller: _pass,
                              focusNode: _passFocus,
                              decoration: InputDecoration(
                                labelText: t.field_password,
                                labelStyle: const TextStyle(color: Colors.black87),
                                prefixIcon: const Icon(Icons.lock_outline),
                                prefixIconColor: Colors.black54,
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  color: Colors.black54,
                                  tooltip: 'Mostrar/ocultar',
                                ),
                                filled: true,
                                fillColor: kBoxColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.28),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Colors.redAccent),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _sendPasswordReset,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                child: Text(t.btn_forgot_password),
                              ),
                            ),
                            const SizedBox(height: 8),

                            if (_error != null)
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 12),

                            // Botón: Iniciar sesión
                            _loading
                                ? const Center(child: CircularProgressIndicator())
                                : FilledButton(
                              style: FilledButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor:
                                Colors.greenAccent.shade400,
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(t.btn_signin),
                            ),
                            const SizedBox(height: 12),

                            // Botón: Crear cuenta
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
                                  Navigator.pushNamed(context, AppRoutes.signUp),
                              child: Text(t.btn_create_account),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
