/// Model for a suit folder (Hearts, Spades, Diamonds, Clubs).
class Folder {
  final int? id;
  final String folderName;
  final String timestamp;

  const Folder({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'folder_name': folderName,
      'timestamp': timestamp,
    };
  }

  factory Folder.fromMap(Map<String, Object?> map) {
    return Folder(
      id: map['id'] as int?,
      folderName: map['folder_name'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  Folder copyWith({int? id, String? folderName, String? timestamp}) {
    return Folder(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
