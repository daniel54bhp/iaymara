// lib/utils/shared_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<SharedPreferences> _p() => SharedPreferences.getInstance();

  /* ─── Foto de perfil ─── */
  static const _photo = 'photo_path';
  static Future<String?> getPhotoPath() async => (await _p()).getString(_photo);
  static Future<void> setPhotoPath(String v) async =>
      (await _p()).setString(_photo, v);

  /* ─── Nombre y apellidos ─── */
  static const _first = 'first_name', _last = 'last_name';
  static Future<String?> getFirstName() async => (await _p()).getString(_first);
  static Future<String?> getLastName() async => (await _p()).getString(_last);
  static Future<void> setFirstName(String v) async =>
      (await _p()).setString(_first, v);
  static Future<void> setLastName(String v) async =>
      (await _p()).setString(_last, v);

  /* ─── Ruta del modelo (.task) ─── */
  static const _model = 'model_path';

  /// Lee la última ruta guardada (o null si no existe).
  static Future<String?> getModelPath() async => (await _p()).getString(_model);

  /// Guarda o actualiza la ruta del modelo.
  static Future<void> saveModelPath(String path) async =>
      (await _p()).setString(_model, path);

  /// Borra la ruta (útil si se elimina el archivo).
  static Future<void> clearModelPath() async => (await _p()).remove(_model);
}
