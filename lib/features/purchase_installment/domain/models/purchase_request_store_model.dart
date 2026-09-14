/// Response of `GET /api/v1/purchase-requests/stores`: the stores a customer
/// can pick as their preferred store and the currently active installment
/// count options.
class PurchaseRequestStoresModel {
  int? totalSize;
  List<PurchaseRequestStore>? stores;
  List<int>? installmentOptions;

  PurchaseRequestStoresModel({this.totalSize, this.stores, this.installmentOptions});

  PurchaseRequestStoresModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    if (json['stores'] != null) {
      stores = <PurchaseRequestStore>[];
      json['stores'].forEach((v) {
        stores!.add(PurchaseRequestStore.fromJson(v));
      });
    }
    if (json['installment_options'] != null) {
      installmentOptions = List<int>.from(json['installment_options']);
    }
  }
}

class PurchaseRequestStore {
  int? id;
  String? name;

  PurchaseRequestStore({this.id, this.name});

  PurchaseRequestStore.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
