import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _paso = 0;
  bool _isLoading = false;
  bool _cargandoCatalogos = true;

  // Estados de expansión por categoría
  Map<String, bool> _interesesExpandidos = {};
  Map<String, bool> _musicaExpandida = {};

  // Paso 1 – Datos básicos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  bool _verPassword = false;
  String? _generoSeleccionado;

  // Paso 2 – Ubicación en Bogotá
  String? _localidadSeleccionada;
  final _direccionController = TextEditingController();

  // Paso 3 – Pasatiempos
  List<Interest> _todosIntereses = [];
  Set<int> _interesesSeleccionados = {};

  // Paso 4 – Música
  List<MusicGenre> _todosGeneros = [];
  Set<int> _generosSeleccionados = {};

  static const List<String> _generos = [
    'Mujer',
    'Mujer trans',
    'No binario',
    'Género fluido',
    'Agénero',
    'Otros géneros',
    'Prefiero no decir',
  ];

  static const List<String> _localidades = [
    'Usaquén', 'Chapinero', 'Santa Fe', 'San Cristóbal', 'Usme',
    'Tunjuelito', 'Bosa', 'Kennedy', 'Fontibón', 'Engativá',
    'Suba', 'Barrios Unidos', 'Teusaquillo', 'Los Mártires',
    'Antonio Nariño', 'Puente Aranda', 'La Candelaria',
    'Rafael Uribe Uribe', 'Ciudad Bolívar', 'Sumapaz',
  ];

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    // TEMPORAL: Datos hardcodeados hasta que el backend se actualice
    final interesesTemp = <Interest>[
      Interest(id: 1, name: 'Pintura', categoria: 'Arte y Creatividad'),
      Interest(id: 2, name: 'Dibujo', categoria: 'Arte y Creatividad'),
      Interest(id: 3, name: 'Fotografía', categoria: 'Arte y Creatividad'),
      Interest(id: 8, name: 'Ver películas', categoria: 'Entretenimiento'),
      Interest(id: 9, name: 'Series y TV', categoria: 'Entretenimiento'),
      Interest(id: 10, name: 'Videojuegos', categoria: 'Entretenimiento'),
      Interest(id: 14, name: 'Yoga', categoria: 'Deporte y Bienestar'),
      Interest(id: 15, name: 'Gimnasio', categoria: 'Deporte y Bienestar'),
      Interest(id: 16, name: 'Ciclismo', categoria: 'Deporte y Bienestar'),
      Interest(id: 23, name: 'Lectura', categoria: 'Cultura y Conocimiento'),
      Interest(id: 24, name: 'Idiomas', categoria: 'Cultura y Conocimiento'),
      Interest(id: 29, name: 'Cocinar', categoria: 'Gastronomía'),
      Interest(id: 30, name: 'Repostería', categoria: 'Gastronomía'),
      Interest(id: 33, name: 'Viajes', categoria: 'Viajes y Naturaleza'),
      Interest(id: 37, name: 'Tocar guitarra', categoria: 'Música'),
      Interest(id: 38, name: 'Canto', categoria: 'Música'),
      Interest(id: 42, name: 'Programación', categoria: 'Tecnología'),
    ];
    
    final generosTemp = <MusicGenre>[
      MusicGenre(id: 1, name: 'Pop latino', categoria: 'Pop'),
      MusicGenre(id: 2, name: 'Pop en inglés', categoria: 'Pop'),
      MusicGenre(id: 3, name: 'K-Pop', categoria: 'Pop'),
      MusicGenre(id: 5, name: 'Reggaetón', categoria: 'Urbano'),
      MusicGenre(id: 6, name: 'Trap', categoria: 'Urbano'),
      MusicGenre(id: 10, name: 'Rock clásico', categoria: 'Rock'),
      MusicGenre(id: 11, name: 'Rock alternativo', categoria: 'Rock'),
      MusicGenre(id: 14, name: 'Indie rock', categoria: 'Rock'),
      MusicGenre(id: 15, name: 'House', categoria: 'Electrónica'),
      MusicGenre(id: 16, name: 'Techno', categoria: 'Electrónica'),
      MusicGenre(id: 17, name: 'EDM', categoria: 'Electrónica'),
      MusicGenre(id: 20, name: 'Música clásica', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 21, name: 'Jazz', categoria: 'Clásica y Jazz'),
      MusicGenre(id: 24, name: 'Vallenato', categoria: 'Colombiana'),
      MusicGenre(id: 25, name: 'Cumbia', categoria: 'Colombiana'),
      MusicGenre(id: 26, name: 'Salsa', categoria: 'Colombiana'),
      MusicGenre(id: 29, name: 'Hip-hop', categoria: 'Hip-Hop'),
      MusicGenre(id: 30, name: 'R&B', categoria: 'Hip-Hop'),
    ];
    
    setState(() {
      _todosIntereses = interesesTemp;
      _todosGeneros = generosTemp;
      _cargandoCatalogos = false;
    });
  }

  bool _validarPaso() {
    switch (_paso) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          _snack('Ingresa tu nombre');
          return false;
        }
        if (_emailController.text.trim().isEmpty ||
            !_emailController.text.contains('@')) {
          _snack('Ingresa un correo válido');
          return false;
        }
        if (_passwordController.text.length < 6) {
          _snack('La contraseña debe tener al menos 6 caracteres');
          return false;
        }
        if (_ageController.text.isEmpty ||
            int.tryParse(_ageController.text) == null) {
          _snack('Ingresa una edad válida');
          return false;
        }
        if (_generoSeleccionado == null) {
          _snack('Selecciona tu género');
          return false;
        }
        return true;
      case 1:
        if (_localidadSeleccionada == null) {
          _snack('Selecciona tu localidad en Bogotá');
          return false;
        }
        return true;
      case 2:
        if (_interesesSeleccionados.isEmpty) {
          _snack('Selecciona al menos un pasatiempo');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _registrar() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        bio: _bioController.text.trim(),
        genero: _generoSeleccionado!,
        localidad: _localidadSeleccionada!,
        direccion: _direccionController.text.trim(),
        interestIds: _interesesSeleccionados.toList(),
        musicGenreIds: _generosSeleccionados.toList(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Error al registrarse. El correo puede estar en uso.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppColors.lavender,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_paso > 0) {
              setState(() => _paso--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _cargandoCatalogos
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildIndicadorPasos(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildPasoActual(),
                  ),
                ),
                _buildBotonesNavegacion(),
              ],
            ),
    );
  }

  Widget _buildIndicadorPasos() {
    final pasos = ['Datos', 'Ubicación', 'Pasatiempos', 'Música'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Row(
        children: List.generate(pasos.length, (i) {
          final activo    = i == _paso;
          final completado = i < _paso;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: completado
                              ? AppColors.teal
                              : activo
                                  ? AppColors.coral
                                  : const Color(0xFFEEE5E0),
                          shape: BoxShape.circle,
                          boxShadow: activo
                              ? [
                                  BoxShadow(
                                    color: AppColors.coral.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: completado
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: activo
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pasos[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: activo
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: activo
                              ? AppColors.coral
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < pasos.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      decoration: BoxDecoration(
                        color: i < _paso
                            ? AppColors.teal
                            : const Color(0xFFEEE5E0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPasoActual() {
    switch (_paso) {
      case 0:
        return _buildPaso1();
      case 1:
        return _buildPaso2();
      case 2:
        return _buildPaso3();
      case 3:
        return _buildPaso4();
      default:
        return const SizedBox();
    }
  }

  // ── Paso 1: Datos básicos ─────────────────────────────────────────────────
  Widget _buildPaso1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Cuéntanos sobre ti', Icons.person_outline),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: !_verPassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                  _verPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => _verPassword = !_verPassword),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad',
            prefixIcon: Icon(Icons.cake_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _generoSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Género',
            prefixIcon: Icon(Icons.wc_outlined),
            border: OutlineInputBorder(),
          ),
          items: _generos
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _generoSeleccionado = v),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _bioController,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            labelText: 'Biografía (opcional)',
            hintText: 'Cuéntales a otras personas quién eres...',
            prefixIcon: Icon(Icons.edit_note),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // ── Paso 2: Ubicación ─────────────────────────────────────────────────────
  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('¿Dónde estás en Bogotá?', Icons.location_city_outlined),
        const SizedBox(height: 8),
        Text(
          'Esto nos ayuda a conectarte con personas en tu misma localidad.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _localidadSeleccionada,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Localidad',
            prefixIcon: Icon(Icons.map_outlined),
            border: OutlineInputBorder(),
          ),
          items: _localidades
              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
              .toList(),
          onChanged: (v) => setState(() => _localidadSeleccionada = v),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _direccionController,
          decoration: const InputDecoration(
            labelText: 'Barrio o dirección (opcional)',
            hintText: 'Ej: Chapinero Alto, Calle 67',
            prefixIcon: Icon(Icons.home_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.purple),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Por ahora solo operamos en Bogotá. Pronto llegaremos a más ciudades.',
                  style: TextStyle(color: AppColors.purple, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Paso 3: Pasatiempos ───────────────────────────────────────────────────
  Widget _buildPaso3() {
    final Map<String, List<Interest>> porCategoria = {};
    for (final i in _todosIntereses) {
      porCategoria.putIfAbsent(i.categoria, () => []).add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('¿Qué te gusta hacer?', Icons.star_outline),
        const SizedBox(height: 4),
        Text(
          'Selecciona tus pasatiempos. Usaremos esto para recomendarte personas afines.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          '${_interesesSeleccionados.length} seleccionados',
          style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...porCategoria.entries.map((entry) {
          final isExpanded = _interesesExpandidos[entry.key] ?? false;
          final itemsToShow = isExpanded ? entry.value : entry.value.take(4).toList();
          final hasMore = entry.value.length > 4;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: hasMore ? () => setState(() {
                  _interesesExpandidos[entry.key] = !isExpanded;
                }) : null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Row(
                    children: [
                      Container(width: 3, height: 16,
                        decoration: BoxDecoration(color: AppColors.coral,
                            borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 13, color: AppColors.coral)),
                      if (hasMore) ...[
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.coral,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 7, runSpacing: 6,
                children: itemsToShow.map((item) {
                  final sel = _interesesSeleccionados.contains(item.id);
                  return FilterChip(
                    label: Text(item.name),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      sel ? _interesesSeleccionados.remove(item.id)
                          : _interesesSeleccionados.add(item.id);
                    }),
                    selectedColor: AppColors.blush,
                    backgroundColor: const Color(0xFFFCE8F3),
                    checkmarkColor: AppColors.pink,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: sel ? AppColors.pink : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              if (hasMore && !isExpanded) ...[
                const SizedBox(height: 4),
                Text(
                  '+${entry.value.length - 4} más',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mauve,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  // ── Paso 4: Música ────────────────────────────────────────────────────────
  Widget _buildPaso4() {
    final Map<String, List<MusicGenre>> porCategoria = {};
    for (final g in _todosGeneros) {
      porCategoria.putIfAbsent(g.categoria, () => []).add(g);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('¿Qué música escuchas?', Icons.music_note_outlined),
        const SizedBox(height: 4),
        Text(
          'Selecciona tus géneros favoritos (opcional).',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          '${_generosSeleccionados.length} seleccionados',
          style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...porCategoria.entries.map((entry) {
          final isExpanded = _musicaExpandida[entry.key] ?? false;
          final itemsToShow = isExpanded ? entry.value : entry.value.take(4).toList();
          final hasMore = entry.value.length > 4;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: hasMore ? () => setState(() {
                  _musicaExpandida[entry.key] = !isExpanded;
                }) : null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Row(
                    children: [
                      Container(width: 3, height: 16,
                        decoration: BoxDecoration(color: AppColors.purple,
                            borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 13, color: AppColors.purple)),
                      if (hasMore) ...[
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.purple,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 7, runSpacing: 6,
                children: itemsToShow.map((item) {
                  final sel = _generosSeleccionados.contains(item.id);
                  return FilterChip(
                    label: Text(item.name),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      sel ? _generosSeleccionados.remove(item.id)
                          : _generosSeleccionados.add(item.id);
                    }),
                    selectedColor: const Color(0xFFF0E6FA),
                    backgroundColor: const Color(0xFFF5EEFF),
                    checkmarkColor: AppColors.purple,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: sel ? AppColors.purple : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              if (hasMore && !isExpanded) ...[
                const SizedBox(height: 4),
                Text(
                  '+${entry.value.length - 4} más',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mauve,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBotonesNavegacion() {
    final esUltimoPaso = _paso == 3;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.slateBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GradientButton(
        label: esUltimoPaso ? 'Crear mi cuenta' : 'Continuar',
        onPressed: () {
          if (!_validarPaso()) return;
          if (esUltimoPaso) {
            _registrar();
          } else {
            setState(() => _paso++);
          }
        },
        isLoading: _isLoading,
        icon: esUltimoPaso
            ? Icons.check_circle_outline_rounded
            : Icons.arrow_forward_rounded,
      ),
    );
  }

  Widget _titulo(String texto, IconData icono) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.salmon.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: AppColors.coral, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          texto,
          style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
