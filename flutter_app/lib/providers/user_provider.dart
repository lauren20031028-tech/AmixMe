import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _nearbyUsers = [];
  Position? _currentPosition;
  
  // Filtros activos
  String? _filterLocalidad;
  List<int> _filterInterestIds = [];
  List<int> _filterMusicGenreIds = [];

  List<User> get nearbyUsers => _nearbyUsers;
  Position? get currentPosition => _currentPosition;
  String? get filterLocalidad => _filterLocalidad;
  List<int> get filterInterestIds => _filterInterestIds;
  List<int> get filterMusicGenreIds => _filterMusicGenreIds;
  
  bool get hasActiveFilters => 
      (_filterLocalidad != null && _filterLocalidad!.isNotEmpty) ||
      _filterInterestIds.isNotEmpty ||
      _filterMusicGenreIds.isNotEmpty;

  /// Carga usuarias compatibles usando localidad e intereses comunes.
  Future<void> loadNearbyUsers(ApiService apiService, int userId,
      {String? localidadFallback}) async {
    
    try {
      // Determinar la localidad a usar
      String localidadToUse = _filterLocalidad ?? localidadFallback ?? 'Usaquén';
      
      print('DEBUG UserProvider: Loading users for userId=$userId, localidad="$localidadToUse"');
      
      // Si hay filtros activos, usar el endpoint de filtrado
      if (hasActiveFilters) {
        print('DEBUG UserProvider: Using filter endpoint');
        _nearbyUsers = await apiService.filterUsers(
          userId: userId,
          localidad: localidadToUse,
          interestIds: _filterInterestIds.isNotEmpty ? _filterInterestIds : null,
          musicGenreIds: _filterMusicGenreIds.isNotEmpty ? _filterMusicGenreIds : null,
        );
      } else {
        // Usar localidad para buscar usuarias compatibles
        print('DEBUG UserProvider: Using compatible users endpoint');
        _nearbyUsers = await apiService.getCompatibleUsersByLocalidad(userId, localidadToUse);
      }
      
      print('DEBUG UserProvider: Got ${_nearbyUsers.length} users');
    } catch (e) {
      print('Error loading nearby users: $e');
      _nearbyUsers = [];
    }

    notifyListeners();
  }

  /// Aplica filtros y recarga los usuarios
  Future<void> applyFilters(ApiService apiService, int userId, {
    String? localidad,
    List<int>? interestIds,
    List<int>? musicGenreIds,
  }) async {
    _filterLocalidad = localidad;
    _filterInterestIds = interestIds ?? [];
    _filterMusicGenreIds = musicGenreIds ?? [];
    
    await loadNearbyUsers(apiService, userId);
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _filterLocalidad = null;
    _filterInterestIds = [];
    _filterMusicGenreIds = [];
    notifyListeners();
  }

  void setLocalidad(String localidad) {
    // Method kept for potential future use
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    ).timeout(const Duration(seconds: 8), onTimeout: () {
      throw Exception('GPS timeout');
    });
  }

  void removeUser(int index) {
    if (index < _nearbyUsers.length) {
      _nearbyUsers.removeAt(index);
      notifyListeners();
    }
  }
}
