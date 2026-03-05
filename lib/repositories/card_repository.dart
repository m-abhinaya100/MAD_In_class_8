import '../database/database_helper.dart';
import '../models/card_model.dart';

/// Repository for card CRUD. All card operations go through this layer.
class CardRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<CardModel>> getCardsByFolderId(int folderId) async {
    final db = await _db.database;
    final maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );
    return maps.map(CardModel.fromMap).toList();
  }

  Future<CardModel?> getCardById(int id) async {
    final db = await _db.database;
    final maps = await db.query('cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CardModel.fromMap(maps.first);
  }

  Future<int> insertCard(CardModel card) async {
    final db = await _db.database;
    return db.insert('cards', card.toMap());
  }

  Future<int> updateCard(CardModel card) async {
    final db = await _db.database;
    if (card.id == null) return 0;
    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _db.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
