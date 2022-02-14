import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  final ScrollController _firstControl = ScrollController();
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded ? widget.order.products.length * 60.0 + 100 : 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat('E dd, MMM yyy').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon:
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _expanded ? widget.order.products.length * 60.0 : 0,
              // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                child: Scrollbar(
                  isAlwaysShown: false,
                  controller: _firstControl,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var prod = widget.order.products[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          prod.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${prod.quantity}x \$${prod.price}',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    },
                    itemCount: widget.order.products.length,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
