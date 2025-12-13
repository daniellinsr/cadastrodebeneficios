import 'package:hive/hive.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';

/// DataSource local para cache de autenticação
///
/// Usa Hive para armazenar dados localmente
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

/// Implementação do AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _boxName = 'auth_cache';
  static const String _userKey = 'cached_user';

  Box? _box;

  /// Abrir box do Hive
  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final box = await _getBox();
    await box.put(_userKey, user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final box = await _getBox();
      final userData = box.get(_userKey);

      if (userData == null) {
        return null;
      }

      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      // Se houver erro ao ler cache, retornar null
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final box = await _getBox();
    await box.clear();
  }
}
