import 'package:flutter/material.dart';
import 'package:sendoff/routes/route_names.dart';
import 'package:sendoff/screens/home/custom_bottom_navbar.dart';
import 'package:sendoff/screens/splash/splash_screen.dart';

import '../screens/cart/cart_page.dart';

@immutable
class AppRouter {
  const AppRouter._();
  static const String initialRoute = RouteNames.splashScreen;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Future<dynamic> pushNamed(routeName, {dynamic routeArguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: routeArguments);
  }

  static Future<dynamic> replaceNamed(routeName, {dynamic routeArguments}) {
    return navigatorKey.currentState!.popAndPushNamed(routeName, arguments: routeArguments);
  }

  static Future<dynamic> pushNamedAndRemoveAllStack(routeName, {dynamic routeArguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: routeArguments,
    );
  }

  static void pop() {
    return navigatorKey.currentState!.pop();
  }

  static Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouteNames.splashScreen:
        return moveMaterialPageRoute(
          pageClass: const SplashScreen(),
          pageName: RouteNames.splashScreen,
        );
      case RouteNames.bottomNav:
        return moveMaterialPageRoute(
          pageClass: const CustomBottomNavBar(),
          pageName: RouteNames.bottomNav,
        );
      case RouteNames.categoryProducts:
      // return moveMaterialPageRoute(
      //   pageClass: const CategoryProducts(),
      //   pageName: RouteNames.categoryProducts,
      // );
      case RouteNames.productDetails:
      // return moveMaterialPageRoute(
      //   pageClass: ProductDetails(),
      //   pageName: RouteNames.productDetails,
      // );
      case RouteNames.cartPage:
        return moveMaterialPageRoute(
          pageClass: const CartPage(),
          pageName: RouteNames.cartPage,
        );
      case RouteNames.checkout:
      // return moveMaterialPageRoute(
      //   pageClass: const Checkout(),
      //   pageName: RouteNames.checkout,
      // );
      case RouteNames.register:
      // return moveMaterialPageRoute(
      //   pageClass: const RegisterScreen(),
      //   pageName: RouteNames.register,
      // );
      case RouteNames.chat:
      // return moveMaterialPageRoute(
      //   pageClass:  ChatScreen(),
      //   pageName: RouteNames.chat,
      // );
      case RouteNames.allCats:
      // return moveMaterialPageRoute(
      //   pageClass: const AllCategories(),
      //   pageName: RouteNames.allCats,
      // );
    }
    return MaterialPageRoute(builder: (context) => Container());
  }
}

MaterialPageRoute moveMaterialPageRoute({required Widget pageClass, required String pageName, Object? arguments}) {
  return MaterialPageRoute(
    builder: (_) => pageClass,
    settings: RouteSettings(
      name: pageName,
      arguments: arguments,
    ),
  );
}
