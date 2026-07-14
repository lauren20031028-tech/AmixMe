import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/user_photo.dart';
import '../theme/app_theme.dart';
import 'photo_manager_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<Interest>   _todosIntereses = [];
  List<MusicGenre> _todosGeneros   = [];
  Set<int> _interesesSel = {};
  Set<int> _generosSel   = {};
  bool _isLoading = true;
  bool _isSaving  = false;
  UserPhoto? _fotoPrincipal;

  // Estados de expansión de bloques completos
  bool _interesesExpanded = false;
  bool _musicaExpanded = false;

  final _nameController  = TextEditingController();
  final _bioController   = TextEditingController();
  final _ageController   = TextEditingController();
  String? _generoSel;
  String? _localidadSel;

  static const _generos = [
    'Mujer',
    'Mujer trans',
    'No binario',
    'Género fluido',
    'Agénero',
    'Otros géneros',
    'Prefiero no decir',
  ];
  static const _localidades = [
    'Usaquén','Chapinero','Santa Fe','San Cristóbal','Usme',
    'Tunjuelito','Bosa','Kennedy','Fontibón','Engativá',
    'Suba','Barrios Unidos','Teusaquillo','Los Mártires',
    'Antonio Nariño','Puente Aranda','La Candelaria',
    'Rafael Uribe Uribe','Ciudad Bolívar','Sumapaz',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final auth = context.read<AuthProvider>();

    // Catálogos hardcodeados (el JAR viejo no tiene esos endpoints)
    final interesesTemp = <Interest>[
      Interest(id: 1, name: 'Pintura', categoria: 'Arte y Creatividad'),
      Interest(id: 2, name: 'Dibujo', categoria: 'Arte y Creatividad'),
      Interest(id: 3, name: 'Fotografía', categoria: 'Arte y Creatividad'),
      Interest(id: 4, name: 'Manualidades', categoria: 'Arte y Creatividad'),
      Interest(id: 5, name: 'Diseño gráfico', categoria: 'Arte y Creatividad'),
      Interest(id: 6, name: 'Escultura', categoria: 'Arte y Creatividad'),
      Interest(id: 7, name: 'Cerámica', categoria: 'Arte y Creatividad'),
      Interest(id: 8, name: 'Ver películas', categoria: 'Entretenimiento'),
      Interest(id: 9, name: 'Series y TV', categoria: 'Entretenimiento'),
      Interest(id: 10, name: 'Videojuegos', categoria: 'Entretenimiento'),
      Interest(id: 11, name: 'Anime', categoria: 'Entretenimiento'),
      Interest(id: 12, name: 'Cómics', categoria: 'Entretenimiento'),
      Interest(id: 13, name: 'Teatro', categoria: 'Entretenimiento'),
      Interest(id: 14, name: 'Yoga', categoria: 'Deporte y Bienestar'),
      Interest(id: 15, name: 'Gimnasio', categoria: 'Deporte y Bienestar'),
      Interest(id: 16, name: 'Ciclismo', categoria: 'Deporte y Bienestar'),
      Interest(id: 17, name: 'Natación', categoria: 'Deporte y Bienestar'),
      Interest(id: 18, name: 'Fútbol', categoria: 'Deporte y Bienestar'),
      Interest(id: 19, name: 'Senderismo', categoria: 'Deporte y Bienestar'),
      Interest(id: 20, name: 'Baile', categoria: 'Deporte y Bienestar'),
      Interest(id: 21, name: 'Pilates', categoria: 'Deporte y Bienestar'),
      Interest(id: 22, name: 'Lectura', categoria: 'Cultura y Conocimiento'),
      Interest(id: 23, name: 'Idiomas', categoria: 'Cultura y Conocimiento'),
      Interest(id: 24, name: 'Historia', categoria: 'Cultura y Conocimiento'),
      Interest(id: 25, name: 'Ciencia', categoria: 'Cultura y Conocimiento'),
      Interest(id: 26, name: 'Podcasts', categoria: 'Cultura y Conocimiento'),
      Interest(id: 27, name: 'Filosofía', categoria: 'Cultura y Conocimiento'),
      Interest(id: 28, name: 'Cocinar', categoria: 'Gastronomía'),
      Interest(id: 29, name: 'Repostería', categoria: 'Gastronomía'),
      Interest(id: 30, name: 'Explorar restaurantes', categoria: 'Gastronomía'),
      Interest(id: 31, name: 'Café de especialidad', categoria: 'Gastronomía'),
      Interest(id: 32, name: 'Viajes', categoria: 'Viajes y Naturaleza'),
      Interest(id: 33, name: 'Acampar', categoria: 'Viajes y Naturaleza'),
      Interest(id: 34, name: 'Jardinería', categoria: 'Viajes y Naturaleza'),
      Interest(id: 35, name: 'Observación de aves', categoria: 'Viajes y Naturaleza'),
      Interest(id: 36, name: 'Tocar guitarra', categoria: 'Música'),
      Interest(id: 37, name: 'Canto', categoria: 'Música'),
      Interest(id: 38, name: 'DJ', categoria: 'Música'),
      Interest(id: 39, name: 'Producción musical', categoria: 'Música'),
      Interest(id: 40, name: 'Ir a conciertos', categoria: 'Música'),
      Interest(id: 41, name: 'Programación', categoria: 'Tecnología'),
      Interest(id: 42, name: 'Inteligencia artificial', categoria: 'Tecnología'),
      Interest(id: 43, name: 'Robótica', categoria: 'Tecnología'),
      Interest(id: 44, name: 'Gadgets', categoria: 'Tecnología'),
    ];

    final generosTemp = <MusicGenre>[
      MusicGenre(id: 1, name: 'Pop latino', categoria: 'Pop'),
      MusicGenre(id: 2, name: 'Pop en inglés', categoria: 'Pop'),
      MusicGenre(id: 3, name: 'K-Pop', categoria: 'Pop'),
      MusicGenre(id: 4, name: 'Pop alternativo', categoria: 'Pop'),
      MusicGenre(id: 5, name: 'Reggaetón', categoria: 'Urbano'),
      MusicGenre(id: 6, name: 'Trap', categoria: 'Urbano'),
      MusicGenre(id: 7, name: 'Afrobeats', categoria: 'Urbano'),
      MusicGenre(id: 8, name: 'Dembow', categoria: 'Urbano'),
      MusicGenre(id: 9, name: 'Dancehall', categoria: 'Urbano'),
      MusicGenre(id: 10, name: 'Rock clásico', categoria: 'Rock'),
      MusicGenre(id: 11, name: 'Rock alternativo', categoria: 'Rock'),
      MusicGenre(id: 12, name: 'Metal', categoria: 'Rock'),
      MusicGenre(id: 13, name: 'Punk', categoria: 'Rock'),
      MusicGenre(id: 14, name: 'Indie rock', categoria: 'Rock'),
      MusicGenre(id: 15, name: 'House', categoria: 'Electrónica'),
      MusicGenre(id: 16, name: 'Techno', categoria: 'Electrónica'),
      MusicGenre(id: 17, name: 'EDM', categoria: 'Electrónica'),
      MusicGenre(id: 18, name: 'Lo-fi', categoria: 'Electrónica'),
      MusicGenre(id: 19, name: 'Ambient', categoria: 'Electrónica'),
      MusicGenre(id: 20, name: 'Música clásica', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 21, name: 'Jazz', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 22, name: 'Blues', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 23, name: 'Soul', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 24, name: 'Vallenato', categoria: 'Colombiana'),
      MusicGenre(id: 25, name: 'Cumbia', categoria: 'Colombiana'),
      MusicGenre(id: 26, name: 'Salsa', categoria: 'Colombiana'),
      MusicGenre(id: 27, name: 'Mapalé', categoria: 'Colombiana'),
      MusicGenre(id: 28, name: 'Champeta', categoria: 'Colombiana'),
      MusicGenre(id: 29, name: 'Hip-hop', categoria: 'Hip-Hop'),
      MusicGenre(id: 30, name: 'R&B', categoria: 'Hip-Hop'),
      MusicGenre(id: 31, name: 'Neo soul', categoria: 'Hip-Hop'),
    ];

    // Cargar datos del perfil desde SharedPreferences
    final savedProfile = await auth.loadProfileLocally();

    if (!mounted) return;
    setState(() {
      _todosIntereses = interesesTemp;
      _todosGeneros = generosTemp;

      // Usar datos guardados localmente
      final name = savedProfile['name'] as String;
      final age = savedProfile['age'] as int;
      final bio = savedProfile['bio'] as String;
      final genero = savedProfile['genero'] as String;
      final localidad = savedProfile['localidad'] as String;
      final interestIds = savedProfile['interestIds'] as List<int>;
      final musicGenreIds = savedProfile['musicGenreIds'] as List<int>;

      _nameController.text = name;
      _bioController.text = bio;
      _ageController.text = age > 0 ? age.toString() : '';
      _generoSel = genero.isNotEmpty ? genero : null;
      _localidadSel = localidad.isNotEmpty ? localidad : null;
      _interesesSel = interestIds.toSet();
      _generosSel = musicGenreIds.toSet();

      _isLoading = false;
    });

    // Cargar foto principal en paralelo
    if (auth.userId != null) {
      try {
        final photos = await auth.apiService.getUserPhotos(auth.userId!);
        if (mounted && photos.isNotEmpty) {
          final primary = photos.firstWhere(
            (p) => p.isPrimary,
            orElse: () => photos.first,
          );
          setState(() => _fotoPrincipal = primary);
        }
      } catch (_) {}
    }
  }

  Future<void> _guardar() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 18 || age > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una edad válida (18-99)')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthProvider>();

      // Guardar en SharedPreferences (persiste entre sesiones)
      await auth.saveProfileLocally(
        name: _nameController.text.trim(),
        age: age,
        bio: _bioController.text.trim(),
        genero: _generoSel ?? '',
        localidad: _localidadSel ?? '',
        direccion: '',
        interestIds: _interesesSel.toList(),
        musicGenreIds: _generosSel.toList(),
      );

      // También actualizar en el backend si hay userId
      if (auth.userId != null) {
        try {
          await auth.apiService.updateProfile(
            userId: auth.userId!,
            name: _nameController.text.trim(),
            age: age,
            bio: _bioController.text.trim(),
            genero: _generoSel ?? '',
            localidad: _localidadSel ?? '',
            direccion: '',
            interestIds: _interesesSel.toList(),
            musicGenreIds: _generosSel.toList(),
          );
        } catch (e) {
          // Si falla el backend, continuar (los datos están guardados localmente)
          print('Error actualizando backend: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil guardado correctamente ✓'),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cerrarSesion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('¿Segura que quieres cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coral))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInfoBasica(),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        titulo: 'Mis pasatiempos',
                        icono: Icons.star_outline_rounded,
                        color: AppColors.pink,
                        child: _buildChipsIntereses(),
                        isCollapsible: true,
                        isExpanded: _interesesExpanded,
                        onToggle: () => setState(() => _interesesExpanded = !_interesesExpanded),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        titulo: 'Mis gustos musicales',
                        icono: Icons.music_note_outlined,
                        color: AppColors.purple,
                        child: _buildChipsMusica(),
                        isCollapsible: true,
                        isExpanded: _musicaExpanded,
                        onToggle: () => setState(() => _musicaExpanded = !_musicaExpanded),
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: 'Guardar cambios',
                        onPressed: _guardar,
                        isLoading: _isSaving,
                        icon: Icons.save_rounded,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _cerrarSesion,
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.redAccent, size: 18),
                          label: const Text('Cerrar sesión',
                              style: TextStyle(color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.pink,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blush, AppColors.lavender, AppColors.mauve, AppColors.purple],
              stops: [0.0, 0.35, 0.68, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white60, width: 2.5),
                    ),
                    child: ClipOval(
                      child: _fotoPrincipal != null
                          ? Image.network(
                              context.read<AuthProvider>().apiService
                                  .getPhotoUrl(_fotoPrincipal!.photoUrl),
                              fit: BoxFit.cover,
                              width: 86,
                              height: 86,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.person_rounded,
                              size: 48, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhotoManagerScreen(),
                          ),
                        );
                        // Recargar foto principal al volver
                        final auth = context.read<AuthProvider>();
                        if (auth.userId != null) {
                          try {
                            final photos = await auth.apiService
                                .getUserPhotos(auth.userId!);
                            if (mounted && photos.isNotEmpty) {
                              final primary = photos.firstWhere(
                                (p) => p.isPrimary,
                                orElse: () => photos.first,
                              );
                              setState(() => _fotoPrincipal = primary);
                            } else if (mounted) {
                              setState(() => _fotoPrincipal = null);
                            }
                          } catch (_) {}
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: AppColors.coral),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'Mi perfil',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              if (_localidadSel != null)
                Text(
                  _localidadSel!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          onSelected: (v) {
            if (v == 'logout') _cerrarSesion();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text('Cerrar sesión',
                      style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBasica() {
    return _buildSeccion(
      titulo: 'Información básica',
      icono: Icons.person_outline_rounded,
      color: AppColors.mauve,
      child: Column(
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Nombre',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _ageController,
            label: 'Edad',
            prefixIcon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _bioController,
            label: 'Biografía',
            prefixIcon: Icons.edit_note_rounded,
            maxLines: 3,
            maxLength: 200,
            hint: 'Cuéntales a otras personas quién eres...',
          ),
          const SizedBox(height: 12),
          _dropdown(
            value: _generoSel,
            label: 'Género',
            icon: Icons.wc_outlined,
            items: _generos,
            onChanged: (v) => setState(() => _generoSel = v),
          ),
          const SizedBox(height: 12),
          _dropdown(
            value: _localidadSel,
            label: 'Localidad en Bogotá',
            icon: Icons.location_city_outlined,
            items: _localidades,
            onChanged: (v) => setState(() => _localidadSel = v),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsIntereses() {
    final Map<String, List<Interest>> grupos = {};
    for (final i in _todosIntereses) {
      grupos.putIfAbsent(i.categoria, () => []).add(i);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grupos.entries.map((e) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(
                e.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pink,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: e.value.map((item) {
                final sel = _interesesSel.contains(item.id);
                return FilterChip(
                  label: Text(item.name),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    sel
                        ? _interesesSel.remove(item.id)
                        : _interesesSel.add(item.id);
                  }),
                  selectedColor: AppColors.blush,
                  backgroundColor: const Color(0xFFFCE8F3),
                  checkmarkColor: AppColors.pink,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: sel
                        ? AppColors.pink
                        : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChipsMusica() {
    final Map<String, List<MusicGenre>> grupos = {};
    for (final g in _todosGeneros) {
      grupos.putIfAbsent(g.categoria, () => []).add(g);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grupos.entries.map((e) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(
                e.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purple,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: e.value.map((item) {
                final sel = _generosSel.contains(item.id);
                return FilterChip(
                  label: Text(item.name),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    sel
                        ? _generosSel.remove(item.id)
                        : _generosSel.add(item.id);
                  }),
                  selectedColor: const Color(0xFFF0E6FA),
                  backgroundColor: const Color(0xFFF5EEFF),
                  checkmarkColor: AppColors.purple,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: sel ? AppColors.purple : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget child,
    bool isCollapsible = false,
    bool isExpanded = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isCollapsible ? onToggle : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCollapsible) ...[
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: color,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
          if (isExpanded || !isCollapsible) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
