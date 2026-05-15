import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/split_session.dart';
import '../../data/repositories/history_repository.dart';

part 'history_provider.g.dart';

/// Provides the [HistoryRepository] instance.
final historyRepositoryProvider = Provider<HistoryRepository>(
  (_) => HistoryRepository(),
);

/// Manages the split history list.
@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  @override
  List<SplitSession> build() {
    return ref.watch(historyRepositoryProvider).getAll();
  }

  /// Saves a session to history and refreshes the list.
  Future<void> save(SplitSession session) async {
    await _repo.save(session);
    state = _repo.getAll();
  }

  /// Deletes a session from history by ID.
  Future<void> delete(String sessionId) async {
    await _repo.delete(sessionId);
    state = _repo.getAll();
  }

  /// Clears all history.
  Future<void> clear() async {
    await _repo.clear();
    state = [];
  }
}
