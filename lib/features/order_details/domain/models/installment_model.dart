class InstallmentModel {
  final int? id;
  final int? installmentNumber;
  final double? amount;
  final String? amountFormatted;
  final String? dueDate;
  final String? dueDateFormatted;
  final String? status;
  final String? statusLabel;
  final bool? isOverdue;
  final String? paymentProof;
  final bool? canSubmitProof;

  InstallmentModel({
    this.id,
    this.installmentNumber,
    this.amount,
    this.amountFormatted,
    this.dueDate,
    this.dueDateFormatted,
    this.status,
    this.statusLabel,
    this.isOverdue,
    this.paymentProof,
    this.canSubmitProof,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      installmentNumber: json['installment_number'],
      amount: _parseDouble(json['amount']),
      amountFormatted: json['amount_formatted'],
      dueDate: json['due_date'],
      dueDateFormatted: json['due_date_formatted'],
      status: json['status'],
      statusLabel: json['status_label'],
      isOverdue: json['is_overdue'],
      paymentProof: json['payment_proof'],
      canSubmitProof: json['can_submit_proof'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'installment_number': installmentNumber,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'due_date': dueDate,
      'due_date_formatted': dueDateFormatted,
      'status': status,
      'status_label': statusLabel,
      'is_overdue': isOverdue,
      'payment_proof': paymentProof,
      'can_submit_proof': canSubmitProof,
    };
  }

  // Getter de compatibilidade para não quebrar o código existente
  String? get statusText => statusLabel;
}

class PaymentInstallmentsSummary {
  final int? totalCount;
  final int? paidCount;
  final int? pendingCount;
  final int? overdueCount;
  final double? totalAmount;
  final String? totalAmountFormatted;
  final double? paidAmount;
  final String? paidAmountFormatted;
  final double? pendingAmount;
  final String? pendingAmountFormatted;

  PaymentInstallmentsSummary({
    this.totalCount,
    this.paidCount,
    this.pendingCount,
    this.overdueCount,
    this.totalAmount,
    this.totalAmountFormatted,
    this.paidAmount,
    this.paidAmountFormatted,
    this.pendingAmount,
    this.pendingAmountFormatted,
  });

  factory PaymentInstallmentsSummary.fromJson(Map<String, dynamic> json) {
    return PaymentInstallmentsSummary(
      totalCount: json['total_count'],
      paidCount: json['paid_count'],
      pendingCount: json['pending_count'],
      overdueCount: json['overdue_count'],
      totalAmount: PaymentInstallmentsSummary._parseDouble(json['total_amount']),
      totalAmountFormatted: json['total_amount_formatted'],
      paidAmount: PaymentInstallmentsSummary._parseDouble(json['paid_amount']),
      paidAmountFormatted: json['paid_amount_formatted'],
      pendingAmount: PaymentInstallmentsSummary._parseDouble(json['pending_amount']),
      pendingAmountFormatted: json['pending_amount_formatted'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'paid_count': paidCount,
      'pending_count': pendingCount,
      'overdue_count': overdueCount,
      'total_amount': totalAmount,
      'total_amount_formatted': totalAmountFormatted,
      'paid_amount': paidAmount,
      'paid_amount_formatted': paidAmountFormatted,
      'pending_amount': pendingAmount,
      'pending_amount_formatted': pendingAmountFormatted,
    };
  }
}

class OrderInstallmentDetailsModel {
  final int? orderId;
  final String? orderStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final double? orderAmount;
  final String? orderAmountFormatted;
  final List<InstallmentModel>? installments;
  final PaymentInstallmentsSummary? summary;

  OrderInstallmentDetailsModel({
    this.orderId,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.orderAmount,
    this.orderAmountFormatted,
    this.installments,
    this.summary,
  });

  factory OrderInstallmentDetailsModel.fromJson(Map<String, dynamic> json) {
    var orderData = json['order'] ?? {};
    var paymentInstallments = json['payment_installments'] ?? {};
    var installmentsList = paymentInstallments['installments'] as List?;
    
    return OrderInstallmentDetailsModel(
      orderId: orderData['id'],
      orderStatus: orderData['order_status'],
      paymentStatus: orderData['payment_status'],
      paymentMethod: orderData['payment_method'],
      orderAmount: OrderInstallmentDetailsModel._parseDouble(orderData['order_amount']),
      orderAmountFormatted: orderData['order_amount_formatted'],
      installments: installmentsList?.map((item) => InstallmentModel.fromJson(item)).toList(),
      summary: paymentInstallments['summary'] != null 
          ? PaymentInstallmentsSummary.fromJson(paymentInstallments['summary'])
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'order_amount': orderAmount,
      'order_amount_formatted': orderAmountFormatted,
      'installments': installments?.map((item) => item.toJson()).toList(),
      'summary': summary?.toJson(),
    };
  }

  // Getters de compatibilidade para não quebrar o código existente
  List<InstallmentModel>? get installmentSchedule => installments;
  int? get paymentPeriod => installments?.length;
  double? get installmentValue => installments?.isNotEmpty == true ? installments!.first.amount : null;
}

class SubmitPaymentProofModel {
  final int installmentId;
  final String proofImage;
  final String customerNote;

  SubmitPaymentProofModel({
    required this.installmentId,
    required this.proofImage,
    required this.customerNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'installment_id': installmentId,
      'proof_image': proofImage,
      'customer_note': customerNote,
    };
  }
}