import 'package:cobes_marketplace/features/purchase_installment/domain/repositories/purchase_installment_repository_interface.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/services/purchase_installment_service_interface.dart';

class PurchaseInstallmentService implements PurchaseInstallmentServiceInterface {
  PurchaseInstallmentRepositoryInterface purchaseInstallmentRepositoryInterface;
  PurchaseInstallmentService({required this.purchaseInstallmentRepositoryInterface});

  @override
  Future getStores() async {
    return await purchaseInstallmentRepositoryInterface.getStores();
  }

  @override
  Future createPurchaseRequest(Map<String, dynamic> body) async {
    return await purchaseInstallmentRepositoryInterface.createPurchaseRequest(body);
  }

  @override
  Future getPurchaseRequest(String reference) async {
    return await purchaseInstallmentRepositoryInterface.getPurchaseRequest(reference);
  }
}
