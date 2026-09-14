import 'dart:io';
import 'package:cobes_marketplace/interface/repo_interface.dart';

abstract class OrderDetailsRepositoryInterface<T> extends RepositoryInterface{

  Future<dynamic> getOrderFromOrderId(String orderID);

  Future<dynamic> getOrderInvoice(String orderID);

  Future<dynamic> getOrderDetailsWithInstallments(String orderID);

  Future<dynamic> submitInstallmentPaymentProof(int installmentId, String imagePath, String customerNote);

  Future<dynamic> downloadDigitalProduct(int orderDetailsId);

  Future<dynamic> resendOtpForDigitalProduct(int orderId);

  Future<dynamic> otpVerificationForDigitalProduct(int orderId, String otp);

  Future<dynamic> trackYourOrder(String orderId, String phoneNumber);

  Future<HttpClientResponse> productDownload(String url);

}