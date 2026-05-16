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
@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  @override
  List<SplitSession> build() {
    return ref.watch(historyRepositoryProvider).getAll();
  }

  /// Saves a session to history and refreshes the list.
  Future<void> save(SplitSession session) async {
    final repo = _repo; // capture before any await
    await repo.save(session);
    state = repo.getAll();
  }

  /// Deletes a session from history by ID.
  Future<void> delete(String sessionId) async {
    final repo = _repo; // capture before any await
    await repo.delete(sessionId);
    state = repo.getAll();
  }

  /// Clears all history.
  Future<void> clear() async {
    final repo = _repo; // capture before any await
    await repo.clear();
    state = [];
  }
}
