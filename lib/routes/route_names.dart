import 'package:flutter/material.dart';

@immutable
abstract class RouteNames {
  const RouteNames._();
  static const String splashScreen = "/splash-screen";
  static const String homeScreen = "/home-screen";
  static const String bottomNav = "/bottom-nav";
  static const String allCats = "/all-cats";
  static const String categoryProducts = "/category-products";
  static const String productDetails = "/product-details";
  static const String cartPage = "/cart-page";
  static const String checkout = "/checkout";
  static const String register = "/register";
  static const String chat = "/chat";
}
