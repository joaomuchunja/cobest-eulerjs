import 'package:flutter/material.dart';
import 'package:cobes_marketplace/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/models/purchase_request_model.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/models/purchase_request_store_model.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/services/purchase_installment_service_interface.dart';
import 'package:cobes_marketplace/helper/api_checker.dart';
import 'package:cobes_marketplace/main.dart';

class PurchaseInstallmentController with ChangeNotifier {
  final PurchaseInstallmentServiceInterface purchaseInstallmentServiceInterface;
  PurchaseInstallmentController({required this.purchaseInstallmentServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  PurchaseRequestStoresModel? storesModel;
  PurchaseRequestModel? submittedRequest;

  String storeType = 'any_store';
  int? selectedStoreId;
  int? selectedInstallments;

  Future<void> getStores() async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await purchaseInstallmentServiceInterface.getStores();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      storesModel = PurchaseRequestStoresModel.fromJson(apiResponse.response!.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setStoreType(String type) {
    storeType = type;
    if (type == 'any_store') {
      selectedStoreId = null;
    }
    notifyListeners();
  }

  void setSelectedStore(int id) {
    selectedStoreId = id;
    notifyListeners();
  }

  void setSelectedInstallments(int installments) {
    selectedInstallments = installments;
    notifyListeners();
  }

  Future<bool> submitPurchaseRequest({
    String? name, String? email, String? phone, required String productDescription,
  }) async {
    _isSubmitLoading = true;
    notifyListeners();

    final Map<String, dynamic> body = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'product_description': productDescription,
      'installments': selectedInstallments,
      'store_type': storeType,
      'store_id': storeType == 'specific_store' ? selectedStoreId : null,
    };

    bool isSuccess = false;
    ApiResponseModel apiResponse = await purchaseInstallmentServiceInterface.createPurchaseRequest(body);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      submittedRequest = PurchaseRequestModel.fromJson(apiResponse.response!.data['data']);
      showCustomSnackBar(apiResponse.response?.data['message'], Get.context!, isError: false);
      isSuccess = true;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isSubmitLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void resetForm() {
    storeType = 'any_store';
    selectedStoreId = null;
    selectedInstallments = null;
    submittedRequest = null;
    notifyListeners();
  }
}
