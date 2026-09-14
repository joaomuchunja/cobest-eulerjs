import 'package:provider/provider.dart';



// ...existing code...
// ...existing code...

import 'package:cobes_marketplace/data/model/api_response.dart';
import 'package:cobes_marketplace/features/auth/controllers/auth_controller.dart';
import 'package:cobes_marketplace/features/cart/domain/models/cart_model.dart';
import 'package:cobes_marketplace/features/checkout/domain/models/installment_options_model.dart';
import 'package:cobes_marketplace/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:cobes_marketplace/features/checkout/domain/services/mpesa_payment_service.dart';
import 'package:cobes_marketplace/features/checkout/domain/services/ponto24_payment_service.dart';
import 'package:cobes_marketplace/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:cobes_marketplace/features/splash/controllers/splash_controller.dart';
import 'package:cobes_marketplace/helper/api_checker.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:cobes_marketplace/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cobes_marketplace/common/basewidget/show_custom_snakbar_widget.dart';

import 'package:cobes_marketplace/features/checkout/screens/digital_payment_order_place_screen.dart';




class CheckoutController with ChangeNotifier {
  // Ponto24 payment method
  Future<ApiResponseModel> placeOrderByPonto24({
    required String addressId,
    required String billingAddressId,
    String? couponCode,
    double? couponDiscount,
    String? orderNote,
    String? guestId,
  }) async {
    _isLoading = true;
    notifyListeners();
    final ponto24Service = Ponto24PaymentService(checkoutService: checkoutServiceInterface);
    final response = await ponto24Service.placeOrderByPonto24(
      addressId: addressId,
      billingAddressId: billingAddressId,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
      orderNote: orderNote,
      guestId: guestId,
    );
    _isLoading = false;
    notifyListeners();
    return response;
  }
  // M-Pesa payment method
  Future<ApiResponseModel> placeOrderByMpesa({
    required String mpesaPhoneNumber,
    required String addressId,
    required String billingAddressId,
    String? couponCode,
    double? couponDiscount,
    String? orderNote,
    String? guestId,
    double? bringChangeAmount,
  }) async {
    _isLoading = true;
    notifyListeners();
    final mpesaService = MpesaPaymentService(checkoutService: checkoutServiceInterface);
    final response = await mpesaService.placeOrderByMpesa(
      mpesaPhoneNumber: mpesaPhoneNumber,
      addressId: addressId,
      billingAddressId: billingAddressId,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
      orderNote: orderNote,
      guestId: guestId,
      bringChangeAmount: bringChangeAmount,
    );
    _isLoading = false;
    notifyListeners();
    if (response.response != null && response.response!.statusCode == 200) {
      // Success: handle navigation or state update as needed
      showCustomSnackBar('Pagamento M-Pesa iniciado com sucesso!', Get.context!, isError: false);
    } else {
      showCustomSnackBar('Erro ao processar pagamento M-Pesa.', Get.context!);
    }
    return response;
  }
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? _shippingIndex;
  bool _isLoading = false;
  bool _isLoadingInstallmentOptions = false;
  bool _isCheckCreateAccount = false;
  bool _newUser = false;

  int _paymentMethodIndex = -1;
  bool _onlyDigital = true;
  bool get onlyDigital => _onlyDigital;
  int? get addressIndex => _addressIndex;
  int? get shippingIndex => _shippingIndex;
  bool get isLoading => _isLoading;
  bool get isLoadingInstallmentOptions => _isLoadingInstallmentOptions;
  int get paymentMethodIndex => _paymentMethodIndex;
  bool get isCheckCreateAccount => _isCheckCreateAccount;

  bool _changeAmountShow = false;
  bool get changeAmountShow => _changeAmountShow;

  double? _cashChangesAmount;
  double? get cashChangesAmount => _cashChangesAmount;

  ReferralAmount? _referralAmount;
  ReferralAmount? get referralAmount => _referralAmount;

  // Installment payment properties
  InstallmentOptionsModel? _installmentOptions;
  InstallmentOptionsModel? get installmentOptions => _installmentOptions;

  InstallmentOption? _selectedInstallmentOption;
  InstallmentOption? get selectedInstallmentOption => _selectedInstallmentOption;

  String selectedPaymentName = '';
  void setSelectedPayment(String payment){
    selectedPaymentName = payment;
    notifyListeners();
  }

  bool _isAcceptTerms = false;
  bool get isAcceptTerms => _isAcceptTerms;


  final TextEditingController orderNoteController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  List<String> inputValueList = [];



  Future<void> placeOrder({required Function callback, String? addressID,
        String? couponCode, String? couponAmount,
        String? billingAddressId, String? orderNote, String? transactionId,
        String? paymentNote, int? id, String? name,bool isfOffline = false, bool wallet = false}) async {
    for(TextEditingController textEditingController in inputFieldControllerList) {
      inputValueList.add(textEditingController.text.trim());

    }

    _isLoading = true;
    _newUser = false;
    notifyListeners();
    ApiResponseModel apiResponse;
    isfOffline?
    apiResponse = await checkoutServiceInterface.offlinePaymentPlaceOrder(addressID, couponCode, couponAmount, billingAddressId, orderNote, keyList, inputValueList, offlineMethodSelectedId, offlineMethodSelectedName, paymentNote, _isCheckCreateAccount, passwordController.text.trim()):
    wallet?
    apiResponse = await checkoutServiceInterface.walletPaymentPlaceOrder(addressID, couponCode, couponAmount, billingAddressId, orderNote, _isCheckCreateAccount, passwordController.text.trim()):

    apiResponse = await checkoutServiceInterface.cashOnDeliveryPlaceOrder(
      addressID: addressID,
      couponCode: couponCode,
      couponDiscountAmount: couponAmount,
      billingAddressId: billingAddressId,
      orderNote: orderNote,
      isCheckCreateAccount: _isCheckCreateAccount,
      password: passwordController.text.trim(),
      cashChangeAmount: _cashChangesAmount,
      currentCurrencyCode: Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      _isCheckCreateAccount = false;
      _isLoading = false;
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      if(!Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()){
        _newUser = apiResponse.response!.data['new_user'];
      }

      String message = apiResponse.response!.data.toString();
      callback(true, message, '', _newUser);
    } else {
      _isLoading = false;
     ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void setAddressIndex(int index) {
    _addressIndex = index;
    notifyListeners();
  }
  void setBillingAddressIndex(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  void resetPaymentMethod(){
    _paymentMethodIndex = -1;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
  }


  void shippingAddressNull(){
    _addressIndex = null;
    notifyListeners();
  }

  void billingAddressNull(){
    _billingAddressIndex = null;
    notifyListeners();
  }

  void setSelectedShippingAddress(int index) {
    _shippingIndex = index;
    notifyListeners();
  }
  void setSelectedBillingAddress(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  bool isOfflineChecked = false;
  bool isCODChecked = false;
  bool isWalletChecked = false;

  void setOfflineChecked(String type){
    if(type == 'offline'){
      isOfflineChecked = !isOfflineChecked;
      isCODChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
      setOfflinePaymentMethodSelectedIndex(0);
    }else if(type == 'cod'){
      isCODChecked = !isCODChecked;
      isOfflineChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
    }else if(type == 'wallet'){
      isWalletChecked = !isWalletChecked;
      isOfflineChecked = false;
      isCODChecked = false;
      _paymentMethodIndex = -1;
    }

    notifyListeners();
  }



  String selectedDigitalPaymentMethodName = '';

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    selectedDigitalPaymentMethodName = name;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
    notifyListeners();
  }


  void digitalOnly(bool value, {bool isUpdate = false}){
    _onlyDigital = value;
    if(isUpdate){
      notifyListeners();
    }

  }



  OfflinePaymentModel? offlinePaymentModel;
  Future<ApiResponseModel> getOfflinePaymentList() async {
    ApiResponseModel apiResponse = await checkoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      offlineMethodSelectedIndex = 0;
      offlinePaymentModel = OfflinePaymentModel.fromJson(apiResponse.response?.data);
    }
    else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  List<TextEditingController> inputFieldControllerList = [];
  List <String?> keyList = [];
  int offlineMethodSelectedIndex = -1;
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}){
    keyList = [];
    inputFieldControllerList = [];
    offlineMethodSelectedIndex = index;
    if(offlinePaymentModel != null && offlinePaymentModel!.offlineMethods!= null && offlinePaymentModel!.offlineMethods!.isNotEmpty){
      offlineMethodSelectedId = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].methodName!;
    }

    if(offlinePaymentModel!.offlineMethods != null && offlinePaymentModel!.offlineMethods!.isNotEmpty && offlinePaymentModel!.offlineMethods![index].methodInformations!.isNotEmpty){
      for(int i= 0; i< offlinePaymentModel!.offlineMethods![index].methodInformations!.length; i++){
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!.offlineMethods![index].methodInformations![i].customerInput);
      }
    }
    if(notify){
      notifyListeners();
    }

  }

  Future<ApiResponseModel> digitalPaymentPlaceOrder({String? orderNote, String? customerId,
    String? addressId, String? billingAddressId,
    String? couponCode,
    String? couponDiscount,
    String? paymentMethod}) async {
    _isLoading =true;
    notifyListeners();

    ApiResponseModel apiResponse = await checkoutServiceInterface.digitalPaymentPlaceOrder(orderNote, customerId, addressId, billingAddressId, couponCode, couponDiscount, paymentMethod, _isCheckCreateAccount, passwordController.text.trim());

    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      _isLoading = false;
      Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) => DigitalPaymentScreen(url: apiResponse.response?.data['redirect_link'])));

    } else if(apiResponse.error == 'Already registered '){
      _isLoading = false;
      showCustomSnackBar('${getTranslated(apiResponse.error, Get.context!)}', Get.context!);
    } else if(apiResponse.response != null && apiResponse.response!.statusCode == 403){
      _isLoading = false;
      showCustomSnackBar('${getTranslated(apiResponse.error, Get.context!)}', Get.context!);
    } else {
      _isLoading = false;
      showCustomSnackBar('${getTranslated('payment_method_not_properly_configured', Get.context!)}', Get.context!);
    }
    notifyListeners();
    return apiResponse;
  }

  bool sameAsBilling = false;
  void setSameAsBilling(){
    sameAsBilling = !sameAsBilling;
    notifyListeners();
  }

  void clearData(){
    orderNoteController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isCheckCreateAccount = false;
    _cashChangesAmount = null;
    clearInstallmentData();
  }


  void setIsCheckCreateAccount(bool isCheck, {bool update = true}) {
    _isCheckCreateAccount = isCheck;
    if(update) {
      notifyListeners();
    }
  }



  void toggleChangeAmountShow(){
    _changeAmountShow = !_changeAmountShow;
    notifyListeners();
  }

  void onChangeCashChangesAmount(double? amount)=> _cashChangesAmount = amount;


  Future<ApiResponseModel> getReferralAmount(String? amount) async {
    ApiResponseModel apiResponse = await checkoutServiceInterface.getReferralAmount(amount);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _referralAmount = ReferralAmount.fromJson(apiResponse.response.data);
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  Future<ApiResponseModel> getInstallmentOptions({double? couponDiscount}) async {
    print('===== INICIANDO CHAMADA PARA API DE OPÇÕES DE PARCELAMENTO =====');
    print('couponDiscount: $couponDiscount');
    
    _isLoadingInstallmentOptions = true;
    notifyListeners();
    
    ApiResponseModel apiResponse = await checkoutServiceInterface.getInstallmentOptions(couponDiscount: couponDiscount);
    
    _isLoadingInstallmentOptions = false;
    
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print('===== RESPOSTA DA API DE PARCELAMENTO (SUCESSO) =====');
      print('Status Code: ${apiResponse.response!.statusCode}');
      print('Response Data: ${apiResponse.response!.data}');
      
      // Parse and store the installment options
      _installmentOptions = InstallmentOptionsModel.fromJson(apiResponse.response!.data);
    } else {
      print('===== RESPOSTA DA API DE PARCELAMENTO (ERRO) =====');
      print('Error: ${apiResponse}');
      print('Error: ${apiResponse.error}');
      ApiChecker.checkApi(apiResponse);
    }
    
    notifyListeners();
    return apiResponse;
  }

  Future<ApiResponseModel> placeOrderByInstallment({
    required int paymentPeriod,
    String? addressId,
    String? billingAddressId,
    String? couponCode,
    String? orderNote,
  }) async {
    print('===== INICIANDO FINALIZAÇÃO DO PEDIDO A PRAZO =====');
    print('Payment Period: $paymentPeriod');
    print('Address ID: $addressId');
    print('Billing Address ID: $billingAddressId');
    
    _isLoading = true;
    notifyListeners();
    
    ApiResponseModel apiResponse = await checkoutServiceInterface.placeOrderByInstallment(
      paymentPeriod: paymentPeriod,
      addressId: addressId,
      billingAddressId: billingAddressId,
      couponCode: couponCode,
      orderNote: orderNote,
      paymentNote: 'Pagamento a prazo em $paymentPeriod parcelas',
      currentCurrencyCode: Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code ?? 'MZN',
      isCheckCreateAccount: _isCheckCreateAccount,
      guestId: Provider.of<AuthController>(Get.context!, listen: false).getGuestToken(),
    );
    
    _isLoading = false;
    
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print('===== PEDIDO A PRAZO FINALIZADO COM SUCESSO =====');
      print('Status Code: ${apiResponse.response!.statusCode}');
      print('Response Data: ${apiResponse.response!.data}');
      
      // Limpar dados após sucesso
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      
      showCustomSnackBar('Pedido criado com sucesso!', Get.context!, isError: false);
    } else {
      print('===== ERRO AO FINALIZAR PEDIDO A PRAZO =====');
      print('Error: ${apiResponse.error}');
      showCustomSnackBar('Erro ao processar pedido. Tente novamente.', Get.context!);
      ApiChecker.checkApi(apiResponse);
    }
    
    notifyListeners();
    return apiResponse;
  }

  void setSelectedInstallmentOption(InstallmentOption option) {
    _selectedInstallmentOption = option;
    notifyListeners();
  }

  void clearInstallmentData() {
    _installmentOptions = null;
    _selectedInstallmentOption = null;
    notifyListeners();
  }


  void toggleTermsCheck({bool isUpdate = true}) {
    _isAcceptTerms = !_isAcceptTerms;
    if(isUpdate) {
      notifyListeners();
    }
  }

}
