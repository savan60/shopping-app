import 'dart:convert';

import 'package:flutter/cupertino.dart';
import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final DateTime date;
  final List<CartItem> products;
  final double total;

  OrderItem(
      {@required this.id,
      @required this.date,
      @required this.products,
      @required this.total});
}


class  Order with ChangeNotifier {
  final String token;
  List<OrderItem> _orders = [];
  String user_id;
  Order(this.token,this._orders,this.user_id);
 

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = 'https://shopapp1-b7199.firebaseio.com/order/$user_id.json?auth=$token';
    // try {
      final response = await http.get(url);
      final extractdata = json.decode(response.body) as Map<String, dynamic>;
      if(extractdata==null){
        return ;
      }
      final List<OrderItem> loadedOrders = [];
      extractdata.forEach((key, value) {
         loadedOrders.add( OrderItem(
            id: key,
            date: DateTime.parse(value['date']) ,
            total: value['amount'],
            products: (value['products'] as List<dynamic>).map((item) {
              return CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']);
            }).toList()));
      });
      print(json.decode(response.body));
      _orders = loadedOrders.reversed.toList();
      print(_orders);
      notifyListeners();
    // } catch (error) {
    //   throw error;
    // }

  }

  Future<void> addOrder(
    List<CartItem> cartProducts,
    double total,
  ) async {
    final url = 'https://shopapp1-b7199.firebaseio.com/order/$user_id.json?auth=$token';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'date': timestamp.toIso8601String(),
          'amount': total,
          'products': cartProducts.map((cp) {
            return {
              'id': cp.id,
              'price': cp.price,
              'quantity': cp.quantity,
              'title': cp.title
            };
          }).toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        date: DateTime.now(),
        products: cartProducts,
        total: total,
      ),
    );
    notifyListeners();
  }
}
