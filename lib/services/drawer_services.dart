import 'package:e_grocery_partner/screens/dashboard_screen.dart';
import 'package:e_grocery_partner/screens/product_screen.dart';
import 'package:flutter/material.dart';

class DrawerServices {
  Widget drawerScreen(title) {
    if (title == "Dashboard")
      return MainScreen();
    if (title == "Product")
      return ProductScreen();
    return MainScreen();
  }
}