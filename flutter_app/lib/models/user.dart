import '../models/user_photo.dart';

class Interest {
  final int id;
  final String name;
  final String categoria;

  Interest({required this.id, required this.name, this.categoria = 'General'});

  factory Interest.fromJson(Map<String, dynamic> json) {
    final raw = json as Map<Object?, Object?>;
    return Interest(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      name: raw['name']?.toString() ?? '',
      categoria: raw['categoria']?.toString() ?? 'General',
    );
  }
}

class MusicGenre {
  final int id;
  final String name;
  final String categoria;

  MusicGenre({required this.id, required this.name, this.categoria = 'General'});

  factory MusicGenre.fromJson(Map<String, dynamic> json) {
    final raw = json as Map<Object?, Object?>;
    return MusicGenre(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      name: raw['name']?.toString() ?? '',
      categoria: raw['categoria']?.toString() ?? 'General',
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final int age;
  final String? bio;
  final String? genero;
  final String? localidad;
  final String? direccion;
  final String? profilePhotoUrl;
  final double? latitude;
  final double? longitude;
  final List<Interest> interests;
  final List<MusicGenre> musicGenres;
  final List<UserPhoto> photos;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    this.bio,
    this.genero,
    this.localidad,
    this.direccion,
    this.profilePhotoUrl,
    this.latitude,
    this.longitude,
    this.interests = const [],
    this.musicGenres = const [],
    this.photos = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final raw = json as Map<Object?, Object?>;
    return User(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      email: raw['email']?.toString() ?? '',
      name: raw['name']?.toString() ?? '',
      age: (raw['age'] as num?)?.toInt() ?? 18,
      bio: raw['bio']?.toString(),
      genero: raw['genero']?.toString(),
      localidad: raw['localidad']?.toString(),
      direccion: raw['direccion']?.toString(),
      profilePhotoUrl: raw['profilePhotoUrl']?.toString(),
      latitude: (raw['latitude'] as num?)?.toDouble(),
      longitude: (raw['longitude'] as num?)?.toDouble(),
      interests: (raw['interests'] as List<dynamic>? ?? [])
          .map((e) => Interest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      musicGenres: (raw['musicGenres'] as List<dynamic>? ?? [])
          .map((e) => MusicGenre.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      photos: (raw['photos'] as List<dynamic>? ?? [])
          .map((e) => UserPhoto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
