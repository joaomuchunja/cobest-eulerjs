
// ================== IMPORTS ==================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/custom_themes.dart';
import '../../../helper/price_converter.dart';
import '../../../localization/language_constrants.dart';
import '../../../common/basewidget/show_custom_snakbar_widget.dart';
import '../../../common/basewidget/animated_custom_dialog_widget.dart';
import '../widgets/choose_payment_widget.dart';
import 'package:cobes_marketplace/common/basewidget/custom_button_widget.dart';
import '../widgets/checkout_condition_checkbox.dart';
import '../widgets/shipping_details_widget.dart';
import '../widgets/coupon_apply_widget.dart';
import '../widgets/mpesa_payment_widget.dart';
import '../widgets/payment_method_bottom_sheet_widget.dart';
import '../widgets/installment_options_bottom_sheet.dart';
import '../widgets/wallet_payment_widget.dart';
import 'package:cobes_marketplace/common/basewidget/amount_widget.dart';
import '../../offline_payment/screens/offline_payment_screen.dart';
import '../../address/screens/saved_address_list_screen.dart';
import '../../address/screens/saved_billing_address_list_screen.dart';
import '../../cart/domain/models/cart_model.dart';
import '../controllers/checkout_controller.dart';
import 'package:cobes_marketplace/common/basewidget/custom_textfield_widget.dart';
import '../../address/controllers/address_controller.dart';
import '../../coupon/controllers/coupon_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../shipping/controllers/shipping_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:cobes_marketplace/features/checkout/widgets/order_place_dialog_widget.dart';
import '../../profile/controllers/profile_contrroller.dart';
import '../../../helper/debounce_helper.dart';
import 'package:cobes_marketplace/features/dashboard/screens/dashboard_screen.dart';
// =============================================

// Dialog customizado para sucesso Ponto24
class _Ponto24SuccessDialog extends StatelessWidget {
  final String entity;
  final String reference;
  final String amount;
  final String invoice;
  final String orderId;
  const _Ponto24SuccessDialog({
    required this.entity,
    required this.reference,
    required this.amount,
    required this.invoice,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 56),
              const SizedBox(height: 12),
              Text('Order Placed Successfully!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              Text('Your payment has been processed and your order - $orderId has been placed.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Ponto 24 Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade900)),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Ponto24Detail(label: 'Entity', value: entity),
                        const SizedBox(height: 8),
                        _Ponto24Detail(label: 'Reference', value: reference),
                        const SizedBox(height: 8),
                        _Ponto24Detail(label: 'Amount', value: 'MZN$amount'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Invoice: $invoice', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Go to any Ponto 24 and make the deposit using these details. Your order will only be processed and shipped after deposit confirmation.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OK, Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ponto24Detail extends StatelessWidget {
  final String label;
  final String value;
  const _Ponto24Detail({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, color: Colors.black)),
      ],
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromProductDetails;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  final int? sellerId;
  final bool onlyDigital;
  final bool hasPhysical;
  final int quantity;

  const CheckoutScreen({super.key, required this.cartList, this.fromProductDetails = false,
    required this.discount, required this.tax, required this.totalOrderAmount, required this.shippingFee,
    this.sellerId, this.onlyDigital = false, required this.quantity, required this.hasPhysical});


  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();


  final FocusNode _orderNoteNode = FocusNode();
  double _order = 0;
  late bool _billingAddress;
  double? _couponDiscount;
  double? _referralDiscount;

  DebounceHelper debounceHelper = DebounceHelper(milliseconds: 500);



  @override
  void initState() {
    super.initState();
    Provider.of<AddressController>(context, listen: false).getAddressList();
    Provider.of<CheckoutController>(context, listen: false).getReferralAmount('0');
    Provider.of<CouponController>(context, listen: false).removePrevCouponData();
    Provider.of<CartController>(context, listen: false).getCartData(context);
    Provider.of<CheckoutController>(context, listen: false).resetPaymentMethod();
    Provider.of<ShippingController>(context, listen: false).getChosenShippingMethod(context);
    if(Provider.of<SplashController>(context, listen: false).configModel != null &&
        Provider.of<SplashController>(context, listen: false).configModel!.offlinePayment != null)
    {
      Provider.of<CheckoutController>(context, listen: false).getOfflinePaymentList();
    }

    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()){
      Provider.of<CouponController>(context, listen: false).getAvailableCouponList();
    }

    if(Provider.of<CheckoutController>(context, listen: false).isAcceptTerms){
      Provider.of<CheckoutController>(context, listen: false).toggleTermsCheck(isUpdate: false);
    }

  _billingAddress = Provider.of<SplashController>(context, listen: false).configModel!.billingInputByCustomer == 1;
    Provider.of<CheckoutController>(context, listen: false).clearData();
  }

  @override
  Widget build(BuildContext context) {
    _order = widget.totalOrderAmount + widget.discount;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar: Consumer<AddressController>(
        builder: (context, locationProvider,_) {
          return Consumer<CheckoutController>(
            builder: (context, orderProvider, child) {
              return Consumer<CouponController>(
                builder: (context, couponProvider, _) {
                  return Consumer<CartController>(
                    builder: (context, cartProvider,_) {
                      return Consumer<ProfileController>(
                        builder: (context, profileProvider,_) {
                          if (orderProvider.isLoading) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [SizedBox(width: 30, height: 30, child: CircularProgressIndicator())],
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            color: Theme.of(context).cardColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CheckoutConditionCheckBox(),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                CustomButton(
                                  onTap: (orderProvider.isLoading || !orderProvider.isAcceptTerms)
                                      ? null
                                      : () async {
                                    if (orderProvider.addressIndex == null && widget.hasPhysical) {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const SavedAddressListScreen()));
                                      showCustomSnackBar(getTranslated('select_a_shipping_address', context), context, isToaster: true);
                                    } else if ((orderProvider.billingAddressIndex == null && !widget.hasPhysical && !_billingAddress)) {
                                      showCustomSnackBar(getTranslated('you_cant_place_order_of_digital_product_without_billing_address', context), context, isToaster: true);
                                    } else if ((orderProvider.billingAddressIndex == null && !widget.hasPhysical && !orderProvider.sameAsBilling && _billingAddress) || (orderProvider.billingAddressIndex == null && _billingAddress && !orderProvider.sameAsBilling)) {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const SavedBillingAddressListScreen()));
                                      showCustomSnackBar(getTranslated('select_a_billing_address', context), context, isToaster: true);
                                    } else {
                                      if (!orderProvider.isCheckCreateAccount || (orderProvider.isCheckCreateAccount && (passwordFormKey.currentState?.validate() ?? false))) {
                                        String orderNote = orderProvider.orderNoteController.text.trim();
                                        String couponCode = couponProvider.discount != null && couponProvider.discount != 0 ? couponProvider.couponCode : '';
                                        String couponCodeAmount = couponProvider.discount != null && couponProvider.discount != 0 ? couponProvider.discount.toString() : '0';
                                        String addressId = orderProvider.addressIndex != null ? locationProvider.addressList![orderProvider.addressIndex!].id.toString() : '';
                                        String billingAddressId = (_billingAddress)
                                            ? (!orderProvider.sameAsBilling ? locationProvider.addressList![orderProvider.billingAddressIndex!].id.toString() : locationProvider.addressList![orderProvider.addressIndex!].id.toString())
                                            : '';


                                        // Se método M-Pesa selecionado, exibe dialogo
                                        if (orderProvider.selectedDigitalPaymentMethodName.toLowerCase().contains('mpesa')) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (c) => MpesaPaymentWidget(
                                              onConfirm: (phone) async {
                                                Navigator.of(context).pop();
                                                final resp = await orderProvider.placeOrderByMpesa(
                                                  mpesaPhoneNumber: phone,
                                                  addressId: addressId,
                                                  billingAddressId: billingAddressId,
                                                  couponCode: couponCode,
                                                  couponDiscount: double.tryParse(couponCodeAmount) ?? 0,
                                                  orderNote: orderNote,
                                                  guestId: Provider.of<AuthController>(context, listen: false).isLoggedIn()
                                                      ? null
                                                      : Provider.of<AuthController>(context, listen: false).getGuestToken(),
                                                  bringChangeAmount: 0,
                                                );
                                                if (resp.response != null && resp.response!.statusCode == 200) {
                                                  _callback(true, resp.response!.data['message'] ?? 'Pedido criado com sucesso', resp.response!.data['order_ids']?.toString() ?? '', false);
                                                } else {
                                                  showCustomSnackBar(resp.error ?? 'Erro ao processar pagamento M-Pesa', context, isToaster: true);
                                                }
                                              },
                                            ),
                                          );
                                          return;
                                        }

                                        // Se método Ponto24 selecionado, chama API e exibe tela de sucesso customizada
                                        if (orderProvider.selectedDigitalPaymentMethodName.toLowerCase().contains('ponto24')) {
                                          final resp = await orderProvider.placeOrderByPonto24(
                                            addressId: addressId,
                                            billingAddressId: billingAddressId,
                                            couponCode: couponCode,
                                            couponDiscount: double.tryParse(couponCodeAmount) ?? 0,
                                            orderNote: orderNote,
                                            guestId: Provider.of<AuthController>(context, listen: false).isLoggedIn()
                                                ? null
                                                : Provider.of<AuthController>(context, listen: false).getGuestToken(),
                                          );
                                          if (resp.response != null && resp.response!.statusCode == 200) {
                                            // Exibe tela customizada com dados Ponto24
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => _Ponto24SuccessDialog(
                                                entity: resp.response!.data['entity']?.toString() ?? '',
                                                reference: resp.response!.data['ponto24_reference']?.toString() ?? '',
                                                amount: resp.response!.data['amount']?.toString() ?? '',
                                                invoice: resp.response!.data['invoice_number']?.toString() ?? '',
                                                orderId: (resp.response!.data['order_ids'] is List && resp.response!.data['order_ids'].isNotEmpty)
                                                    ? resp.response!.data['order_ids'][0].toString()
                                                    : '',
                                              ),
                                            );
                                          } else {
                                            showCustomSnackBar(resp.error ?? 'Erro ao processar pagamento Ponto24', context, isToaster: true);
                                          }
                                          return;
                                        }

                                        // Se método Pagamento a Prazo selecionado, abre bottom sheet para seleção de parcelas
                                        if (orderProvider.selectedDigitalPaymentMethodName.toLowerCase().contains('prazo') || 
                                            orderProvider.selectedDigitalPaymentMethodName.toLowerCase().contains('installment')) {
                                          
                                          // Primeiro busca as opções de parcelamento
                                          final installmentResponse = await orderProvider.getInstallmentOptions(
                                            couponDiscount: double.tryParse(couponCodeAmount) ?? 0,
                                          );
                                          
                                          if (installmentResponse.response != null && 
                                              installmentResponse.response!.statusCode == 200 &&
                                              orderProvider.installmentOptions != null) {
                                            
                                            // Abre bottom sheet para seleção de parcelas
                                            await showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => Consumer<CheckoutController>(
                                                builder: (context, checkoutController, _) {
                                                  return InstallmentOptionsBottomSheet(
                                                    installmentOptions: checkoutController.installmentOptions!,
                                                    onOrderComplete: (success, message, orderId) {
                                                      if (success) {
                                                        _callback(true, message, orderId ?? '', false);
                                                      } else {
                                                        showCustomSnackBar(message, context, isToaster: true);
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                            
                                          } else {
                                            showCustomSnackBar('Erro ao carregar opções de parcelamento', context, isToaster: true);
                                          }
                                          return;
                                        }

                                        if (orderProvider.paymentMethodIndex != -1) {
                                          orderProvider.digitalPaymentPlaceOrder(
                                            orderNote: orderNote,
                                            customerId: Provider.of<AuthController>(context, listen: false).isLoggedIn()
                                                ? profileProvider.userInfoModel?.id.toString()
                                                : Provider.of<AuthController>(context, listen: false).getGuestToken(),
                                            addressId: addressId,
                                            billingAddressId: billingAddressId,
                                            couponCode: couponCode,
                                            couponDiscount: couponCodeAmount,
                                            paymentMethod: orderProvider.selectedDigitalPaymentMethodName,
                                          );
                                        } else if (orderProvider.isCODChecked && !widget.onlyDigital) {
                                          orderProvider.placeOrder(
                                            callback: _callback,
                                            addressID: addressId,
                                            couponCode: couponCode,
                                            couponAmount: couponCodeAmount,
                                            billingAddressId: billingAddressId,
                                            orderNote: orderNote,
                                          );
                                        } else if (orderProvider.isOfflineChecked) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => OfflinePaymentScreen(
                                                payableAmount: _order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + widget.tax,
                                                callback: _callback,
                                              ),
                                            ),
                                          );
                                        } else if (orderProvider.isWalletChecked) {
                                          showAnimatedDialog(
                                            context,
                                            WalletPaymentWidget(
                                              currentBalance: profileProvider.balance ?? 0,
                                              orderAmount: _order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + widget.tax,
                                              onTap: () {
                                                if (profileProvider.balance! < (_order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + widget.tax)) {
                                                  showCustomSnackBar(getTranslated('insufficient_balance', context), context, isToaster: true);
                                                } else {
                                                  Navigator.pop(context);
                                                  orderProvider.placeOrder(
                                                    callback: _callback,
                                                    wallet: true,
                                                    addressID: addressId,
                                                    couponCode: couponCode,
                                                    couponAmount: couponCodeAmount,
                                                    billingAddressId: billingAddressId,
                                                    orderNote: orderNote,
                                                  );
                                                }
                                              },
                                            ),
                                            dismissible: false,
                                            willFlip: true,
                                          );
                                        } else {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (c) => PaymentMethodBottomSheetWidget(onlyDigital: widget.onlyDigital),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  buttonText: '${getTranslated('proceed', context)}',
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
  appBar: AppBar(title: Text(getTranslated('checkout', context) ?? 'Checkout')),
      body: Consumer<AuthController>(
        builder: (context, authProvider, _) {
          return Consumer<CheckoutController>(
            builder: (context, orderProvider, _) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                          child: ShippingDetailsWidget(
                            hasPhysical: widget.hasPhysical,
                            billingAddress: _billingAddress,
                            passwordFormKey: passwordFormKey,
                          ),
                        ),
                        if (Provider.of<AuthController>(context, listen: false).isLoggedIn())
                          Padding(
                            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            child: CouponApplyWidget(
                              couponController: _controller,
                              orderAmount: _order,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: ChoosePaymentWidget(onlyDigital: widget.onlyDigital),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeSmall),
                          child: Text(
                            getTranslated('order_summary', context) ?? '',
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Consumer<CheckoutController>(
                            builder: (context, checkoutController, child) {
                              _couponDiscount = Provider.of<CouponController>(context).discount ?? 0;
                              _referralDiscount = Provider.of<CheckoutController>(context).referralAmount?.amount ?? 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.quantity > 1
                                      ? AmountWidget(
                                          title:
                                              '${getTranslated('sub_total', context)} (${widget.quantity} ${getTranslated('items', context)}) ',
                                          amount: PriceConverter.convertPrice(context, _order),
                                        )
                                      : AmountWidget(
                                          title:
                                              '${getTranslated('sub_total', context)} (${widget.quantity} ${getTranslated('item', context)})',
                                          amount: PriceConverter.convertPrice(context, _order),
                                        ),
                                  AmountWidget(
                                    title: getTranslated('shipping_fee', context),
                                    amount: PriceConverter.convertPrice(context, widget.shippingFee),
                                  ),
                                  AmountWidget(
                                    title: getTranslated('discount', context),
                                    amount: PriceConverter.convertPrice(context, widget.discount),
                                  ),
                                  AmountWidget(
                                    title: getTranslated('coupon_voucher', context),
                                    amount: PriceConverter.convertPrice(context, _couponDiscount),
                                  ),
                                  AmountWidget(
                                    title: getTranslated('tax', context),
                                    amount: PriceConverter.convertPrice(context, widget.tax),
                                  ),
                                  if ((_referralDiscount ?? 0) > 0)
                                    AmountWidget(
                                      title: getTranslated('referral_discount', context),
                                      amount: PriceConverter.convertPrice(context, _referralDiscount),
                                    ),
                                  Divider(height: 5, color: Theme.of(context).hintColor),
                                  AmountWidget(
                                    title: getTranslated('total_payable', context),
                                    amount: PriceConverter.convertPrice(
                                      context,
                                      (_order +
                                          widget.shippingFee -
                                          (_referralDiscount ?? 0) -
                                          widget.discount -
                                          _couponDiscount! +
                                          widget.tax),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeDefault,
                              0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${getTranslated('order_note', context)}',
                                    style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              CustomTextFieldWidget(
                                hintText: getTranslated('enter_note', context),
                                inputType: TextInputType.multiline,
                                inputAction: TextInputAction.done,
                                maxLines: 3,
                                focusNode: _orderNoteNode,
                                controller: orderProvider.orderNoteController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }

  void _callback(bool isSuccess, String message, String orderID, bool createAccount) async {
    if(isSuccess) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashBoardScreen()), (route) => false);
        showAnimatedDialog(context, OrderPlaceDialogWidget(
          icon: Icons.check,
          title: getTranslated(createAccount ? 'order_placed_Account_Created' : 'order_placed', context),
          description: getTranslated('your_order_placed', context),
          isFailed: false,
        ), dismissible: false, willFlip: true);
    }else {
      showCustomSnackBar(message, context, isToaster: true);
    }
  }
}

