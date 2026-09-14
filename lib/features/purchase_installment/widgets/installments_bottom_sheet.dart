import 'package:flutter/material.dart';
import 'package:cobes_marketplace/features/purchase_installment/controllers/purchase_installment_controller.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Lets the customer pick one of the active installment-count options
/// returned by `GET /api/v1/purchase-requests/stores`.
class InstallmentsBottomSheet extends StatelessWidget {
  const InstallmentsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseInstallmentController>(
      builder: (context, purchaseInstallmentProvider, child) {
        final List<int> options = purchaseInstallmentProvider.storesModel?.installmentOptions ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeDefault))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Text(getTranslated('number_of_installments', context) ?? '',
                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ),
            ListView.builder(
                itemCount: options.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final int option = options[index];
                  final bool isSelected = purchaseInstallmentProvider.selectedInstallments == option;
                  return InkWell(onTap: () {
                    purchaseInstallmentProvider.setSelectedInstallments(option);
                    Navigator.of(context).pop();
                  },
                    child: Container(decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: .1) : Theme.of(context).cardColor),
                      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(children: [
                          Expanded(child: Text('$option ${getTranslated('installments', context) ?? ''}',
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color))),
                          if (isSelected) Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                        ]),
                      ),
                    ),
                  );
                }),
          ]),
        );
      },
    );
  }
}
