import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/checkout/domain/services/checkout_service_interface.dart';

class Ponto24PaymentService {
  final CheckoutServiceInterface checkoutService;
  Ponto24PaymentService({required this.checkoutService});

  Future<ApiResponseModel> placeOrderByPonto24({
    required String addressId,
    required String billingAddressId,
    String? couponCode,
    double? couponDiscount,
    String? orderNote,
    String? guestId,
  }) async {
    final Map<String, dynamic> payload = {
      "address_id": addressId,
      "billing_address_id": billingAddressId,
      "coupon_code": couponCode,
      "coupon_discount": couponDiscount ?? 0,
      "order_note": orderNote,
      "guest_id": guestId,
    };
    payload.removeWhere((k, v) => v == null);
    try {
      final repo = (checkoutService as dynamic).checkoutRepositoryInterface;
      final response = await repo.dioClient!.post(
        '/api/v1/customer/order/place-by-ponto24',
        data: payload,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(e.toString());
    }
  }
}
