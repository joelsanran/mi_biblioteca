import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/book.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/book_cover.dart';
import 'package:flutter/services.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, required this.userId, this.book});

  final String userId;
  final Book? book; // null = agregar, con valor = editar

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _coverUrlCtrl;
  late final TextEditingController _pageCtrl;
  late final TextEditingController _reviewCtrl;

  String _status = 'pendiente';
  String _coverBase64 = '';
  int _rating = 0;
  bool _saving = false;

  bool get _isEditing => widget.book != null;
  bool get _hasCover =>
      _coverBase64.isNotEmpty || _coverUrlCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _yearCtrl = TextEditingController(text: b?.year?.toString() ?? '');
    _coverUrlCtrl = TextEditingController(text: b?.coverUrl ?? '');
    _pageCtrl = TextEditingController(text: b?.currentPage?.toString() ?? '');
    _reviewCtrl = TextEditingController(text: b?.review ?? '');
    _status = b?.status ?? 'pendiente';
    _coverBase64 = b?.coverBase64 ?? '';
    _rating = b?.rating ?? 0;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _yearCtrl.dispose();
    _coverUrlCtrl.dispose();
    _pageCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickCover() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 900,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final encoded = base64Encode(bytes);

      if (encoded.length > 700000) {
        _showMessage('La imagen es demasiado grande, elige otra');
        return;
      }

      setState(() {
        _coverBase64 = encoded;
        _coverUrlCtrl.clear();
      });
    } catch (e) {
      _showMessage('No se pudo cargar la imagen: $e');
    }
  }

  void _removeCover() {
    setState(() {
      _coverBase64 = '';
      _coverUrlCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final isRead = _status == 'leido';
    final isReading = _status == 'leyendo';

    final book = Book(
      id: widget.book?.id ?? '',
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()),
      coverUrl: _coverUrlCtrl.text.trim(),
      coverBase64: _coverBase64,
      status: _status,
      ownerId: widget.userId,
      rating: isRead && _rating > 0 ? _rating : null,
      review: isRead ? _reviewCtrl.text.trim() : '',
      currentPage: isReading ? int.tryParse(_pageCtrl.text.trim()) : null,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateBook(book);
      } else {
        await _firestoreService.addBook(book);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMessage('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar libro' : 'Agregar libro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                BookCover(
                  coverBase64: _coverBase64,
                  coverUrl: _coverUrlCtrl.text.trim(),
                  width: 90,
                  height: 126,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickCover,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Elegir de la galería'),
                      ),
                      if (_hasCover)
                        TextButton.icon(
                          onPressed: _removeCover,
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          label: const Text('Quitar portada',
                              style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El título es obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorCtrl,
              decoration: const InputDecoration(labelText: 'Autor'),
              validator: Validators.author,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearCtrl,
              decoration: const InputDecoration(
                labelText: 'Año de publicación (4 dígitos)',
                hintText: 'Ej. 1999',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: Validators.year,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _coverUrlCtrl,
              decoration: const InputDecoration(
                  labelText: 'O pega una URL de portada (opcional)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            const Text('Estado de lectura',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _statusChip('pendiente', 'Pendiente', AppColors.pending),
                _statusChip('leyendo', 'Leyendo', AppColors.warning),
                _statusChip('leido', 'Leído', AppColors.success),
              ],
            ),

            // Solo si está leyendo: página donde se quedó
            if (_status == 'leyendo') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _pageCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Página en la que te quedaste',
                  prefixIcon: Icon(Icons.bookmark_outline),
                ),
                validator: Validators.page,
              ),
            ],

            // Solo si está leído: calificación y opinión
            if (_status == 'leido') ...[
              const SizedBox(height: 20),
              const Text('Tu calificación',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              _ratingStars(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Tu opinión (opcional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],

            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    child:
                        Text(_isEditing ? 'Guardar cambios' : 'Agregar libro'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _ratingStars() {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < _rating;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: AppColors.secondary,
            size: 32,
          ),
          // Tocar la estrella ya seleccionada quita la calificación
          onPressed: () =>
              setState(() => _rating = (_rating == i + 1) ? 0 : i + 1),
        );
      }),
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final selected = _status == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _status = value),
      selectedColor: color.withValues(alpha: 0.85),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}