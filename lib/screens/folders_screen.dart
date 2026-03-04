import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import 'cards_screen.dart';
import '../widgets/delete_confirmation_dialog.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};
  bool _loading = true;
  String? _error;

  static IconData _suitIcon(String name) {
    switch (name) {
      case 'Hearts':
        return Icons.favorite;
      case 'Spades':
        return Icons.grain;
      case 'Diamonds':
        return Icons.workspace_premium;
      case 'Clubs':
        return Icons.eco;
      default:
        return Icons.folder;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final folders = await _folderRepo.getAllFolders();
      final counts = <int, int>{};
      for (final f in folders) {
        if (f.id != null) counts[f.id!] = await _folderRepo.getCardCountForFolder(f.id!);
      }
      setState(() {
        _folders = folders;
        _cardCounts = counts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete folder "${folder.folderName}"?',
        message: 'This will permanently delete this folder and all ${_cardCounts[folder.id] ?? 0} cards inside it. This cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );
    if (confirmed != true) return;
    if (folder.id == null) return;
    try {
      await _folderRepo.deleteFolder(folder.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${folder.folderName}" and its cards')),
        );
        _loadFolders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
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
                        FilledButton(
                          onPressed: _loadFolders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _folders.isEmpty
                  ? const Center(child: Text('No folders yet.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _folders.length,
                      itemBuilder: (context, index) {
                        final folder = _folders[index];
                        final count = _cardCounts[folder.id] ?? 0;
                        final icon = _suitIcon(folder.folderName);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              if (folder.id == null) return;
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => CardsScreen(folderId: folder.id!, folderName: folder.folderName),
                                ),
                              );
                              _loadFolders();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    folder.folderName,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text('$count cards', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteFolder(folder),
                                    tooltip: 'Delete folder',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
