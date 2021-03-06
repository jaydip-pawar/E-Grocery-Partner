import 'package:e_grocery_partner/providers/authentication_provider.dart';
import 'package:e_grocery_partner/screens/banner_screen.dart';
import 'package:e_grocery_partner/screens/dashboard_screen.dart';
import 'package:e_grocery_partner/screens/login_screen.dart';
import 'package:e_grocery_partner/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerServices {

  Widget drawerScreen(title) {
    if (title == "Dashboard")
      return MainScreen();
    if (title == "Product")
      return ProductScreen();
    if (title == "Banner")
      return BannerScreen();
    return MainScreen();
  }
}
