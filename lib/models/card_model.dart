/// Model for a card belonging to a folder. Use [CardModel] to avoid conflict with Material Card.
class CardModel {
  final int? id;
  final String cardName;
  final String suit;
  final String? imageUrl;
  final int folderId;

  const CardModel({
    this.id,
    required this.cardName,
    required this.suit,
    this.imageUrl,
    required this.folderId,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'card_name': cardName,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    };
  }

  factory CardModel.fromMap(Map<String, Object?> map) {
    return CardModel(
      id: map['id'] as int?,
      cardName: map['card_name'] as String,
      suit: map['suit'] as String,
      imageUrl: map['image_url'] as String?,
      folderId: map['folder_id'] as int,
    );
  }

  CardModel copyWith({
    int? id,
    String? cardName,
    String? suit,
    String? imageUrl,
    int? folderId,
  }) {
    return CardModel(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      suit: suit ?? this.suit,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId ?? this.folderId,
    );
  }
}
