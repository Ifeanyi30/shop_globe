import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/orders.dart' show Order;
import 'package:shop_globe/widgets/app_drawer.dart';
import 'package:shop_globe/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Order>(context, listen: false).fetchOrders();
  }

  Future<void> _refreshOrdersFuture() async {
    return await Provider.of<Order>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return RefreshIndicator(
                onRefresh: _refreshOrdersFuture,
                child: const Center(
                  child: Text('An error Occurred'),
                ),
              );
            } else {
              return Consumer<Order>(
                builder: (ctx, orderData, child) => RefreshIndicator(
                  onRefresh: _obtainOrdersFuture,
                  child: ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (cxt, index) =>
                        OrderItem(orderData.orders[index]),
                  ),
                ),
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
