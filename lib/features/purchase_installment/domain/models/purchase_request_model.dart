import 'package:cobes_marketplace/features/purchase_installment/domain/models/purchase_request_store_model.dart';

/// The `data` object returned by `POST /api/v1/purchase-requests` and
/// `GET /api/v1/purchase-requests/{reference}`.
class PurchaseRequestModel {
  String? reference;
  String? name;
  String? email;
  String? phone;
  String? productDescription;
  int? installments;
  String? storePreference;
  PurchaseRequestStore? store;
  String? source;
  String? status;
  String? createdAt;

  PurchaseRequestModel({
    this.reference, this.name, this.email, this.phone, this.productDescription,
    this.installments, this.storePreference, this.store, this.source, this.status, this.createdAt,
  });

  PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    reference = json['reference'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    productDescription = json['product_description'];
    installments = json['installments'];
    storePreference = json['store_preference'];
    store = json['store'] != null ? PurchaseRequestStore.fromJson(json['store']) : null;
    source = json['source'];
    status = json['status'];
    createdAt = json['created_at'];
  }
}
