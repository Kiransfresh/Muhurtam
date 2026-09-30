import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muhurtham',
      initialRoute: RouteNames.splash,
      routes: appRoutes,
      theme: AppTheme.light,
    );
  }
}
