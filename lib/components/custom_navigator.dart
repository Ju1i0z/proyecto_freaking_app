import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

/// Clase que define métodos personalizados para la navegación entre pantallas en la aplicación.
///
/// Esta clase contiene métodos para realizar transiciones personalizadas entre pantallas.

//TODO Añadir tiempo de carga en pantallas
class CustomNavigator {

  /// Método que navega a una nueva pantalla y elimina todas las pantallas anteriores
  /// de la pila de navegación y que tiene animación instantánea.
  ///
  /// Parámetros:
  /// - `context`: El contexto de construcción actual.
  /// - `page`: El widget de la clase de la nueva pantalla a la que se va a navegar.
  static void instantNavigationPushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
      ),
          (Route<dynamic> route) => false,
    );
  }

  /// Método que navega a una nueva pantalla sin eliminar las pantallas anteriores
  /// de la pila de navegación y que tiene animación instantánea.
  ///
  /// Parámetros:
  /// - `context`: El contexto de construcción actual.
  /// - `page`: El widget de la clase de la nueva pantalla a la que se va a navegar.
  static void instantNavigationPush(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  /// Método que navega a una nueva pantalla utilizando el nombre de ruta sin eliminar las pantallas anteriores
  /// de la pila de navegación y que tiene animación instantánea.
  ///
  /// Parámetros:
  /// - `context`: El contexto de construcción actual.
  /// - `routeName`: El nombre de la ruta de la nueva pantalla a la que se va a navegar.
  static void instantNavigationPushNamed(BuildContext context, String routeName) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppRoutes.getRoutes()[routeName]!(context),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  /// Método que navega a una nueva pantalla utilizando el nombre de ruta y elimina todas las pantallas anteriores
  /// de la pila de navegación y que tiene animación instantánea.
  ///
  /// Parámetros:
  /// - `context`: El contexto de construcción actual.
  /// - `routeName`: El nombre de la ruta de la nueva pantalla a la que se va a navegar.
  static void instantNavigationPushNamedAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppRoutes.getRoutes()[routeName]!(context),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
          (Route<dynamic> route) => false,
    );
  }

  /// Método que retrocede a la pantalla anterior en la pila de navegación.
  ///
  /// Parámetros:
  /// - `context`: El contexto de construcción actual.
  static void instantNavigationPop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
