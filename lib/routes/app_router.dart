import 'package:flutter/material.dart';
import 'route_names.dart'; // Import RouteNames from separate file
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/customer/home/presentation/pages/home_page.dart';

// Routes map for MaterialApp
Map<String, WidgetBuilder> get appRoutes {
  return {
    RouteNames.splash: (context) => const SplashPage(),
    RouteNames.home: (context) => const HomePage(),
  };
}

// onGenerateRoute for more control
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.splash:
      return MaterialPageRoute(
        builder: (_) => const SplashPage(),
        settings: settings,
      );
    case RouteNames.home:
      return MaterialPageRoute(
        builder: (_) => const HomePage(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const SplashPage(),
        settings: settings,
      );
  }
}
