abstract class PurchaseInstallmentServiceInterface {
  Future<dynamic> getStores();
  Future<dynamic> createPurchaseRequest(Map<String, dynamic> body);
  Future<dynamic> getPurchaseRequest(String reference);
}
