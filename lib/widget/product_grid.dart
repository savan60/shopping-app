import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';
import '../provider/products.dart';

class ProductGrid extends StatelessWidget {

  final bool favitems;

  ProductGrid(this.favitems);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final loadProducts = favitems ? productData.favItems : productData.items;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadProducts[i],
        child: ProductItem(),
      ),
      itemCount: loadProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
    );
  }
}
