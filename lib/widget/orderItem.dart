import 'package:flutter/material.dart';
import 'package:fourth/provider/order.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderItems extends StatefulWidget {
  final OrderItem order;

  OrderItems(this.order);

  @override
  _OrderItemsState createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  var _showmore = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(microseconds: 300),
      height:
          _showmore ? min(widget.order.products.length * 20 + 140.0, 400) : 120,
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.total.toStringAsFixed(2)}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(widget.order.date),
            ),
            trailing: IconButton(
              icon: Icon(_showmore ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showmore = !_showmore;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _showmore
                ? min(widget.order.products.length * 20 + 10.0, 100)
                : 0,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: ListView(
              children: widget.order.products
                  .map(
                    (pr) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          pr.title,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${pr.quantity}x \$${pr.price}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
