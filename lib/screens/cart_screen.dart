import 'package:flutter/material.dart';
import 'package:fourth/provider/order.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart' show Cart;
import '../widget/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const String routename = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final orderdata = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 10,),
                  OrderNowBtn(cart: cart, orderdata: orderdata),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                return CartItems(
                    cart.items.values.toList()[i].id,
                    cart.items.keys.toList()[i],
                    cart.items.values.toList()[i].title,
                    cart.items.values.toList()[i].quantity,
                    cart.items.values.toList()[i].price);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderNowBtn extends StatefulWidget {
  const OrderNowBtn({
    Key key,
    @required this.cart,
    @required this.orderdata,
  }) : super(key: key);

  final Cart cart;
  final Order orderdata;

  @override
  _OrderNowBtnState createState() => _OrderNowBtnState();
}

class _OrderNowBtnState extends State<OrderNowBtn> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : FlatButton(
            child: Text(
              'Order Now',
              style: widget.cart.totalAmount > 0
                  ? TextStyle(
                      color: Theme.of(context).primaryColor,
                    )
                  : TextStyle(color: Colors.grey),
            ),
            onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await widget.orderdata.addOrder(
                        widget.cart.items.values.toList(),
                        widget.cart.totalAmount);
                    widget.cart.clear();
                    setState(() {
                      _isLoading = false;
                    });
                  },
          );
  }
}
