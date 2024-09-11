import 'package:flutter/material.dart';
import 'package:freaking/components/custom_bottomNavigationBar_controller.dart';
import 'package:freaking/screens/home_screen.dart';
import 'package:freaking/screens/news_screen.dart';
import 'package:freaking/screens/points_store_screen.dart';
import 'package:freaking/screens/register_screen.dart';
import '../screens/details_screen.dart';
import '../screens/favorite_screen.dart';
import '../screens/login_screen.dart';

/// Clase que define las rutas de la aplicación.
///
/// Esta clase proporciona las rutas en forma de variables constantes para usarlas con los métodos de navegación personalizados de la clase 'CustomNavigator'.
class AppRoutes {
  static const String homeScreen = '/homeScreen';
  static const String pointsStoreScreen = '/pointsStoreScreen';
  static const String newsScreen = '/newsScreen';
  static const String favoriteScreen = '/favoriteScreen';
  static const String detailsScreen = '/detailsScreen';
  static const String registerScreen = '/registerScreen';
  static const String loginScreen = '/loginScreen';
  static const String customBotomNavigationBarController = '/customBotomNavigationBarController';

  /// Método estático que devuelve un mapa con las rutas de la aplicación.
  ///
  /// En este método cada entrada en el mapa asocia una ruta con la clase de la pantalla correspondiente.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      homeScreen: (context) => const HomeScreen(),
      pointsStoreScreen: (context) => const PointsStoreScreen(),
      newsScreen: (context) => const NewsScreen(),
      favoriteScreen: (context) => const FavoriteScreen(),
      detailsScreen: (context) => const DetailsScreen(),
      registerScreen: (context) => const RegisterScreen(),
      loginScreen: (context) => const LoginScreen(),
      customBotomNavigationBarController: (context) => const CustomBottomNavBarController(),
    };
  }
}
