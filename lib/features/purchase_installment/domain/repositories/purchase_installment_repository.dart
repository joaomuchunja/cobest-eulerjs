import 'package:cobes_marketplace/data/datasource/remote/dio/dio_client.dart';
import 'package:cobes_marketplace/data/datasource/remote/exception/api_error_handler.dart';
import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/repositories/purchase_installment_repository_interface.dart';
import 'package:cobes_marketplace/utill/app_constants.dart';
import 'dart:async';

class PurchaseInstallmentRepository implements PurchaseInstallmentRepositoryInterface {
  final DioClient? dioClient;
  PurchaseInstallmentRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getStores() async {
    try {
      final response = await dioClient!.get(AppConstants.purchaseRequestStores);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> createPurchaseRequest(Map<String, dynamic> body) async {
    try {
      final response = await dioClient!.post(AppConstants.purchaseRequestCreate, data: body);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getPurchaseRequest(String reference) async {
    try {
      final response = await dioClient!.get('${AppConstants.purchaseRequestShow}$reference');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }
}
