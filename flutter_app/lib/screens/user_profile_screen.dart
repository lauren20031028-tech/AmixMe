import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

/// Pantalla de perfil de otra usuaria (solo lectura)
class UserProfileScreen extends StatefulWidget {
  final User user;
  /// Si ya hay match, se puede pasar el matchId para ir al chat
  final int? matchId;
  final VoidCallback? onLike;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.matchId,
    this.onLike,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _interesesExpanded = false;
  bool _musicaExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(),
                const SizedBox(height: 16),
                if (widget.user.interests.isNotEmpty) _buildInteresesCard(),
                if (widget.user.interests.isNotEmpty) const SizedBox(height: 16),
                if (widget.user.musicGenres.isNotEmpty) _buildMusicaCard(),
                if (widget.user.musicGenres.isNotEmpty) const SizedBox(height: 16),
                _buildBotones(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.pink,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
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
              const SizedBox(height: 60),
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white60, width: 3),
                ),
                child: Center(
                  child: Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.user.name}, ${widget.user.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.user.localidad != null && widget.user.localidad!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.user.localidad!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
              if (widget.user.genero != null && widget.user.genero!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.user.genero!,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Sobre mí',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (widget.user.bio != null && widget.user.bio!.isNotEmpty)
            Text(
              widget.user.bio!,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            )
          else
            Text(
              '${widget.user.name} no ha escrito una biografía todavía.',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildInteresesCard() {
    // Agrupar por categoría
    final Map<String, List<Interest>> grupos = {};
    for (final i in widget.user.interests) {
      grupos.putIfAbsent(i.categoria, () => []).add(i);
    }

    // Mostrar solo los primeros 4 intereses si está colapsado
    final int visibleCount = _interesesExpanded ? widget.user.interests.length : 4;
    final bool hasMore = widget.user.interests.length > 4;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botón expandir/colapsar
          InkWell(
            onTap: hasMore ? () => setState(() => _interesesExpanded = !_interesesExpanded) : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_outline_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pasatiempos (${widget.user.interests.length})',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
                if (hasMore) ...[
                  Icon(
                    _interesesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.pink,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_interesesExpanded) ...[
            ...grupos.entries.map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (grupos.length > 1) ...[
                      Text(
                        e.key,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pink,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: e.value.map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.blush,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pink,
                                  fontWeight: FontWeight.w600),
                            ),
                          )).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                )),
          ] else ...[
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: widget.user.interests.take(4).map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.pink,
                          fontWeight: FontWeight.w600),
                    ),
                  )).toList(),
            ),
            if (hasMore) ...[
              const SizedBox(height: 8),
              Text(
                '+${widget.user.interests.length - 4} más',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mauve,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMusicaCard() {
    final Map<String, List<MusicGenre>> grupos = {};
    for (final g in widget.user.musicGenres) {
      grupos.putIfAbsent(g.categoria, () => []).add(g);
    }

    // Mostrar solo los primeros 4 géneros si está colapsado
    final bool hasMore = widget.user.musicGenres.length > 4;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botón expandir/colapsar
          InkWell(
            onTap: hasMore ? () => setState(() => _musicaExpanded = !_musicaExpanded) : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mauve, AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note_outlined,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Música (${widget.user.musicGenres.length})',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
                if (hasMore) ...[
                  Icon(
                    _musicaExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.purple,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_musicaExpanded) ...[
            ...grupos.entries.map((e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (grupos.length > 1) ...[
                      Text(
                        e.key,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: e.value.map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E6FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.w600),
                            ),
                          )).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                )),
          ] else ...[
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: widget.user.musicGenres.take(4).map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.purple,
                          fontWeight: FontWeight.w600),
                    ),
                  )).toList(),
            ),
            if (hasMore) ...[
              const SizedBox(height: 8),
              Text(
                '+${widget.user.musicGenres.length - 4} más',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mauve,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBotones(BuildContext context) {
    return Row(
      children: [
        // Botón pasar (X)
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded,
                  color: Colors.redAccent, size: 18),
              label: const Text('Pasar',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón like / chat
        Expanded(
          flex: 2,
          child: widget.matchId != null
              ? GradientButton(
                  label: 'Chatear 💬',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icons.chat_bubble_outline_rounded,
                )
              : GradientButton(
                  label: 'Me interesa 💜',
                  onPressed: () {
                    widget.onLike?.call();
                    Navigator.pop(context);
                  },
                  icon: Icons.favorite_rounded,
                ),
        ),
      ],
    );
  }
}
