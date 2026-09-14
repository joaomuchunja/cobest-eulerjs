import 'package:flutter/material.dart';
import 'package:cobes_marketplace/features/order_details/domain/models/installment_model.dart';
import 'package:cobes_marketplace/features/order_details/widgets/submit_payment_proof_dialog.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';

class OrderInstallmentWidget extends StatelessWidget {
  final OrderInstallmentDetailsModel? installmentDetails;

  const OrderInstallmentWidget({
    super.key,
    required this.installmentDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (installmentDetails == null || 
        installmentDetails!.installmentSchedule == null || 
        installmentDetails!.installmentSchedule!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Icon(
                Icons.payment,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                getTranslated('installment_details', context) ?? 'Installment Details',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Informações gerais do parcelamento
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  '${getTranslated('payment_method', context) ?? 'Payment Method'}:',
                  _formatPaymentMethod(context, installmentDetails!.paymentMethod),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                _buildInfoRow(
                  context,
                  '${getTranslated('number_of_installments', context) ?? 'Number of Installments'}:',
                  '${installmentDetails!.paymentPeriod}x',
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                _buildInfoRow(
                  context,
                  '${getTranslated('installment_value', context) ?? 'Installment Value'}:',
                  ' ${installmentDetails!.installmentValue?.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Lista de parcelas
          Text(
            '${getTranslated('payment_schedule', context) ?? 'Payment Schedule'}:',
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ...installmentDetails!.installmentSchedule!.map((installment) => 
            _buildInstallmentCard(context, installment)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: titilliumSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentModel installment) {
    Color statusColor = _getStatusColor(context, installment.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Número da parcela
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${installment.installmentNumber}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Informações da parcela
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' ${installment.amountFormatted}',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        installment.statusText ?? '',
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${getTranslated('due_date', context) ?? 'Due Date'}: ${installment.dueDateFormatted}',
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                // Botão para enviar comprovativo se status for pending
                if (installment.status?.toLowerCase() == 'pending') ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSubmitProofDialog(context, installment),
                      icon: const Icon(Icons.receipt, size: 16),
                      label: Text(getTranslated('send_payment_proof', context) ?? 'Send Payment Proof'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        textStyle: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitProofDialog(BuildContext context, InstallmentModel installment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SubmitPaymentProofDialog(installment: installment);
      },
    );
  }

  String _formatPaymentMethod(BuildContext context, String? method) {
    switch (method?.toLowerCase()) {
      case 'pagamento_a_prazo':
        return getTranslated('payment_a_prazo', context) ?? 'Term Payment';
      case 'credit_card':
        return getTranslated('credit_card', context) ?? 'Credit Card';
      case 'debit_card':
        return getTranslated('debit_card', context) ?? 'Debit Card';
      default:
        return method ?? 'N/A';
    }
  }

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}