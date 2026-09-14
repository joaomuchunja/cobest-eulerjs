import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/checkout/domain/services/checkout_service_interface.dart';

class MpesaPaymentService {
  final CheckoutServiceInterface checkoutService;
  MpesaPaymentService({required this.checkoutService});

  Future<ApiResponseModel> placeOrderByMpesa({
    required String mpesaPhoneNumber,
    required String addressId,
    required String billingAddressId,
    String? couponCode,
    double? couponDiscount,
    String? orderNote,
    String? guestId,
    double? bringChangeAmount,
  }) async {
    // Monta o payload conforme documentação
    final Map<String, dynamic> payload = {
      "mpesa_phone_number": mpesaPhoneNumber,
      "address_id": addressId,
      "billing_address_id": billingAddressId,
      "coupon_code": couponCode,
      "coupon_discount": couponDiscount ?? 0,
      "order_note": orderNote,
      "guest_id": guestId,
      "bring_change_amount": bringChangeAmount ?? 0,
    };
    // Remove campos nulos
    payload.removeWhere((k, v) => v == null);
    try {
      // O cast é seguro pois CheckoutService é a implementação concreta
      final repo = (checkoutService as dynamic).checkoutRepositoryInterface;
      final response = await repo.dioClient!.post(
        '/api/v1/customer/order/place-by-mpesa',
        data: payload,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(e.toString());
    }
  }
}
