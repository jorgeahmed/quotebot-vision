import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  final Function(PaymentMethod) onPay;

  const PaymentDialog({
    super.key,
    required this.amount,
    required this.onPay,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Process Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Amount: \$${widget.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          const Text('Select Payment Method:'),
          RadioListTile<PaymentMethod>(
            title: const Text('Credit Card'),
            value: PaymentMethod.creditCard,
            groupValue: _selectedMethod,
            onChanged: (value) => setState(() => _selectedMethod = value!),
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Cash'),
            value: PaymentMethod.cash,
            groupValue: _selectedMethod,
            onChanged: (value) => setState(() => _selectedMethod = value!),
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Bank Transfer'),
            value: PaymentMethod.transfer,
            groupValue: _selectedMethod,
            onChanged: (value) => setState(() => _selectedMethod = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onPay(_selectedMethod);
            Navigator.of(context).pop();
          },
          child: const Text('Pay Now'),
        ),
      ],
    );
  }
}
