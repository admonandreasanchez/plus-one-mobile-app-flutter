import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('No hay usuario autenticado');
    return uid;
  }

  /// Guarda/actualiza el animal elegido en el Onboarding.
  Future<void> setUserAnimal(String animal) async {
    final now = FieldValue.serverTimestamp();
    await _db.collection('users').doc(_uid).set(
      {
        'uid': _uid,
        'animal': animal,
        'updatedAt': now,
        'createdAt': now,                 // si ya existía, no se pisa (merge)
        'baselineSeconds': null,          // baseline inicial (si no existía)
        'points': FieldValue.increment(0) // asegura que exista el campo
      },
      SetOptions(merge: true),
    );
  }

  /// Obtiene el perfil del usuario (puede ser null si estás offline sin caché).
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      return doc.data();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return null; // offline sin caché
      rethrow;
    }
  }

  /// Registra ducha con transacción atómica:
  /// - Primera ducha: fija baseline
  /// - Si mejora: +10 puntos y actualiza baseline
  /// - Siempre registra el log en subcolección
  /// Devuelve: puntos ganados, si mejoró y el nuevo baseline (si cambió)
  Future<({int pointsGained, bool improved, int? newBaseline})> logShower(int durationSeconds) async {
    final userRef = _db.collection('users').doc(_uid);
    final showersRef = userRef.collection('showers');
    final newLogRef = showersRef.doc(); // docId manual para escribir en la transacción

    return await _db.runTransaction((txn) async {
      final userSnap = await txn.get(userRef);
      final data = (userSnap.data() as Map<String, dynamic>?) ?? {};

      int? baseline = (data['baselineSeconds'] is int) ? data['baselineSeconds'] as int : null;
      int currentPoints = (data['points'] ?? 0) is int ? data['points'] as int : 0;

      int gained = 0;
      bool improved = false;
      int? newBaseline;

      if (baseline == null) {
        // Primera ducha → baseline = duración actual
        baseline = durationSeconds;
        newBaseline = baseline;
        txn.set(userRef, {
          'baselineSeconds': baseline,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (durationSeconds < baseline) {
        // Mejoró → +10 puntos y nuevo baseline
        gained = 10;
        improved = true;
        newBaseline = durationSeconds;
        currentPoints += gained;

        txn.set(userRef, {
          'baselineSeconds': newBaseline,
          'points': currentPoints,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // No mejoró → solo updatedAt
        newBaseline = baseline;
        txn.set(userRef, {
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Registrar SIEMPRE la ducha
      txn.set(newLogRef, {
        'durationSeconds': durationSeconds,
        'createdAt': FieldValue.serverTimestamp(),
        'baselineAtMoment': baseline,
        'pointsGained': gained,
        'improved': improved,
        'newBaseline': newBaseline,
      });

      return (pointsGained: gained, improved: improved, newBaseline: newBaseline);
    });
  }

  /// (Opcional) Rehabilita red si quedó deshabilitada.
  Future<void> ensureNetworkEnabled() async {
    try {
      await _db.enableNetwork();
    } catch (_) {/* ignore */}
  }
}
