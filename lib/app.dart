import 'package:flutter/material.dart';
import 'utils/app_router.dart';

class MyApp extends StatelessWidget {
 final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.navigatorKey, 
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TaskTaker",
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
