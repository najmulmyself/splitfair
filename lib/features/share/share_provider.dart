import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import '../../data/models/split_result.dart';

part 'share_provider.g.dart';

/// Manages the share sheet state and screenshot capture.
@riverpod
class ShareNotifier extends _$ShareNotifier {
  @override
  ShareState build() => const ShareState();

  /// Sets the results to be shared.
  void setResults(List<SplitResult> results) {
    state = state.copyWith(results: results);
  }

  /// Updates the screenshot controller reference.
  void setController(ScreenshotController controller) {
    state = state.copyWith(screenshotController: controller);
  }

  /// Marks the share sheet as loading (e.g. during image capture).
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}

/// State for the share sheet.
class ShareState {
  const ShareState({
    this.results = const [],
    this.screenshotController,
    this.isLoading = false,
  });

  final List<SplitResult> results;
  final ScreenshotController? screenshotController;
  final bool isLoading;

  ShareState copyWith({
    List<SplitResult>? results,
    ScreenshotController? screenshotController,
    bool? isLoading,
  }) => ShareState(
    results: results ?? this.results,
    screenshotController: screenshotController ?? this.screenshotController,
    isLoading: isLoading ?? this.isLoading,
  );
}
