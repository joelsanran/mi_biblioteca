
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

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

  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _coverUrlCtrl;
  String _status = 'pendiente';
  bool _saving = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _yearCtrl = TextEditingController(text: b?.year?.toString() ?? '');
    _coverUrlCtrl = TextEditingController(text: b?.coverUrl ?? '');
    _status = b?.status ?? 'pendiente';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _yearCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final book = Book(
      id: widget.book?.id ?? '',
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text.trim()),
      coverUrl: _coverUrlCtrl.text.trim(),
      status: _status,
      ownerId: widget.userId,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateBook(book);
      } else {
        await _firestoreService.addBook(book);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar libro' : 'Agregar libro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                labelText: 'Año de publicación',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _coverUrlCtrl,
              decoration: const InputDecoration(labelText: 'URL de portada'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Estado de lectura',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _statusChip('pendiente', 'Pendiente', AppColors.pending),
                _statusChip('leyendo', 'Leyendo', AppColors.warning),
                _statusChip('leido', 'Leído', AppColors.success),
              ],
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      _isEditing ? 'Guardar cambios' : 'Agregar libro',
                    ),
                  ),
          ],
        ),
      ),
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
