import 'dart:io';

import 'package:cobes_marketplace/features/order_details/domain/repositories/order_details_repository_interface.dart';
import 'package:cobes_marketplace/features/order_details/domain/services/order_details_service_interface.dart';

class OrderDetailsService implements OrderDetailsServiceInterface{
  OrderDetailsRepositoryInterface orderDetailsRepositoryInterface;
  OrderDetailsService({required this.orderDetailsRepositoryInterface});



  @override
  Future getOrderFromOrderId(String orderID) async{
    return await orderDetailsRepositoryInterface.getOrderFromOrderId(orderID);
  }

  @override
  Future getOrderDetails(String orderID) async{
    return await orderDetailsRepositoryInterface.get(orderID);
  }

  @override
  Future getOrderDetailsWithInstallments(String orderID) async{
    return await orderDetailsRepositoryInterface.getOrderDetailsWithInstallments(orderID);
  }

  @override
  Future submitInstallmentPaymentProof(int installmentId, String imagePath, String customerNote) async{
    return await orderDetailsRepositoryInterface.submitInstallmentPaymentProof(installmentId, imagePath, customerNote);
  }

  @override
  Future getOrderInvoice(String orderID) async{
    return await orderDetailsRepositoryInterface.getOrderInvoice(orderID);
  }

  @override
  Future downloadDigitalProduct(int orderDetailsId) async{
    return await orderDetailsRepositoryInterface.downloadDigitalProduct(orderDetailsId);
  }

  @override
  Future verifyDigitalProductOtp(int orderId, String otp) async{
    return await orderDetailsRepositoryInterface.otpVerificationForDigitalProduct(orderId, otp);
  }

  @override
  Future resentDigitalProductOtp(int orderId) async{
    return await orderDetailsRepositoryInterface.resendOtpForDigitalProduct(orderId);
  }

  @override
  Future trackOrder(String orderId, String phoneNumber) async{
    return await orderDetailsRepositoryInterface.trackYourOrder(orderId, phoneNumber);
  }

  @override
  Future<HttpClientResponse> productDownload(String url) async{
    return await orderDetailsRepositoryInterface.productDownload(url);
  }



}