import 'package:flutter/material.dart';
import 'package:cobes_marketplace/common/basewidget/custom_app_bar_widget.dart';
import 'package:cobes_marketplace/common/basewidget/custom_asset_image_widget.dart';
import 'package:cobes_marketplace/common/basewidget/custom_button_widget.dart';
import 'package:cobes_marketplace/common/basewidget/custom_loader_widget.dart';
import 'package:cobes_marketplace/common/basewidget/custom_textfield_widget.dart';
import 'package:cobes_marketplace/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:cobes_marketplace/features/auth/controllers/auth_controller.dart';
import 'package:cobes_marketplace/features/purchase_installment/controllers/purchase_installment_controller.dart';
import 'package:cobes_marketplace/features/purchase_installment/widgets/installments_bottom_sheet.dart';
import 'package:cobes_marketplace/features/purchase_installment/widgets/purchase_store_bottom_sheet.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:cobes_marketplace/utill/images.dart';
import 'package:provider/provider.dart';

/// The "Compra a Prazo / Purchase by installment" request form, backed
/// natively by `POST /api/v1/purchase-requests` (see
/// API_PEDIDOS_COMPRA_A_PRAZO.md) instead of embedding the storefront page.
class PurchaseByInstallmentScreen extends StatefulWidget {
  const PurchaseByInstallmentScreen({super.key});

  @override
  State<PurchaseByInstallmentScreen> createState() => _PurchaseByInstallmentScreenState();
}

class _PurchaseByInstallmentScreenState extends State<PurchaseByInstallmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final PurchaseInstallmentController provider = Provider.of<PurchaseInstallmentController>(context, listen: false);
      provider.resetForm();
      provider.getStores();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, PurchaseInstallmentController purchaseInstallmentProvider, bool isLoggedIn) async {
    if (!isLoggedIn && _nameController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('name_is_required', context), context);
    } else if (!isLoggedIn && _emailController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('email_is_required', context), context);
    } else if (!isLoggedIn && _phoneController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('phone_is_required', context), context);
    } else if (_descriptionController.text.trim().length < 10) {
      showCustomSnackBar(getTranslated('product_description_is_required', context), context);
    } else if (purchaseInstallmentProvider.selectedInstallments == null) {
      showCustomSnackBar(getTranslated('please_select_installments', context), context);
    } else if (purchaseInstallmentProvider.storeType == 'specific_store' && purchaseInstallmentProvider.selectedStoreId == null) {
      showCustomSnackBar(getTranslated('please_select_a_store', context), context);
    } else {
      final bool success = await purchaseInstallmentProvider.submitPurchaseRequest(
        name: isLoggedIn ? null : _nameController.text.trim(),
        email: isLoggedIn ? null : _emailController.text.trim(),
        phone: isLoggedIn ? null : _phoneController.text.trim(),
        productDescription: _descriptionController.text.trim(),
      );
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _selectorField({required BuildContext context, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(onTap: onTap,
      child: Container(width: double.infinity, height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor, border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .5))),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Expanded(child: Text(value.isEmpty ? label : value, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: value.isEmpty ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color))),
              const Icon(Icons.arrow_drop_down),
            ]),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated('purchase_by_installment', context)!,
        centerTitle: true,
        reset: InkWell(
          splashColor: Theme.of(context).splashColor,
          highlightColor: Theme.of(context).splashColor,
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
            child: CustomAssetImageWidget(Images.crossIcon),
          ),
        ),
        showResetIcon: true,
      ),
      body: Consumer<PurchaseInstallmentController>(
        builder: (context, purchaseInstallmentProvider, child) {
          if (purchaseInstallmentProvider.isLoading && purchaseInstallmentProvider.storesModel == null) {
            return const Center(child: CustomLoaderWidget());
          }

          return ListView(physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge), children: [

            if (!isLoggedIn) ...[
              CustomTextFieldWidget(
                focusNode: _nameNode, nextFocus: _emailNode, required: true,
                inputAction: TextInputAction.next,
                labelText: getTranslated('full_name', context),
                hintText: getTranslated('full_name', context),
                controller: _nameController,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomTextFieldWidget(
                focusNode: _emailNode, nextFocus: _phoneNode, required: true,
                inputAction: TextInputAction.next,
                inputType: TextInputType.emailAddress,
                labelText: getTranslated('email', context),
                hintText: getTranslated('email', context),
                controller: _emailController,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomTextFieldWidget(
                focusNode: _phoneNode, nextFocus: _descriptionNode, required: true,
                inputAction: TextInputAction.next,
                inputType: TextInputType.phone,
                labelText: getTranslated('phone_number', context),
                hintText: '+258840000000',
                controller: _phoneController,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],

            CustomTextFieldWidget(
              focusNode: _descriptionNode, required: true,
              inputAction: TextInputAction.newline,
              inputType: TextInputType.multiline,
              maxLines: 5,
              labelText: getTranslated('product_description', context),
              hintText: getTranslated('describe_the_product_you_want_to_purchase', context),
              controller: _descriptionController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(getTranslated('number_of_installments', context) ?? '',
                style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _selectorField(
              context: context,
              label: getTranslated('select_installments', context) ?? '',
              value: purchaseInstallmentProvider.selectedInstallments == null ? ''
                  : '${purchaseInstallmentProvider.selectedInstallments} ${getTranslated('installments', context) ?? ''}',
              onTap: () => showModalBottomSheet(backgroundColor: Colors.transparent,
                  context: context, builder: (_) => const InstallmentsBottomSheet()),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(getTranslated('store_preference', context) ?? '',
                style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(children: [
              Expanded(child: InkWell(
                onTap: () => purchaseInstallmentProvider.setStoreType('any_store'),
                child: Container(height: 45, alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                    color: purchaseInstallmentProvider.storeType == 'any_store' ? Theme.of(context).primaryColor.withValues(alpha: .1) : Theme.of(context).cardColor,
                    border: Border.all(color: purchaseInstallmentProvider.storeType == 'any_store' ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: .5))),
                  child: Text(getTranslated('any_store', context) ?? '',
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: purchaseInstallmentProvider.storeType == 'any_store' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
                ),
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: InkWell(
                onTap: () => purchaseInstallmentProvider.setStoreType('specific_store'),
                child: Container(height: 45, alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                    color: purchaseInstallmentProvider.storeType == 'specific_store' ? Theme.of(context).primaryColor.withValues(alpha: .1) : Theme.of(context).cardColor,
                    border: Border.all(color: purchaseInstallmentProvider.storeType == 'specific_store' ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: .5))),
                  child: Text(getTranslated('specific_store', context) ?? '',
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: purchaseInstallmentProvider.storeType == 'specific_store' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
                ),
              )),
            ]),

            if (purchaseInstallmentProvider.storeType == 'specific_store') ...[
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _selectorField(
                context: context,
                label: getTranslated('select_a_store', context) ?? '',
                value: purchaseInstallmentProvider.selectedStoreId == null ? ''
                    : (purchaseInstallmentProvider.storesModel?.stores?.firstWhere(
                        (store) => store.id == purchaseInstallmentProvider.selectedStoreId).name ?? ''),
                onTap: () => showModalBottomSheet(backgroundColor: Colors.transparent,
                    context: context, builder: (_) => const PurchaseStoreBottomSheet()),
              ),
            ],

            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            CustomButton(
              buttonText: getTranslated('submit', context),
              isLoading: purchaseInstallmentProvider.isSubmitLoading,
              onTap: () => _submit(context, purchaseInstallmentProvider, isLoggedIn),
            ),
          ]);
        },
      ),
    );
  }
}
