import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

class FiltersSection extends ConsumerWidget {
  final String? typeFilter;
  final String? payFilter;

  const FiltersSection({
    super.key,
    required this.typeFilter,
    required this.payFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // --- Order Type Dropdown ---
        DropdownButtonHideUnderline(
          child: GFDropdown(
            value: typeFilter,
            hint: const Text('Order Type'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(12),
            border: const BorderSide(color: Colors.black26, width: 1),
            dropdownButtonColor: Colors.white,
            items: const [
              DropdownMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 18, color: clrMainAppClr),
                    SizedBox(width: 8),
                    Text('All types'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'dinein',
                child: Row(
                  children: [
                    Icon(Icons.restaurant, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Dine-in'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'takeaway',
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Takeaway'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'delivery',
                child: Row(
                  children: [
                    Icon(Icons.delivery_dining, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Delivery'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(ordersAsyncProvider.notifier).setType(value);
            },
          ),
        ),
        const SizedBox(width: 12),

        // --- Payment Type Dropdown ---
        DropdownButtonHideUnderline(
          child: GFDropdown(
            value: payFilter,
            hint: const Text('Payment Type'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(12),
            border: const BorderSide(color: Colors.black26, width: 1),
            dropdownButtonColor: Colors.white,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 18, color: clrMainAppClr),
                    SizedBox(width: 8),
                    Text('All payments'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: PaymentMethod.cashPayment.name,
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    TxtWidget(txt: "Cash"),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: PaymentMethod.mobileBanking.name,
                child: Row(
                  children: [
                    Icon(Icons.phone_android, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    TxtWidget(txt: "Mobile Banking"),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(ordersAsyncProvider.notifier).setPayment(value);
            },
          ),
        ),
      ],
    );
  }
}
