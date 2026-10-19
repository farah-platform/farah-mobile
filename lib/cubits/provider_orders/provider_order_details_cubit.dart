import 'dart:typed_data';

import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'provider_order_errors.dart';

class ProviderOrderDetailsState {
  final Map<String, dynamic>? booking;

  /// Saved payment instructions, used to prefill the accept sheet.
  final String? paymentInstructions;
  /// The provider's earnings account (bank_name, account_number, iban).
  final Map<String, dynamic> payoutAccount;
  final Map<int, Uint8List> proofs;
  final bool loading;
  final bool acting;

  /// One-off feedback for a snackbar.
  final String? message;
  final String? error;

  const ProviderOrderDetailsState({
    this.booking,
    this.paymentInstructions,
    this.payoutAccount = const {},
    this.proofs = const {},
    this.loading = false,
    this.acting = false,
    this.message,
    this.error,
  });

  ProviderOrderDetailsState copyWith({
    Map<String, dynamic>? booking,
    String? paymentInstructions,
    Map<String, dynamic>? payoutAccount,
    Map<int, Uint8List>? proofs,
    bool? loading,
    bool? acting,
    String? message,
    String? error,
  }) {
    return ProviderOrderDetailsState(
      booking: booking ?? this.booking,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      proofs: proofs ?? this.proofs,
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      message: message,
      error: error,
    );
  }
}

/// One booking: accept/reject, review the deposit proof, mark it done.
class ProviderOrderDetailsCubit extends Cubit<ProviderOrderDetailsState> {
  final ProviderRepository _repository;
  final int bookingId;

  ProviderOrderDetailsCubit(this._repository, this.bookingId)
    : super(const ProviderOrderDetailsState(loading: true));

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true));
    try {
      final booking = await _repository.getBookingDetails(bookingId);
      String? instructions;
      Map<String, dynamic>? payout;
      try {
        final provider = (await _repository.getDashboardData())['provider'];
        if (provider is Map) {
          instructions = provider['payment_instructions']?.toString();
          final account = provider['payout_account'];
          if (account is Map) payout = Map<String, dynamic>.from(account);
        }
      } catch (_) {
        // Only used to prefill fields.
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          booking: booking,
          paymentInstructions: instructions,
          payoutAccount: payout,
          loading: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل الطلب'),
        ),
      );
    }
  }

  Future<void> accept({
    required double deposit,
    required String instructions,
  }) => _act('تم قبول الطلب وإرسال تعليمات الدفع للعميل', () async {
    if (instructions.trim() != (state.paymentInstructions ?? '').trim()) {
      await _repository.updatePaymentInstructions(instructions.trim());
    }
    await _repository.decideBooking(
      bookingId,
      'accepted',
      depositAmount: deposit,
    );
  });

  Future<void> reject(String note) => _act(
    'تم رفض الطلب',
    () => _repository.decideBooking(bookingId, 'rejected', note: note),
  );

  Future<void> reviewPayment(int paymentId, String decision, {String? note}) =>
      _act(
        decision == 'confirmed'
            ? 'تم اعتماد الدفع وتأكيد الحجز'
            : 'تم رفض إثبات الدفع',
        () => _repository.reviewPaymentProof(
          bookingId,
          paymentId,
          decision,
          reviewNote: note,
        ),
      );

  Future<void> complete() => _act(
    'تم تسجيل تنفيذ الطلب',
    () => _repository.completeBooking(bookingId),
  );

  Future<void> loadProof(int paymentId) async {
    try {
      final bytes = await _repository.getPaymentProof(bookingId, paymentId);
      if (isClosed) return;
      emit(
        state.copyWith(
          proofs: {...state.proofs, paymentId: Uint8List.fromList(bytes)},
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(error: providerOrderError(e, 'تعذّر تحميل إثبات الدفع')),
      );
    }
  }

  Future<void> _act(String done, Future<void> Function() action) async {
    if (isClosed || state.acting) return;
    emit(state.copyWith(acting: true));
    try {
      await action();
      final booking = await _repository.getBookingDetails(bookingId);
      if (isClosed) return;
      emit(state.copyWith(booking: booking, acting: false, message: done));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          acting: false,
          error: providerOrderError(e, 'تعذّر تنفيذ الإجراء'),
        ),
      );
    }
  }
}
