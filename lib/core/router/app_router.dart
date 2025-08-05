import 'package:go_router/go_router.dart';
import 'package:starter_template/features/home/home_screen.dart';
import '../../features/splash/splash_screen.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
  ],
);
