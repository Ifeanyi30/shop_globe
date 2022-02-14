import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;

  final double price;
  final int quantity;
  final String title;

  CartItem(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final _itemKey = ValueKey(id);
    return Dismissible(
      onDismissed: (direction) {
        cart.removeItem(id);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content:
                const Text('Do you want to remove the item from the cart?'),
            contentPadding: const EdgeInsets.all(20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes'),
              )
            ],
          ),
        );
      },
      direction: DismissDirection.endToStart,
      key: _itemKey,
      background: Container(
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${_roundDouble((price * quantity), 2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }

  double _roundDouble(double value, int places) {
    int mod = 10 ^ places;
    return ((value * mod).round().toDouble() / mod);
  }
}
