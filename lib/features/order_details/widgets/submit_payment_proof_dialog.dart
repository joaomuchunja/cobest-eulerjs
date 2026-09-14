import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cobes_marketplace/features/order_details/controllers/order_details_controller.dart';
import 'package:cobes_marketplace/features/order_details/domain/models/installment_model.dart';
import 'package:cobes_marketplace/utill/custom_themes.dart';
import 'package:cobes_marketplace/utill/dimensions.dart';
import 'package:cobes_marketplace/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class SubmitPaymentProofDialog extends StatefulWidget {
  final InstallmentModel installment;

  const SubmitPaymentProofDialog({
    Key? key,
    required this.installment,
  }) : super(key: key);

  @override
  State<SubmitPaymentProofDialog> createState() => _SubmitPaymentProofDialogState();
}

class _SubmitPaymentProofDialogState extends State<SubmitPaymentProofDialog> {
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 1200,
        maxWidth: 1200,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getTranslated('error_selecting_image', context) ?? 'Error selecting image'}: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 1200,
        maxWidth: 1200,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getTranslated('error_taking_photo', context) ?? 'Error taking photo'}: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslated('select_image', context) ?? 'Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(getTranslated('take_photo', context) ?? 'Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(getTranslated('choose_from_gallery', context) ?? 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitProof() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getTranslated('please_select_image', context) ?? 'Please select a payment proof image')),
      );
      return;
    }

    // Debug: Vamos verificar se o ID existe
    print('=== DEBUG SUBMIT PROOF ===');
    print('Installment ID: ${widget.installment.id}');
    print('Installment Number: ${widget.installment.installmentNumber}');
    print('Installment Status: ${widget.installment.status}');
    print('========================');

    // Usar o ID se existir, senão usar o número da parcela como fallback
    int installmentId;
    if (widget.installment.id != null) {
      installmentId = widget.installment.id!;
    } else if (widget.installment.installmentNumber != null) {
      // Fallback: usar o número da parcela
      installmentId = widget.installment.installmentNumber!;
      print('AVISO: Usando installment_number como ID fallback: $installmentId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getTranslated('installment_id_not_found', context) ?? 'Installment ID not found')),
      );
      return;
    }

    final orderDetailsController = Provider.of<OrderDetailsController>(context, listen: false);
    
    await orderDetailsController.submitInstallmentPaymentProof(
      installmentId: installmentId,
      imagePath: _selectedImage!.path,
      customerNote: _noteController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    getTranslated('submit_payment_proof', context) ?? 'Submit Payment Proof',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Informações da parcela
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.installment.installmentNumber}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getTranslated('installment', context) ?? 'Installment'} ${widget.installment.installmentNumber}',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          ' ${widget.installment.amountFormatted}',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${getTranslated('due_date', context) ?? 'Due Date'}: ${widget.installment.dueDateFormatted}',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Seleção de imagem
            Text(
              '${getTranslated('payment_proof', context) ?? 'Payment Proof'}:',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            getTranslated('tap_to_add_image', context) ?? 'Tap to add image',
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Nota do cliente
            Text(
              '${getTranslated('note_about_payment', context) ?? 'Note about payment'} (${getTranslated('optional', context) ?? 'Optional'}):',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '${getTranslated('payment_proof_placeholder', context) ?? 'Ex: Payment made via bank transfer on'} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(getTranslated('cancel', context) ?? 'Cancel'),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Consumer<OrderDetailsController>(
                    builder: (context, controller, _) {
                      return ElevatedButton(
                        onPressed: controller.isSubmittingProof ? null : _submitProof,
                        child: controller.isSubmittingProof
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(getTranslated('send', context) ?? 'Send'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}