import 'package:glorify_god/screens/bottom_tabs/bottom_tabs.dart';
import 'package:glorify_god/screens/login_pages/login_page.dart';
import 'package:glorify_god/screens/profile_screens/profile_screen.dart';
import 'package:glorify_god/screens/search_screens/search_screen.dart';
import 'package:glorify_god/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      name: 'SplashScreen',
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: 'LoginPage',
      path: '/loginPage',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'BottomTabs',
      path: '/bottomTabs',
      builder: (context, state) => const BottomTabs(),
    ),
    GoRoute(
      name: 'ProfileScreen',
      path: '/profileScreen',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      name: 'SearchScreen',
      path: '/searchScreen',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);
