import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';
import '../repositories/folder_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int folderId;
  final String folderName;
  final CardModel? existingCard;

  const AddEditCardScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    this.existingCard,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepo = CardRepository();
  final FolderRepository _folderRepo = FolderRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  String _suit = '';
  int? _selectedFolderId;
  List<Folder> _folders = [];
  bool _saving = false;

  bool get _isEditing => widget.existingCard != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingCard?.cardName ?? '');
    _imageUrlController = TextEditingController(text: widget.existingCard?.imageUrl ?? '');
    _suit = widget.existingCard?.suit ?? widget.folderName;
    _selectedFolderId = widget.existingCard?.folderId ?? widget.folderId;
    _loadFolders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.getAllFolders();
    setState(() => _folders = folders);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final folderId = _selectedFolderId ?? widget.folderId;
      if (_isEditing && widget.existingCard != null) {
        await _cardRepo.updateCard(
          widget.existingCard!.copyWith(
            cardName: _nameController.text.trim(),
            suit: _suit,
            imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
            folderId: folderId,
          ),
        );
      } else {
        await _cardRepo.insertCard(
          CardModel(
            cardName: _nameController.text.trim(),
            suit: _suit,
            imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
            folderId: folderId,
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Card updated' : 'Card added')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static const _suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit card' : 'Add card'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card name',
                hintText: 'e.g. Ace, King, 2',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a card name';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _suits.contains(_suit) ? _suit : _suits.first,
              decoration: const InputDecoration(
                labelText: 'Suit',
                border: OutlineInputBorder(),
              ),
              items: _suits.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _suit = v ?? _suits.first),
            ),
            const SizedBox(height: 16),
            if (_folders.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: _selectedFolderId,
                decoration: const InputDecoration(
                  labelText: 'Folder',
                  border: OutlineInputBorder(),
                ),
                items: _folders
                    .where((f) => f.id != null)
                    .map((f) => DropdownMenuItem(value: f.id, child: Text(f.folderName)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedFolderId = v),
              ),
            if (_folders.isNotEmpty) const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://deckofcardsapi.com/static/img/AS.png',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isEditing ? 'Update' : 'Save'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
