import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/home/payment_request_model.dart';

abstract class PaymentRepository {
  Future<void> submitPaymentReceipt(PaymentRequestModel request);
}

class ApiPaymentRepository implements PaymentRepository {
  final DioClient _dioClient;

  ApiPaymentRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  @override
  Future<void> submitPaymentReceipt(PaymentRequestModel request) async {
    final fileName = request.receiptImage.path.split('/').last;

    final formData = FormData.fromMap({
      'booking_id': request.bookingId,
      'payment_method': request.paymentMethod,
      'amount': request.amount,
      'receipt': await MultipartFile.fromFile(
        request.receiptImage.path,
        filename: fileName,
      ),
    });

    await _dio.post(
      '/payments/receipt',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
