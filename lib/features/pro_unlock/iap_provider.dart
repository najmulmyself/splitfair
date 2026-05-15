import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../settings/settings_provider.dart';

part 'iap_provider.g.dart';

/// Product ID — must match App Store Connect exactly.
const kProProductId = 'com.splitfair.pro';

/// Tip jar product ID.
const kCoffeeProductId = 'com.splitfair.coffee';

/// Manages in-app purchase state for Pro and tip jar.
@riverpod
class IapNotifier extends _$IapNotifier {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  IapState build() {
    ref.onDispose(() => _subscription?.cancel());
    _listenToPurchaseUpdates();
    final isPro = ref.watch(settingsRepositoryProvider).isPro;
    return IapState(isPro: isPro);
  }

  void _listenToPurchaseUpdates() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> updates) {
    for (final purchase in updates) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverPurchase(purchase);
        case PurchaseStatus.error:
          state = state.copyWith(
            errorMessage: purchase.error?.message,
            isPurchasing: false,
          );
        case PurchaseStatus.pending:
          state = state.copyWith(isPurchasing: true);
        case PurchaseStatus.canceled:
          state = state.copyWith(isPurchasing: false);
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    if (purchase.productID == kProProductId) {
      ref.read(settingsNotifierProvider.notifier).setIsPro(true);
      state = state.copyWith(isPro: true, isPurchasing: false);
    } else if (purchase.productID == kCoffeeProductId) {
      // Tip jar — just complete the purchase with a thank-you.
      state = state.copyWith(isPurchasing: false);
    }
  }

  /// Initiates purchase of [kProProductId].
  Future<void> purchasePro() async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'Store not available',
        );
        return;
      }
      final response = await InAppPurchase.instance.queryProductDetails(
        {kProProductId},
      );
      if (response.productDetails.isEmpty) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'Product not found',
        );
        return;
      }
      final param = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Initiates purchase of [kCoffeeProductId] (tip jar, consumable).
  Future<void> purchaseCoffee() async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        state = state.copyWith(isPurchasing: false);
        return;
      }
      final response = await InAppPurchase.instance.queryProductDetails(
        {kCoffeeProductId},
      );
      if (response.productDetails.isEmpty) {
        state = state.copyWith(isPurchasing: false);
        return;
      }
      final param = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } catch (e) {
      state = state.copyWith(isPurchasing: false);
    }
  }

  /// Restores previous purchases.
  Future<void> restore() async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Snapshot of IAP state.
class IapState {
  const IapState({
    this.isPro = false,
    this.isPurchasing = false,
    this.errorMessage,
  });

  final bool isPro;
  final bool isPurchasing;
  final String? errorMessage;

  IapState copyWith({bool? isPro, bool? isPurchasing, String? errorMessage}) =>
      IapState(
        isPro: isPro ?? this.isPro,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
