import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'user_profile_screen.dart';
import 'chat_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with AutomaticKeepAliveClientMixin {
  final CardSwiperController _controller = CardSwiperController();
  bool _isLoading = true;
  List<Interest> _allInterests = [];
  List<MusicGenre> _allMusicGenres = [];

  // ── Filtros ──────────────────────────────────────────────────────────────
  RangeValues _edadRange = const RangeValues(18, 50);
  Set<int> _filtroIntereses = {};
  Set<int> _filtroMusica = {};

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadCatalogs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadUsers();
    });
  }

  Future<void> _loadCatalogs() async {
    final auth = context.read<AuthProvider>();
    try {
      _allInterests = await auth.apiService.getInterests();
      _allMusicGenres = await auth.apiService.getMusicGenres();
      if (mounted) setState(() {});
    } catch (e) {
      // Ignorar errores de catálogos
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    if (auth.userId != null) {
      try {
        final savedProfile = await auth.loadProfileLocally();
        var localidad = (savedProfile['localidad'] as String?) ?? '';
        
        print('DEBUG: Loaded localidad from prefs: "$localidad"');
        
        // Si la localidad está vacía, usar una por defecto
        if (localidad.isEmpty) {
          localidad = 'Usaquén';
          print('DEBUG: Localidad was empty, using default: "$localidad"');
        }
        
        userProvider.setLocalidad(localidad);
        print('DEBUG: About to load nearby users with localidad: "$localidad"');
        
        await userProvider.loadNearbyUsers(
          auth.apiService,
          auth.userId!,
          localidadFallback: localidad,
        );
        
        print('DEBUG: Loaded ${userProvider.nearbyUsers.length} nearby users');
      } catch (e) {
        print('Error cargando usuarios: $e');
        // Intentar con localidad por defecto
        print('DEBUG: Retrying with default localidad: "Usaquén"');
        await userProvider.loadNearbyUsers(
          auth.apiService,
          auth.userId!,
          localidadFallback: 'Usaquén',
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _abrirPerfil(User user) async {
    final auth = context.read<AuthProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          user: user,
          onLike: () async {
            await auth.apiService.swipe(auth.userId!, user.id, true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Le diste like a ${user.name}! 💜'),
                  backgroundColor: AppColors.purple,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _openChatWithCurrentUser() async {
    final userProvider = context.read<UserProvider>();
    final auth = context.read<AuthProvider>();
    
    if (userProvider.nearbyUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay usuarios disponibles para chatear'),
          backgroundColor: AppColors.mauve,
        ),
      );
      return;
    }
    
    // Obtener el usuario actual (el que está en la parte superior del stack)
    final currentUser = userProvider.nearbyUsers[0];
    
    try {
      // Verificar si ya existe un match entre estos usuarios
      final matches = await auth.apiService.getMatches(auth.userId!);
      final existingMatch = matches.firstWhere(
        (match) {
          final otherUser = match['user1']['id'] == auth.userId
              ? match['user2']
              : match['user1'];
          return otherUser['id'] == currentUser.id;
        },
        orElse: () => null,
      );
      
      if (existingMatch != null) {
        // Ya existe un match, abrir el chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              matchId: existingMatch['id'] as int,
              otherUserName: currentUser.name,
            ),
          ),
        );
      } else {
        // No existe match, mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Primero dale like a ${currentUser.name} para poder chatear'),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al verificar el match'),
          backgroundColor: AppColors.mauve,
        ),
      );
    }
  }

  Future<bool> _handleSwipe(
      int index, int? previousIndex, CardSwiperDirection direction) async {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (index < userProvider.nearbyUsers.length) {
      final user = userProvider.nearbyUsers[index];
      final isLike = direction == CardSwiperDirection.right;
      await auth.apiService.swipe(auth.userId!, user.id, isLike);

      if (isLike && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Le diste like a ${user.name}! 💜'),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    return true;
  }

  Future<void> _cerrarSesion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('¿Segura que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  // ── Modal de filtros ─────────────────────────────────────────────────────
  void _abrirFiltros() {
    // Copias temporales para el modal
    RangeValues edadTemp = _edadRange;
    Set<int> interesesTemp = Set.from(_filtroIntereses);
    Set<int> musicaTemp = Set.from(_filtroMusica);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0C8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Filtros de búsqueda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Botón limpiar
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              edadTemp = const RangeValues(18, 50);
                              interesesTemp.clear();
                              musicaTemp.clear();
                            });
                          },
                          child: const Text(
                            'Limpiar',
                            style: TextStyle(
                                color: AppColors.mauve,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24, indent: 24, endIndent: 24),
                  // Contenido scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Rango de edad ──────────────────────────────
                          _filtroTitulo(
                              Icons.cake_outlined, 'Rango de edad'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _edadBadge(edadTemp.start.round()),
                              const Text('—',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                              _edadBadge(edadTemp.end.round()),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(ctx).copyWith(
                              activeTrackColor: AppColors.pink,
                              inactiveTrackColor:
                                  AppColors.blush,
                              thumbColor: AppColors.purple,
                              overlayColor:
                                  AppColors.purple.withOpacity(0.15),
                              rangeThumbShape:
                                  const RoundRangeSliderThumbShape(
                                      enabledThumbRadius: 10),
                              trackHeight: 4,
                            ),
                            child: RangeSlider(
                              values: edadTemp,
                              min: 18,
                              max: 60,
                              divisions: 42,
                              onChanged: (v) =>
                                  setModalState(() => edadTemp = v),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Intereses ──────────────────────────────────
                          if (_allInterests.isNotEmpty) ...[
                            _filtroTitulo(
                                Icons.star_outline_rounded, 'Pasatiempos'),
                            const SizedBox(height: 10),
                            _buildFiltroChips(
                              items: _allInterests
                                  .map((i) =>
                                      _ChipItem(id: i.id, name: i.name))
                                  .toList(),
                              selected: interesesTemp,
                              color: AppColors.pink,
                              bgColor: const Color(0xFFFCE8F3),
                              onToggle: (id) => setModalState(() {
                                interesesTemp.contains(id)
                                    ? interesesTemp.remove(id)
                                    : interesesTemp.add(id);
                              }),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Música ─────────────────────────────────────
                          if (_allMusicGenres.isNotEmpty) ...[
                            _filtroTitulo(
                                Icons.music_note_outlined, 'Géneros musicales'),
                            const SizedBox(height: 10),
                            _buildFiltroChips(
                              items: _allMusicGenres
                                  .map((g) =>
                                      _ChipItem(id: g.id, name: g.name))
                                  .toList(),
                              selected: musicaTemp,
                              color: AppColors.purple,
                              bgColor: const Color(0xFFF0E6FA),
                              onToggle: (id) => setModalState(() {
                                musicaTemp.contains(id)
                                    ? musicaTemp.remove(id)
                                    : musicaTemp.add(id);
                              }),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Si no hay catálogos cargados
                          if (_allInterests.isEmpty &&
                              _allMusicGenres.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.blush,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: AppColors.mauve),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Los filtros de intereses y música estarán disponibles cuando el servidor esté conectado.',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Botón aplicar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: GradientButton(
                      label: 'Aplicar filtros',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        setState(() {
                          _edadRange = edadTemp;
                          _filtroIntereses = interesesTemp;
                          _filtroMusica = musicaTemp;
                        });
                        Navigator.pop(ctx);
                        _loadUsers();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filtroTitulo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.pink, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _edadBadge(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$value años',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }

  Widget _buildFiltroChips({
    required List<_ChipItem> items,
    required Set<int> selected,
    required Color color,
    required Color bgColor,
    required void Function(int) onToggle,
  }) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: items.map((item) {
        final sel = selected.contains(item.id);
        return GestureDetector(
          onTap: () => onToggle(item.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: sel ? AppColors.primaryGradient : null,
              color: sel ? null : bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? Colors.transparent : color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Colors.white : color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool hayFiltros = _filtroIntereses.isNotEmpty ||
        _filtroMusica.isNotEmpty ||
        _edadRange != const RangeValues(18, 50);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient
                  .createShader(bounds),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient
                  .createShader(bounds),
              child: const Text(
                'FriendMatch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Botón filtros con badge si hay filtros activos
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filtros',
                onPressed: _abrirFiltros,
              ),
              if (hayFiltros)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _loadUsers,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.pink)))
          : Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final hasUsers = userProvider.nearbyUsers.isNotEmpty;
                
                if (!hasUsers) {
                  return _buildEmpty();
                }
                
                // CardSwiper necesita al menos 2 tarjetas para funcionar correctamente
                // Si hay solo 1 usuario, mostrar una vista especial
                if (userProvider.nearbyUsers.length == 1) {
                  return _buildSingleUserView(userProvider.nearbyUsers[0]);
                }
                
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: CardSwiper(
                        controller: _controller,
                        cardsCount: userProvider.nearbyUsers.length,
                        onSwipe: _handleSwipe,
                        padding: EdgeInsets.zero,
                        cardBuilder: (context, index, _, __) {
                          if (index >= userProvider.nearbyUsers.length) {
                            return const SizedBox.shrink();
                          }
                          return _buildUserCard(
                              userProvider.nearbyUsers[index]);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildActionButtons(),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blush,
                    AppColors.pink.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 52, color: AppColors.pink),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay personas cerca',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Intenta ampliar tu radio de búsqueda o vuelve más tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Intentar de nuevo',
              onPressed: _loadUsers,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleUserView(User user) {
    final auth = context.read<AuthProvider>();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Center(
            child: GestureDetector(
              onTap: () => _abrirPerfil(user),
              child: _buildUserCard(user),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              _buildActionButtons(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.coral, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta es la única persona disponible en tu zona. ¡Dale like si te interesa!',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleBtn(
          icon: Icons.close_rounded,
          color: Colors.redAccent,
          size: 60,
          onTap: () => _controller.swipeLeft(),
        ),
        const SizedBox(width: 20),
        _circleBtn(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.coral,
          size: 60,
          onTap: _openChatWithCurrentUser,
          gradient: const LinearGradient(
            colors: [AppColors.coral, AppColors.mauve],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        const SizedBox(width: 20),
        _circleBtn(
          icon: Icons.favorite_rounded,
          color: AppColors.pink,
          size: 70,
          onTap: () => _controller.swipeRight(),
          gradient: AppColors.primaryGradient,
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: gradient == null ? Colors.white : null,
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon,
            color: gradient != null ? Colors.white : color,
            size: size * 0.45),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return GestureDetector(
      onTap: () => _abrirPerfil(user),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto de usuario o fondo por defecto
              _buildUserPhoto(user),
              // Overlay degradado inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.purple.withOpacity(0.95),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre y edad
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.name}, ${user.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: Colors.white70, size: 12),
                                SizedBox(width: 4),
                                Text('Ver perfil',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Localidad
                      if (user.localidad != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.blush, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user.localidad!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.bio!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Intereses
                      if (user.interests.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 5,
                          children: user.interests.take(4).map((i) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pink.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        AppColors.blush.withOpacity(0.5),
                                    width: 1),
                              ),
                              child: Text(
                                i.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      // Música
                      if (user.musicGenres.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.music_note_rounded,
                                color: AppColors.blush, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.musicGenres
                                    .take(3)
                                    .map((g) => g.name)
                                    .join(' · '),
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserPhoto(User user) {
    // Si el usuario tiene fotos, mostrar la primera (principal)
    if (user.photos.isNotEmpty) {
      final primaryPhoto = user.photos.firstWhere(
        (photo) => photo.isPrimary,
        orElse: () => user.photos.first,
      );
      
      final auth = context.read<AuthProvider>();
      return Image.network(
        auth.apiService.getPhotoUrl(primaryPhoto.photoUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blush,
                  AppColors.lavender,
                  AppColors.mauve,
                  AppColors.purple,
                ],
                stops: [0.0, 0.35, 0.68, 1.0],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading user photo: $error');
          return _buildDefaultBackground();
        },
      );
    }
    
    // Si no tiene fotos, mostrar fondo por defecto
    return _buildDefaultBackground();
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blush,
            AppColors.lavender,
            AppColors.mauve,
            AppColors.purple,
          ],
          stops: [0.0, 0.35, 0.68, 1.0],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded,
            size: 130, color: Colors.white24),
      ),
    );
  }
}

// Helper interno para los chips del modal
class _ChipItem {
  final int id;
  final String name;
  const _ChipItem({required this.id, required this.name});
}
