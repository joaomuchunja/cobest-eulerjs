import 'package:flutter/material.dart';
import 'package:cobes_marketplace/features/purchase_installment/controllers/purchase_installment_controller.dart';
import 'package:cobes_marketplace/features/purchase_installment/domain/models/purchase_request_store_model.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Lets the customer pick the preferred store returned by
/// `GET /api/v1/purchase-requests/stores` (approved sellers only).
class PurchaseStoreBottomSheet extends StatelessWidget {
  const PurchaseStoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseInstallmentController>(
      builder: (context, purchaseInstallmentProvider, child) {
        final List<PurchaseRequestStore> stores = purchaseInstallmentProvider.storesModel?.stores ?? [];
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeDefault))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Text(getTranslated('select_a_store', context) ?? '',
                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ),
            Flexible(
              child: ListView.builder(
                  itemCount: stores.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final PurchaseRequestStore store = stores[index];
                    final bool isSelected = purchaseInstallmentProvider.selectedStoreId == store.id;
                    return InkWell(onTap: () {
                      purchaseInstallmentProvider.setSelectedStore(store.id!);
                      Navigator.of(context).pop();
                    },
                      child: Container(decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: .1) : Theme.of(context).cardColor),
                        child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Row(children: [
                            Expanded(child: Text(store.name ?? '',
                              style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color))),
                            if (isSelected) Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                          ]),
                        ),
                      ),
                    );
                  }),
            ),
          ]),
        );
      },
    );
  }
}
