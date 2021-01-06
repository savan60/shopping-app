import 'package:flutter/material.dart';
import 'package:fourth/screens/edit_product_screen.dart';
import 'package:fourth/widget/app_drawer.dart';
import 'package:fourth/widget/user_products_item.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';

class UserProducts extends StatelessWidget {
  static const String routeName = '/user-product';

  Future<void> _refreshPage(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsDetails = Provider.of<Products>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshPage(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshPage(context),
                    child: Consumer<Products>(
                      builder: (ctx,productsDetails,_)=> Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: productsDetails.items.length,
                          itemBuilder: (ctx, i) => Column(
                            children: <Widget>[
                              UserProductItem(
                                productsDetails.items[i].title,
                                productsDetails.items[i].imageUrl,
                                productsDetails.items[i].id,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
