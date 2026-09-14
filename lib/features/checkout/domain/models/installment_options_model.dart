class InstallmentOptionsModel {
  List<InstallmentOption>? installmentOptions;
  double? cartTotal;
  String? cartTotalFormatted;

  InstallmentOptionsModel({
    this.installmentOptions,
    this.cartTotal,
    this.cartTotalFormatted,
  });

  InstallmentOptionsModel.fromJson(Map<String, dynamic> json) {
    if (json['installment_options'] != null) {
      installmentOptions = <InstallmentOption>[];
      json['installment_options'].forEach((v) {
        installmentOptions!.add(InstallmentOption.fromJson(v));
      });
    }
    cartTotal = json['cart_total']?.toDouble();
    cartTotalFormatted = json['cart_total_formatted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (installmentOptions != null) {
      data['installment_options'] = installmentOptions!.map((v) => v.toJson()).toList();
    }
    data['cart_total'] = cartTotal;
    data['cart_total_formatted'] = cartTotalFormatted;
    return data;
  }
}

class InstallmentOption {
  int? period;
  String? periodText;
  double? installmentValue;
  String? installmentValueFormatted;
  double? totalAmount;
  String? totalAmountFormatted;
  String? description;

  InstallmentOption({
    this.period,
    this.periodText,
    this.installmentValue,
    this.installmentValueFormatted,
    this.totalAmount,
    this.totalAmountFormatted,
    this.description,
  });

  InstallmentOption.fromJson(Map<String, dynamic> json) {
    period = json['period'];
    periodText = json['period_text'];
    installmentValue = json['installment_value']?.toDouble();
    installmentValueFormatted = json['installment_value_formatted'];
    totalAmount = json['total_amount']?.toDouble();
    totalAmountFormatted = json['total_amount_formatted'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['period'] = period;
    data['period_text'] = periodText;
    data['installment_value'] = installmentValue;
    data['installment_value_formatted'] = installmentValueFormatted;
    data['total_amount'] = totalAmount;
    data['total_amount_formatted'] = totalAmountFormatted;
    data['description'] = description;
    return data;
  }
}