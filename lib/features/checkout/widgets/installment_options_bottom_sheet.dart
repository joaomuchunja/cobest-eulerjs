import 'package:flutter/material.dart';
import 'package:cobes_marketplace/features/checkout/domain/models/installment_options_model.dart';
import 'package:cobes_marketplace/features/checkout/controllers/checkout_controller.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:cobes_marketplace/common/basewidget/custom_button_widget.dart';
import 'package:provider/provider.dart';

class InstallmentOptionsBottomSheet extends StatefulWidget {
  final InstallmentOptionsModel installmentOptions;
  final Function(bool success, String message, String? orderId)? onOrderComplete;
  
  const InstallmentOptionsBottomSheet({
    super.key,
    required this.installmentOptions,
    this.onOrderComplete,
  });

  @override
  State<InstallmentOptionsBottomSheet> createState() => _InstallmentOptionsBottomSheetState();
}

class _InstallmentOptionsBottomSheetState extends State<InstallmentOptionsBottomSheet> {
  int? selectedPeriod;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: Center(
              child: Container(
                width: 35,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento a Prazo',
                  style: titilliumSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                    child: Text(
                      'Escolha quantos meses deseja para pagar. Será aplicada taxa de juros e taxa de processamento conforme configurado.',
                      style: textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart total
          if (widget.installmentOptions.cartTotalFormatted != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total do Carrinho:',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    '${widget.installmentOptions.cartTotalFormatted} ',
                    style: titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

          // Instructions
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: Text(
              'Selecione o número de meses (1 - ${widget.installmentOptions.installmentOptions?.length ?? 0} Meses):',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),

          // Installment options list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: widget.installmentOptions.installmentOptions?.map((option) {
                  final isSelected = selectedPeriod == option.period;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPeriod = option.period;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Radio button
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).hintColor,
                                width: 2,
                              ),
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          
                          // Option details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.description ?? '',
                                  style: titilliumSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Parcela: ',
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      '${option.installmentValueFormatted} ',
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      option.periodText ?? '',
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList() ?? [],
              ),
            ),
          ),

          // Confirm button
          CustomButton(
            buttonText: selectedPeriod != null 
                ? 'Confirmar ${selectedPeriod}x' 
                : '${getTranslated('select_option', context) ?? 'Selecione uma opção'}',
            backgroundColor: selectedPeriod != null 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).disabledColor,
            onTap: selectedPeriod != null ? () async {
              final selectedOption = widget.installmentOptions.installmentOptions
                  ?.firstWhere((option) => option.period == selectedPeriod);
              
              if (selectedOption != null) {
                // Store selected option in controller
                final checkoutController = Provider.of<CheckoutController>(context, listen: false);
                checkoutController.setSelectedInstallmentOption(selectedOption);
                
                print('===== OPÇÃO DE PARCELAMENTO SELECIONADA =====');
                print('Período: ${selectedOption.period} meses');
                print('Valor da parcela: ${selectedOption.installmentValueFormatted} ');
                print('Descrição: ${selectedOption.description}');
                
                // Close bottom sheet first
                Navigator.of(context).pop();
                
                // Place order by installment
                final response = await checkoutController.placeOrderByInstallment(
                  paymentPeriod: selectedOption.period!,
                  addressId: checkoutController.addressIndex?.toString(),
                  billingAddressId: checkoutController.billingAddressIndex?.toString(),
                  couponCode: null, // You might want to get this from the controller
                  orderNote: checkoutController.orderNoteController.text.trim(),
                );
                
                // Handle response and call callback
                if (response.response != null && response.response!.statusCode == 200) {
                  print('===== PEDIDO FINALIZADO COM SUCESSO =====');
                  widget.onOrderComplete?.call(
                    true, 
                    response.response!.data['message'] ?? 'Pedido criado com sucesso',
                    response.response!.data['order_ids']?.toString()
                  );
                } else {
                  print('===== ERRO AO FINALIZAR PEDIDO =====');
                  widget.onOrderComplete?.call(
                    false, 
                    response.error ?? 'Erro ao processar pagamento a prazo',
                    null
                  );
                }
              }
            } : null,
          ),
        ],
      ),
    );
  }
}