import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';
import '../widgets/delete_confirmation_dialog.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardsScreen({super.key, required this.folderId, required this.folderName});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();
  List<CardModel> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cards = await _cardRepo.getCardsByFolderId(widget.folderId);
      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteCard(CardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete card?',
        message: 'Delete "${card.cardName} of ${card.suit}"? This cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );
    if (confirmed != true) return;
    if (card.id == null) return;
    try {
      await _cardRepo.deleteCard(card.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card deleted')));
        _loadCards();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openAddCard() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AddEditCardScreen(
          folderId: widget.folderId,
          folderName: widget.folderName,
        ),
      ),
    );
    if (result == true) _loadCards();
  }

  Future<void> _openEditCard(CardModel card) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AddEditCardScreen(
          folderId: widget.folderId,
          folderName: widget.folderName,
          existingCard: card,
        ),
      ),
    );
    if (result == true) _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folderName} (${_cards.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _loadCards, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _cards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No cards in this folder.'),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _openAddCard,
                            icon: const Icon(Icons.add),
                            label: const Text('Add card'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: _buildCardImage(card.imageUrl),
                            title: Text('${card.cardName} of ${card.suit}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openEditCard(card),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteCard(card),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            onTap: () => _openEditCard(card),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCard,
        tooltip: 'Add card',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.credit_card, size: 32),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 80,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 56,
            height: 80,
            color: Colors.grey.shade200,
            child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        },
      ),
    );
  }
}
