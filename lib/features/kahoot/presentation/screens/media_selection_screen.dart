import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/media/application/providers/media_provider.dart';
import 'package:green_frontend/features/media/domain/entities/media.dart';

class MediaSelectionScreen extends StatefulWidget {
  final String? currentMediaId;
  final Function(String?)? onMediaSelected;

  const MediaSelectionScreen({
    Key? key,
    this.currentMediaId,
    this.onMediaSelected,
  }) : super(key: key);

  @override
  _MediaSelectionScreenState createState() => _MediaSelectionScreenState();
}

class _MediaSelectionScreenState extends State<MediaSelectionScreen> {
  final List<String> _allowedTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mp3'];
  final Map<String, IconData> _typeIcons = {
    'image': Icons.image,
    'video': Icons.videocam,
    'audio': Icons.audiotrack,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      // Podríamos cargar la lista de media del usuario aquí si es necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Multimedia'),
        actions: [
          if (widget.currentMediaId != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, widget.currentMediaId!);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Opciones de carga
          _buildUploadOptions(mediaProvider),
          
          // Media del usuario
          Expanded(
            child: _buildUserMedia(mediaProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions(MediaProvider mediaProvider) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subir nuevo archivo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  color: Colors.purple,
                  onTap: () => _pickFromGallery(mediaProvider),
                ),
                _buildUploadOption(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  color: Colors.blue,
                  onTap: () => _pickFromCamera(mediaProvider),
                ),
                _buildUploadOption(
                  icon: Icons.attach_file,
                  label: 'Archivo',
                  color: Colors.green,
                  onTap: () => _pickFile(mediaProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildUserMedia(MediaProvider mediaProvider) {
    if (mediaProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (mediaProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              mediaProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => mediaProvider.clearError(),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final userMedia = mediaProvider.userMedia;

    if (userMedia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay archivos multimedia',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Sube archivos usando las opciones de arriba',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: userMedia.length,
      itemBuilder: (context, index) {
        final media = userMedia[index];
        return _buildMediaItem(media);
      },
    );
  }

  Widget _buildMediaItem(MediaAsset media) {
    final isSelected = widget.currentMediaId == media.id;

    return GestureDetector(
      onTap: () {
        if (widget.onMediaSelected != null) {
          widget.onMediaSelected!(media.id);
        }
        Navigator.pop(context, media.id);
      },
      onLongPress: () => _showMediaDetails(context, media),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // Vista previa
            _buildMediaPreview(media),
            
            // Indicador de tipo
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _typeIcons[media.category] ?? Icons.insert_drive_file,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Indicador de local
            if (media.isLocal)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.storage,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            
            // Nombre del archivo
            if (media.isImage)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    media.originalName.length > 15
                        ? '${media.originalName.substring(0, 15)}...'
                        : media.originalName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(MediaAsset media) {
    if (media.isImage && media.localPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(media.localPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      );
    } else if (media.thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          media.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(media);
          },
        ),
      );
    } else {
      return _buildPlaceholder(media);
    }
  }

  Widget _buildPlaceholder(MediaAsset media) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _typeIcons[media.category] ?? Icons.insert_drive_file,
              size: 32,
              color: Colors.grey[600],
            ),
            SizedBox(height: 4),
            Text(
              media.format.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(MediaProvider mediaProvider) async {
    try {
      final media = await mediaProvider.pickImageFromGallery();
      if (media != null) {
        _onMediaUploaded(media);
      }
    } catch (e) {
      _showErrorSnackbar('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _pickFromCamera(MediaProvider mediaProvider) async {
    try {
      final media = await mediaProvider.pickImageFromCamera();
      if (media != null) {
        _onMediaUploaded(media);
      }
    } catch (e) {
      _showErrorSnackbar('Error al tomar foto: $e');
    }
  }

  Future<void> _pickFile(MediaProvider mediaProvider) async {
    // Implementar selección de archivo genérico
    // Necesitarías un paquete como file_picker
    _showErrorSnackbar('Selección de archivos no implementada');
  }

  void _onMediaUploaded(MediaAsset media) {
    if (widget.onMediaSelected != null) {
      widget.onMediaSelected!(media.id);
    }
    Navigator.pop(context, media.id);
  }

  void _showMediaDetails(BuildContext context, MediaAsset media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del archivo'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.description),
                title: Text('Nombre'),
                subtitle: Text(media.originalName),
              ),
              ListTile(
                leading: Icon(Icons.format_size),
                title: Text('Tamaño'),
                subtitle: Text('${(media.size / 1024).toStringAsFixed(2)} KB'),
              ),
              ListTile(
                leading: Icon(Icons.format_align_left),
                title: Text('Tipo'),
                subtitle: Text('${media.mimeType} (${media.format})'),
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text('Categoría'),
                subtitle: Text(media.category),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Subido el'),
                subtitle: Text(media.createdAt.toString()),
              ),
              ListTile(
                leading: Icon(Icons.storage),
                title: Text('Almacenamiento'),
                subtitle: Text(media.isLocal ? 'Local y remoto' : 'Solo remoto'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          if (media.isLocal)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _shareMedia(media);
              },
              child: Text('Compartir'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteDialog(context, media.id);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String mediaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar archivo'),
        content: Text('¿Estás seguro de que quieres eliminar este archivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMedia(mediaId);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedia(String mediaId) async {
    try {
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      await mediaProvider.deleteMedia(mediaId);
      
      if (widget.currentMediaId == mediaId && widget.onMediaSelected != null) {
        widget.onMediaSelected!(null);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo eliminado correctamente')),
      );
    } catch (e) {
      _showErrorSnackbar('Error al eliminar archivo: $e');
    }
  }

  Future<void> _shareMedia(MediaAsset media) async {
    try {
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      final signedUrl = await mediaProvider.getSignedUrl(
        media.id,
        expiry: Duration(hours: 24),
      );
      
      // Implementar compartir usando share_plus o similar
      _showSuccessSnackbar('URL generada: ${signedUrl.substring(0, 50)}...');
    } catch (e) {
      _showErrorSnackbar('Error al generar URL: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}