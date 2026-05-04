import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_photo.dart';
import '../theme/app_theme.dart';

class PhotoManagerScreen extends StatefulWidget {
  const PhotoManagerScreen({super.key});

  @override
  State<PhotoManagerScreen> createState() => _PhotoManagerScreenState();
}

class _PhotoManagerScreenState extends State<PhotoManagerScreen> {
  List<UserPhoto> _photos = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId != null) {
      try {
        final photos = await auth.apiService.getUserPhotos(auth.userId!);
        if (mounted) {
          setState(() {
            _photos = photos;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading photos: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_photos.length >= 3) {
      _showMessage('Ya tienes el máximo de 3 fotos');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final auth = context.read<AuthProvider>();
        final nextOrder = _photos.length + 1;
        
        setState(() => _isLoading = true);
        
        final uploadedPhoto = await auth.apiService.uploadPhoto(
          auth.userId!,
          image,
          nextOrder,
        );

        if (uploadedPhoto != null) {
          await _loadPhotos();
          _showMessage('Foto subida exitosamente');
        } else {
          _showMessage('Error al subir la foto');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error picking/uploading photo: $e');
      if (kIsWeb && e.toString().contains('MultipartFile')) {
        _showMessage('Funcionalidad de fotos disponible en app móvil');
      } else {
        _showMessage('Error al seleccionar la foto: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePhoto(UserPhoto photo) async {
    if (_photos.length <= 2) {
      _showMessage('Debes tener al menos 2 fotos');
      return;
    }

    final confirmed = await _showConfirmDialog(
      'Eliminar foto',
      '¿Estás segura de que quieres eliminar esta foto?',
    );

    if (confirmed == true) {
      final auth = context.read<AuthProvider>();
      setState(() => _isLoading = true);
      
      final success = await auth.apiService.deletePhoto(
        auth.userId!,
        photo.photoOrder,
      );

      if (success) {
        await _loadPhotos();
        _showMessage('Foto eliminada');
      } else {
        _showMessage('Error al eliminar la foto');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Fotos'),
        actions: [
          if (_photos.length < 3)
            IconButton(
              icon: const Icon(Icons.add_a_photo_rounded),
              onPressed: _pickAndUploadPhoto,
              tooltip: 'Agregar foto',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coral))
          : _buildPhotoGrid(),
    );
  }

  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kIsWeb ? AppColors.coral.withOpacity(0.1) : AppColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestiona tus fotos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Mínimo 2 fotos requeridas\n• Máximo 3 fotos permitidas\n• La primera foto es tu foto principal\n• Formatos soportados: JPG, PNG\n• Tamaño máximo: 5MB por foto',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid de fotos
          Text(
            'Fotos (${_photos.length}/3)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                if (index < _photos.length) {
                  return _buildPhotoCard(_photos[index]);
                } else {
                  return _buildAddPhotoCard();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(UserPhoto photo) {
    final auth = context.read<AuthProvider>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            Image.network(
              auth.apiService.getPhotoUrl(photo.photoUrl),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.blush,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.coral,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Container(
                  color: AppColors.blush,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 50,
                        color: AppColors.coral,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar\nfoto #${photo.photoOrder}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Overlay con información
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: photo.isPrimary ? AppColors.coral : AppColors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  photo.isPrimary ? 'Principal' : '#${photo.photoOrder}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Botón eliminar
            if (_photos.length > 2)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _deletePhoto(photo),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    final canAdd = _photos.length < 3;
    return GestureDetector(
      onTap: canAdd ? _pickAndUploadPhoto : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.coral.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 40,
              color: canAdd ? AppColors.coral : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              canAdd 
                ? 'Agregar foto' 
                : 'Máximo alcanzado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: canAdd ? AppColors.coral : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}