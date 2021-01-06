import 'package:flutter/material.dart';
import 'package:fourth/provider/products.dart';
import 'package:fourth/screens/auth_screen.dart';
import 'package:fourth/screens/cart_screen.dart';
import 'package:fourth/screens/edit_product_screen.dart';
import 'package:fourth/screens/order_scrren.dart';
import 'package:fourth/screens/product_detail_screen.dart';
import 'package:fourth/screens/product_overview_screen.dart';
import 'package:fourth/screens/user_productes.dart';
import 'package:fourth/widget/Splash.dart';
import 'package:provider/provider.dart';
import './provider/cart.dart';
import './screens/edit_product_screen.dart';
import './provider/order.dart';
import './provider/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (ctx)=>Auth()),ProxyProvider<Auth,Products>(create: (_,auth,previousProduct)=>Products(),),
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (_, auth, previosProduct) => Products(
                token: auth.token,
                userid: auth.user_id,
                item: (previosProduct == null ? [] : previosProduct.item)),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            update: (_, auth, previosProduct) => Order(
                auth.token,
                (previosProduct == null ? [] : previosProduct.orders),
                auth.user_id),
          ),

          //ProxyProvider<Auth,Products>(update: (_,auth,previous)=>Products(token:auth.token,item: previous==null ? [] : previous.item), create: (_) =>Products(),),
          // ChangeNotifierProvider.value(
          //   value: Products(),
          // ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          // ChangeNotifierProvider.value(
          //   value: Order(),
          // ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? Splash()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routename: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProducts.routeName: (ctx) => UserProducts(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
