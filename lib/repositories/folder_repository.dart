import '../database/database_helper.dart';
import '../models/folder.dart';

/// Repository for folder CRUD. Keeps data access out of the UI.
class FolderRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Folder>> getAllFolders() async {
    final db = await _db.database;
    final maps = await db.query('folders', orderBy: 'id ASC');
    return maps.map(Folder.fromMap).toList();
  }

  Future<Folder?> getFolderById(int id) async {
    final db = await _db.database;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  Future<int> insertFolder(Folder folder) async {
    final db = await _db.database;
    return db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await _db.database;
    if (folder.id == null) return 0;
    return db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  /// Deletes folder; CASCADE removes all cards in this folder.
  Future<int> deleteFolder(int id) async {
    final db = await _db.database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCardCountForFolder(int folderId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return result.first['count'] as int? ?? 0;
  }
}
