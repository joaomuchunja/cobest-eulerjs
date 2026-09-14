
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cobes_marketplace/data/datasource/remote/dio/dio_client.dart';
import 'package:cobes_marketplace/data/datasource/remote/exception/api_error_handler.dart';
import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/order_details/domain/repositories/order_details_repository_interface.dart';
import 'package:cobes_marketplace/main.dart';
import 'package:cobes_marketplace/features/auth/controllers/auth_controller.dart';
import 'package:cobes_marketplace/utill/app_constants.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class OrderDetailsRepository implements OrderDetailsRepositoryInterface{
  final DioClient? dioClient;
  OrderDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> get(String orderID) async {
    try {
      final response = await dioClient!.get(AppConstants.orderDetailsUri+orderID);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getOrderFromOrderId(String orderID) async {
    try {
      final response = await dioClient!.get('${AppConstants.getOrderFromOrderId}$orderID&guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getOrderDetailsWithInstallments(String orderID) async {
    try {
      final response = await dioClient!.get(AppConstants.orderDetailsWithInstallmentsUri+orderID);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> submitInstallmentPaymentProof(int installmentId, String imagePath, String customerNote) async {
    try {
      final formData = FormData.fromMap({
        'installment_id': installmentId,
        'proof_image': await MultipartFile.fromFile(imagePath),
        'customer_note': customerNote,
      });
      
      final response = await dioClient!.post(AppConstants.submitInstallmentPaymentProof, data: formData);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponseModel> downloadDigitalProduct(int orderDetailsId) async {
    try {
      final response = await dioClient!.get('${AppConstants.downloadDigitalProduct}$orderDetailsId?guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> resendOtpForDigitalProduct(int orderId) async {
    try {
      final response = await dioClient!.post(AppConstants.otpVResendForDigitalProduct,
      data: {'order_details_id' : orderId});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> otpVerificationForDigitalProduct(int orderId, String otp) async {
    try {
      final response = await dioClient!.get('${AppConstants.otpVerificationForDigitalProduct}?order_details_id=$orderId&otp=$otp&guest_id=1',);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> trackYourOrder(String orderId, String phoneNumber) async {
    try {
      final response = await dioClient!.post(AppConstants.orderTrack,
          data: {'order_id': orderId,
            'phone_number' : phoneNumber

          });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> reorder(String orderId) async {
    try {
      final response = await dioClient!.post(AppConstants.reorder,
          data: {'order_id': orderId,
          });
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }


  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future getOrderInvoice(String orderID) async{
    try {
      final response = await dioClient!.get('${AppConstants.generateInvoice}$orderID');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }




  @override
  Future<HttpClientResponse> productDownload(String? url) async {
      HttpClient client = HttpClient();
    final response = await client.getUrl(Uri.parse(url!)).then((HttpClientRequest request) {
          return request.close();
        },
      );
    return response;
  }




}
