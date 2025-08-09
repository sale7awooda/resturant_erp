import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';

class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);
    final count = ref.watch(cartCountProvider);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          //   onTap: () => showModalBottomSheet(
          //     context: context,
          //     isScrollControlled: true,
          //     builder: (_) => const CartScreen(),

          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 12),
                Text('$count item(s)'),
                const Spacer(),
                Text('Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: () {
                      // proceed to checkout -> example
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Proceed to checkout (not implemented)')));
                    },
                    child: const Text('Checkout')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
