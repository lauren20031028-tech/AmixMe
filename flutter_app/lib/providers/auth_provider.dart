import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  int? _userId;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  ApiService get apiService => _apiService;

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _token = response['token'] as String;
      _userId = (response['userId'] as num).toInt();
      _apiService.setToken(_token!);
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setInt('userId', _userId!);
      // Guardar email para referencia
      await prefs.setString('email', email);

      // Cargar el perfil del usuario desde el servidor
      try {
        final user = await _apiService.getUserProfile(_userId!);
        if (user != null) {
          await prefs.setString('profile_name', user.name);
          await prefs.setInt('profile_age', user.age);
          await prefs.setString('profile_bio', user.bio ?? '');
          await prefs.setString('profile_genero', user.genero ?? 'Mujer');
          // Asegurar que la localidad siempre tenga un valor
          await prefs.setString('profile_localidad', user.localidad ?? 'Usaquén');
          await prefs.setString('profile_direccion', user.direccion ?? '');
          await prefs.setString('profile_interestIds', 
              user.interests.map((i) => i.id.toString()).join(','));
          await prefs.setString('profile_musicGenreIds', 
              user.musicGenres.map((g) => g.id.toString()).join(','));
          print('Profile saved: localidad=${user.localidad}');
        }
      } catch (e) {
        print('Error loading profile: $e');
        // Si falla la carga del perfil, inicializar con valores por defecto
        if (!prefs.containsKey('profile_name')) {
          await prefs.setString('profile_name', email.split('@').first);
          await prefs.setInt('profile_age', 18);
          await prefs.setString('profile_bio', '');
          await prefs.setString('profile_genero', 'Mujer');
          await prefs.setString('profile_localidad', 'Usaquén');
          await prefs.setString('profile_direccion', '');
          await prefs.setString('profile_interestIds', '');
          await prefs.setString('profile_musicGenreIds', '');
        }
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Credenciales incorrectas. Verifica tu email y contraseña.');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required String bio,
    required String genero,
    required String localidad,
    required String direccion,
    required List<int> interestIds,
    required List<int> musicGenreIds,
  }) async {
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
        age: age,
        bio: bio,
        genero: genero,
        localidad: localidad,
        direccion: direccion,
        interestIds: interestIds,
        musicGenreIds: musicGenreIds,
      );
      _token = response['token'] as String;
      _userId = (response['userId'] as num).toInt();
      _apiService.setToken(_token!);
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setInt('userId', _userId!);
      await prefs.setString('email', email);
      // Guardar datos del perfil recién registrado
      await prefs.setString('profile_name', name);
      await prefs.setInt('profile_age', age);
      await prefs.setString('profile_bio', bio);
      await prefs.setString('profile_genero', genero);
      await prefs.setString('profile_localidad', localidad);
      await prefs.setString('profile_direccion', direccion);
      await prefs.setString('profile_interestIds', interestIds.join(','));
      await prefs.setString('profile_musicGenreIds', musicGenreIds.join(','));

      notifyListeners();
    } catch (e) {
      throw Exception('Error al registrarse. El email puede estar en uso.');
    }
  }

  /// Guarda los datos del perfil en SharedPreferences (persiste entre sesiones)
  Future<void> saveProfileLocally({
    required String name,
    required int age,
    required String bio,
    required String genero,
    required String localidad,
    required String direccion,
    required List<int> interestIds,
    required List<int> musicGenreIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setInt('profile_age', age);
    await prefs.setString('profile_bio', bio);
    await prefs.setString('profile_genero', genero);
    await prefs.setString('profile_localidad', localidad);
    await prefs.setString('profile_direccion', direccion);
    await prefs.setString('profile_interestIds', interestIds.join(','));
    await prefs.setString('profile_musicGenreIds', musicGenreIds.join(','));
  }

  /// Lee los datos del perfil guardados localmente
  Future<Map<String, dynamic>> loadProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('profile_name') ?? '',
      'age': prefs.getInt('profile_age') ?? 18,
      'bio': prefs.getString('profile_bio') ?? '',
      'genero': prefs.getString('profile_genero') ?? 'Mujer',
      'localidad': prefs.getString('profile_localidad') ?? '',
      'direccion': prefs.getString('profile_direccion') ?? '',
      'interestIds': (prefs.getString('profile_interestIds') ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
      'musicGenreIds': (prefs.getString('profile_musicGenreIds') ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
    };
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getInt('userId');

    if (_token != null && _userId != null) {
      _apiService.setToken(_token!);
      _isAuthenticated = true;
      notifyListeners();
    }
  }
}
