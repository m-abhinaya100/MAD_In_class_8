import 'package:flutter/material.dart';

/// Non-dismissible dialog for confirming delete actions (e.g. folder/card).
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
