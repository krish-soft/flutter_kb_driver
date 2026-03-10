import 'package:get/get.dart';
import 'package:kb_driver/core/data/presentation/views/auth/forgot_password_screen.dart';
import 'package:kb_driver/core/data/presentation/views/auth/signin_screen.dart';
import 'package:kb_driver/core/data/presentation/views/auth/signup_screen.dart';
import 'package:kb_driver/view/home_screen.dart';
import 'package:kb_driver/view/screens/settings/BankScreen.dart';
import 'package:kb_driver/view/screens/settings/ProfileScreen.dart';
import 'package:kb_driver/view/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/splash',
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),

    GetPage(
      name: '/signin',
      page: () => SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),

    GetPage(
      name: '/signup',
      page: () => SignUpScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/forgot-password',
      page: () => ForgotPasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),

    GetPage(
      name: '/home',
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),


     GetPage(
      name: '/profile',
      page: () => ProfileScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 250),
    ),

    
     GetPage(
      name: '/user-bank',
      page: () => BankScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 250),
    ),
  ];
}
