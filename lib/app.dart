import 'package:flutter/material.dart';
import 'utils/app_router.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TaskTaker",
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
