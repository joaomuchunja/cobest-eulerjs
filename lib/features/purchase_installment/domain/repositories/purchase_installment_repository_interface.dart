import 'package:cobes_marketplace/interface/repo_interface.dart';

abstract class PurchaseInstallmentRepositoryInterface<T> extends RepositoryInterface {
  Future<dynamic> getStores();
  Future<dynamic> createPurchaseRequest(Map<String, dynamic> body);
  Future<dynamic> getPurchaseRequest(String reference);
}
