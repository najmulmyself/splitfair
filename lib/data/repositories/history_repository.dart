import 'package:hive_flutter/hive_flutter.dart';
import '../models/split_session.dart';

/// Hive-backed repository for storing and retrieving split history.
/// Stores a maximum of 20 sessions. Oldest records are deleted when full.
class HistoryRepository {
  static const _boxName = 'split_history';
  static const _maxRecords = 20;

  /// Opens the Hive box. Call once during app startup.
  Future<void> init() async {
    await Hive.openBox<SplitSession>(_boxName);
  }

  Box<SplitSession> get _box => Hive.box<SplitSession>(_boxName);

  /// Saves a [SplitSession] to history.
  /// If the box already contains [_maxRecords], the oldest entry is deleted.
  Future<void> save(SplitSession session) async {
    if (_box.length >= _maxRecords) {
      final oldest = _box.keys.first;
      await _box.delete(oldest);
    }
    await _box.put(session.id, session);
  }

  /// Returns all sessions sorted newest first.
  List<SplitSession> getAll() {
    final sessions = _box.values.toList();
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  /// Returns a session by ID, or null if not found.
  SplitSession? getById(String id) => _box.get(id);

  /// Deletes a session by ID.
  Future<void> delete(String sessionId) async {
    await _box.delete(sessionId);
  }

  /// Deletes all stored sessions.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Returns the total number of saved sessions.
  int get count => _box.length;
}
