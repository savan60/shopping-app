import 'package:flutter/material.dart';
import 'package:fourth/widget/app_drawer.dart';
import '../provider/order.dart';
import 'package:provider/provider.dart';
import '../widget/orderItem.dart';

class OrderScreen extends StatelessWidget {
  static const String routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Order>(context, listen: false).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('Some error occured!!'),
              );
            } else {
              return Consumer<Order>(builder: (ctx, orderdata, child) {
                return ListView.builder(
                  itemBuilder: (ctx, i) {
                    return OrderItems(orderdata.orders[i]);
                  },
                  itemCount: orderdata.orders.length,
                );
              });
            }
          }
        },
      ),
    );
  }
}
