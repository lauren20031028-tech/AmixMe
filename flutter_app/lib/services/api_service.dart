import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/user_photo.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    return 'http://10.0.2.2:8080/api';
  }

  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> _headers() => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'age': age,
        'bio': bio,
        'genero': genero,
        'localidad': localidad,
        'direccion': direccion,
        'interestIds': interestIds,
        'musicGenreIds': musicGenreIds,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error en registro: ${response.body}');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Intentando login con: $email');
    final requestBody = jsonEncode({'email': email, 'password': password});
    print('Request body: $requestBody');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: requestBody,
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Credenciales inválidas: ${response.body}');
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) throw Exception('Error al enviar correo');
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );
    if (response.statusCode != 200) throw Exception('Token inválido o expirado');
  }

  // ── Catálogos ─────────────────────────────────────────────────────────────

  Future<List<Interest>> getInterests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/interests'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Interest.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<MusicGenre>> getMusicGenres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/music-genres'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => MusicGenre.fromJson(e))
          .toList();
    }
    return [];
  }

  // ── Usuarios ──────────────────────────────────────────────────────────────

  Future<User?> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<User?> getUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<User?> updateProfile({
    required int userId,
    required String name,
    required int age,
    required String bio,
    required String genero,
    required String localidad,
    required String direccion,
    required List<int> interestIds,
    required List<int> musicGenreIds,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'age': age,
        'bio': bio,
        'genero': genero,
        'localidad': localidad,
        'direccion': direccion,
        'interestIds': interestIds,
        'musicGenreIds': musicGenreIds,
      }),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al guardar perfil: ${response.body}');
  }

  /// Usuarias compatibles ordenadas por score de intereses + música.
  /// Usa GPS si se proveen lat/lon, si no usa localidad.
  Future<List<User>> getCompatibleUsers({
    required int userId,
    double? lat,
    double? lon,
    int maxDistance = 15,
    String? localidad,
  }) async {
    String url = '$baseUrl/users/compatible/$userId?maxDistance=$maxDistance';
    if (lat != null && lon != null) {
      url += '&lat=$lat&lon=$lon';
    }
    if (localidad != null && localidad.isNotEmpty) {
      url += '&localidad=${Uri.encodeComponent(localidad)}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers());
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<User>> getNearbyUsers(
      int userId, double lat, double lon, int maxDistance) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/users/nearby/$userId?lat=$lat&lon=$lon&maxDistance=$maxDistance'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<User>> getUsersByLocalidad(int userId, String localidad) async {
    final encoded = Uri.encodeComponent(localidad);
    final response = await http.get(
      Uri.parse('$baseUrl/users/localidad/$userId?localidad=$encoded'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<User>> getCompatibleUsersByLocalidad(int userId, String localidad) async {
    final encoded = Uri.encodeComponent(localidad);
    final url = '$baseUrl/users/compatible/$userId?localidad=$encoded';
    
    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => User.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> swipe(int swiperId, int swipedId, bool isLike) async {
    await http.post(
      Uri.parse('$baseUrl/swipes'),
      headers: _headers(),
      body: jsonEncode({
        'swiperId': swiperId,
        'swipedId': swipedId,
        'isLike': isLike,
      }),
    );
  }

  // ── Matches ───────────────────────────────────────────────────────────────

  Future<List<dynamic>> getMatches(int userId) async {
    print('DEBUG: getMatches called for userId: $userId');
    print('DEBUG: URL: $baseUrl/matches/user/$userId');
    print('DEBUG: Headers: ${_headers()}');
    
    final response = await http.get(
      Uri.parse('$baseUrl/matches/user/$userId'),
      headers: _headers(),
    );
    
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('DEBUG: Decoded matches: $decoded');
      return decoded;
    }
    print('DEBUG: Returning empty list due to status code: ${response.statusCode}');
    return [];
  }

  Future<List<User>> getLikesSent(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/swipes/sent/$userId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<User>> getLikesReceived(int userId) async {
    print('DEBUG: getLikesReceived called for userId: $userId');
    print('DEBUG: URL: $baseUrl/swipes/received/$userId');
    
    final response = await http.get(
      Uri.parse('$baseUrl/swipes/received/$userId'),
      headers: _headers(),
    );
    
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body length: ${response.body.length}');
    
    if (response.statusCode == 200) {
      final decoded = (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
      print('DEBUG: Decoded ${decoded.length} received likes');
      return decoded;
    }
    print('DEBUG: Returning empty list due to status code: ${response.statusCode}');
    return [];
  }

  // ── Mensajes ──────────────────────────────────────────────────────────────

  Future<List<Message>> getMessages(int matchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/match/$matchId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Message.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<Message> sendMessage(int matchId, int senderId, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: _headers(),
      body: jsonEncode({'matchId': matchId, 'senderId': senderId, 'text': text}),
    );
    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al enviar mensaje');
  }

  Future<void> updateLocation(int userId, double lat, double lon) async {
    await http.put(
      Uri.parse('$baseUrl/users/$userId/location'),
      headers: _headers(),
      body: jsonEncode({'latitude': lat, 'longitude': lon}),
    );
  }

  /// Filtra usuarias por localidad y/o intereses/géneros musicales
  Future<List<User>> filterUsers({
    required int userId,
    String? localidad,
    List<int>? interestIds,
    List<int>? musicGenreIds,
  }) async {
    String url = '$baseUrl/users/filter/$userId?';
    
    if (localidad != null && localidad.isNotEmpty) {
      url += 'localidad=${Uri.encodeComponent(localidad)}&';
    }
    if (interestIds != null && interestIds.isNotEmpty) {
      url += 'interestIds=${interestIds.join(',')}&';
    }
    if (musicGenreIds != null && musicGenreIds.isNotEmpty) {
      url += 'musicGenreIds=${musicGenreIds.join(',')}&';
    }
    
    // Remover el último & si existe
    if (url.endsWith('&')) {
      url = url.substring(0, url.length - 1);
    }
    
    final response = await http.get(Uri.parse(url), headers: _headers());
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => User.fromJson(e))
          .toList();
    }
    return [];
  }

  // ── Fotos de usuario ─────────────────────────────────────────────────────────
  
  Future<List<UserPhoto>> getUserPhotos(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/user/$userId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => UserPhoto.fromJson(e))
          .toList();
    }
    return [];
  }
  
  Future<UserPhoto?> uploadPhoto(int userId, XFile imageFile, int photoOrder) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload/$userId'),
      );
      
      // Agregar headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      // Agregar archivo - compatible con web y móvil
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name.isNotEmpty ? imageFile.name : 'photo.jpg';
      
      // Detectar content type por extensión para que el backend lo acepte
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'png'  => 'image/png',
        'gif'  => 'image/gif',
        'webp' => 'image/webp',
        _      => 'image/jpeg',
      };
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));
      
      // Agregar parámetros
      request.fields['order'] = photoOrder.toString();
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return UserPhoto.fromJson(jsonDecode(responseBody));
      } else {
        print('Upload failed with status: ${response.statusCode}');
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
    return null;
  }
  
  Future<bool> deletePhoto(int userId, int photoOrder) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/photos/user/$userId/order/$photoOrder'),
      headers: _headers(),
    );
    return response.statusCode == 200;
  }
  
  Future<bool> validateMinimumPhotos(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/photos/user/$userId/validation'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    return false;
  }
  
  String getPhotoUrl(String photoUrl) {
    // Si es una URL completa (externa), devolverla tal como está
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    }
    
    // Si es una URL local que ya incluye /api/, construir correctamente
    if (photoUrl.startsWith('/api/')) {
      // Remover /api/ del photoUrl y usar baseUrl completo
      return baseUrl + photoUrl.substring(4);
    }
    
    // Si es una URL relativa, agregar baseUrl
    return baseUrl + photoUrl;
  }
}