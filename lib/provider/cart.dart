import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {

    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var _total = 0.0;
    _items.forEach((key, f) {
      _total += f.price * f.quantity;
    });
    return _total;
  }

  Future<void> additem(
    String prodId,
    double price,
    String title,
  ) async {
    if (_items.containsKey(prodId)) {
      _items.update(
        prodId,
        (earlier) => CartItem(
          id: earlier.id,
          price: earlier.price,
          title: earlier.title,
          quantity: earlier.quantity + 1,
        ),
      );
    } else {
      // const url = 'https://shopapp1-b7199.firebaseio.com/cart.json';
      // try {
      //   await http.post(url,
      //       body: json.encode({
      //         'id': prodId,
      //         'title': title,
      //         'price': price,
      //         'quantity': 1,
      //       }));
        _items.putIfAbsent(
          prodId,
          () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price,
          ),
        );
      // } catch (error) {
      //   throw error;
      // }
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (!_items.containsKey(prodId)) {
      return;
    }
    if (_items[prodId].quantity > 1) {
      _items.update(
        prodId,
        (exiting) => CartItem(
          id: exiting.id,
          price: exiting.price,
          title: exiting.title,
          quantity: exiting.quantity - 1,
        ),
      );
    } else {
      _items.remove(prodId);
    }
    notifyListeners();
  }

  void removeItem(String prodId) {
    _items.remove(prodId);
    notifyListeners();
  }
}
