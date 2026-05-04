import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'user_profile_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with TickerProviderStateMixin {
  List<dynamic> _matches = [];
  List<User> _sentLikes = [];
  List<User> _receivedLikes = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      try {
        print('DEBUG: Loading matches for user ${auth.userId}');
        
        // Cargar matches (conexiones mutuas)
        final matches = await auth.apiService.getMatches(auth.userId!);
        print('DEBUG: Got ${matches.length} matches: $matches');
        
        // Cargar likes enviados desde el backend
        final sentLikes = await auth.apiService.getLikesSent(auth.userId!);
        print('DEBUG: Got ${sentLikes.length} sent likes');
        
        // Cargar likes recibidos desde el backend
        final receivedLikes = await auth.apiService.getLikesReceived(auth.userId!);
        print('DEBUG: Got ${receivedLikes.length} received likes');
        
        if (mounted) {
          setState(() {
            _matches = matches;
            _sentLikes = sentLikes;
            _receivedLikes = receivedLikes;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error cargando datos: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conexiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.lavender,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.purple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Matches'),
            Tab(text: 'Mis likes'),
            Tab(text: 'Me dieron like'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pink))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMatchesList(),
                _buildSentLikesList(),
                _buildReceivedLikesList(),
              ],
            ),
    );
  }

  Widget _buildMatchesList() {
    print('DEBUG: Building matches list with ${_matches.length} matches');
    if (_matches.isEmpty) {
      return _buildEmpty(
        icon: Icons.favorite_border_rounded,
        title: 'Aún no tienes matches',
        subtitle: 'Cuando alguien también te dé like, aparecerá aquí para que puedan chatear.',
      );
    }
    return _buildList(_matches, showChatButton: true);
  }

  Widget _buildSentLikesList() {
    if (_sentLikes.isEmpty) {
      return _buildEmpty(
        icon: Icons.send_outlined,
        title: 'No has enviado likes',
        subtitle: 'Los usuarios a los que les des like aparecerán aquí.',
      );
    }
    return _buildUserList(_sentLikes, showLikeIcon: true);
  }

  Widget _buildReceivedLikesList() {
    print('DEBUG: Building received likes list with ${_receivedLikes.length} likes');
    if (_receivedLikes.isEmpty) {
      return _buildEmpty(
        icon: Icons.thumb_up_outlined,
        title: 'Nadie te ha dado like aún',
        subtitle: 'Cuando alguien te dé like, aparecerá aquí.',
      );
    }
    return _buildUserList(_receivedLikes, showLikeIcon: false);
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.salmon.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: AppColors.coral),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<User> users, {required bool showLikeIcon}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = users[index];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(user: user),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.salmon, AppColors.coral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${user.age} años${user.localidad != null ? ' · ${user.localidad}' : ''}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Icono
                Container(
                  margin: const EdgeInsets.all(14),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: showLikeIcon 
                        ? AppColors.pink.withOpacity(0.2)
                        : AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    showLikeIcon ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                    size: 18, 
                    color: showLikeIcon ? AppColors.pink : AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleList(
    List<dynamic> users, {
    required IconData buttonIcon,
    required Color buttonColor,
    required void Function(dynamic)? onButtonTap,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = users[index];
        final name = user['name']?.toString() ?? 'Usuaria';
        final age = user['age'] ?? '';
        final localidad = user['localidad']?.toString() ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.salmon, AppColors.coral],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$age años${localidad.isNotEmpty ? ' · $localidad' : ''}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Botón de acción
              GestureDetector(
                onTap: onButtonTap != null ? () => onButtonTap(user) : null,
                child: Container(
                  margin: const EdgeInsets.all(14),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(buttonIcon, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildList(List<dynamic> matches, {bool showChatButton = false}) {
    print('DEBUG: _buildList called with ${matches.length} matches, showChatButton: $showChatButton');
    final auth = context.read<AuthProvider>();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final match = matches[index];
        print('DEBUG: Processing match $index: $match');
        final otherUser = match['user1']['id'] == auth.userId
            ? match['user2']
            : match['user1'];
        final name     = otherUser['name']?.toString() ?? 'Usuaria';
        final age      = otherUser['age'] ?? '';
        final localidad = otherUser['localidad']?.toString() ?? '';
        final matchId  = match['id'] as int;

        // Construir objeto User para la pantalla de perfil
        final userObj = User(
          id: (otherUser['id'] as num?)?.toInt() ?? 0,
          email: otherUser['email']?.toString() ?? '',
          name: name,
          age: (otherUser['age'] as num?)?.toInt() ?? 0,
          bio: otherUser['bio']?.toString(),
          genero: otherUser['genero']?.toString(),
          localidad: localidad.isNotEmpty ? localidad : null,
          interests: (otherUser['interests'] as List<dynamic>? ?? [])
              .map((e) => Interest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          musicGenres: (otherUser['musicGenres'] as List<dynamic>? ?? [])
              .map((e) => MusicGenre.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar — toca para ver perfil
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      user: userObj,
                      matchId: matchId,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.salmon, AppColors.coral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
              // Info — toca para ver perfil
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        user: userObj,
                        matchId: matchId,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$age años${localidad.isNotEmpty ? ' · $localidad' : ''}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón chat (solo si showChatButton es true)
              if (showChatButton)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        matchId: matchId,
                        otherUserName: name,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.coral, AppColors.mauve],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
