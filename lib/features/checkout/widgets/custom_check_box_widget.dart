import 'package:flutter/material.dart';
import 'package:cobes_marketplace/features/checkout/controllers/checkout_controller.dart';
import 'package:cobes_marketplace/theme/controllers/theme_controller.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:cobes_marketplace/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  final int index;
  final bool isDigital;
  final String? icon;
  final String name;
  final String title;
  const CustomCheckBoxWidget({super.key,  required this.index, this.isDigital =  false, this.icon, required this.name, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutController>(
      builder: (context, order, child) {
        return InkWell(onTap: () {
          // Verificar se é pagamento a prazo
          if (name.toLowerCase().contains('installment') || 
              name.toLowerCase().contains('prazo') ||
              title.toLowerCase().contains('installment') ||
              title.toLowerCase().contains('prazo')) {
            print('===== PAGAMENTO A PRAZO SELECIONADO =====');
            print('Name: $name');
            print('Title: $title');
          }
          
          order.setDigitalPaymentMethodName(index, name);
        },
          child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Container(
              //padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                Theme(data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Provider.of<ThemeController>(context, listen: false).darkTheme?
                    Theme.of(context).hintColor.withValues(alpha:.5) : Theme.of(context).primaryColor.withValues(alpha:.25),),
                  child: Checkbox(visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
                    value: order.paymentMethodIndex == index,
                    activeColor: Colors.green,
                    checkColor: Theme.of(context).cardColor,
                    onChanged: (bool? isChecked) {
                      // Verificar se é pagamento a prazo
                      if (name.toLowerCase().contains('installment') || 
                          name.toLowerCase().contains('prazo') ||
                          title.toLowerCase().contains('installment') ||
                          title.toLowerCase().contains('prazo')) {
                        print('===== PAGAMENTO A PRAZO SELECIONADO (CHECKBOX) =====');
                        print('Name: $name');
                        print('Title: $title');
                      }
                      
                      order.setDigitalPaymentMethodName(index, name);
                    })),

                SizedBox(height: 40, child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: CustomImageWidget(image : icon!))),
                Expanded(child: Text(title, style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color))),
                
                // Mostrar loading indicator se estiver carregando opções de parcelamento
                if ((name.toLowerCase().contains('installment') || 
                     name.toLowerCase().contains('prazo') ||
                     title.toLowerCase().contains('installment') ||
                     title.toLowerCase().contains('prazo')) && 
                    order.isLoadingInstallmentOptions)
                  const Padding(
                    padding: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
