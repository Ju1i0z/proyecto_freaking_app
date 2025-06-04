import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'custom_button.dart';
import 'custom_navigator.dart';
import 'custom_text_field.dart';
import 'custom_text_style.dart';

/// Clase que proporciona notificaciones emergentes personalizadas.
///
/// Esta clase contiene la colección de notificaciones emergentes
/// personalizadas.
class CustomDialog {

  /// Notificación emergente de bienvenida para un nuevo usuario personalizada.
  ///
  /// Parámetros:
  /// - 'context': Contexto sobre el lugar de la aplicación dónde se mostrará la notificación.
  /// - 'title': Título de la notificación.
  /// - 'message': Contenido de la notificación.
  /// - 'onConfirm': Función que se ejecuta cuando el usuario presiona el botón de confirmación.
  static void showWelcomeNewUserDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '¡Bienvenid@!',
              style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Text(
              'Te damos la bienvenida a nuestro rincón del mundo friki. Explora y descubre nuestra variedad de productos relacionados con la cultura oriental.',
              style: Theme.of(context).dialogTheme.contentTextStyle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                onConfirm(); // Llama la función de confirmación
              },
              child: Text(
                  'Continuar',
                  style: Theme.of(context).dialogTheme.contentTextStyle),
            ),
          ],
        );
      },
    );
  }

  /// Notificación emergente de bienvenida para un usuario antiguo personalizada.
  ///
  /// Parámetros:
  /// - 'context': Contexto sobre el lugar de la aplicación dónde se mostrará la notificación.
  /// - 'title': Título de la notificación.
  /// - 'message': Contenido de la notificación.
  /// - 'onConfirm': Función que se ejecuta cuando el usuario presiona el botón de confirmación.
  static void showWelcomeOldUserDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '¡Nos alegra verte de nuevo por aquí!',
              style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Text(
              '¡Bienvenid@ de vuelta! Puede que encuentres algo nuevo desde la última vez, ¿que tal si echamos un vistazo?',
              style: Theme.of(context).dialogTheme.contentTextStyle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                onConfirm(); // Llama la función de confirmación
              },
              child: Text(
                  'Continuar',
                  style: Theme.of(context).dialogTheme.contentTextStyle),
            ),
          ],
        );
      },
    );
  }

  /// Notificación emergente personalizada para reestablecer la contraseña.
  ///
  /// Parámetros:
  /// - 'context': Contexto sobre el lugar de la aplicación dónde se mostrará la notificación.
  /// - 'resetEmailController': Controlador del campo de texto que captura el correo electrónico.
  /// - 'onConfirm': Función que se ejecuta cuando el usuario presiona el botón de confirmación.
  static Widget buildResetPasswordDialog({
    required BuildContext context,
    required TextEditingController resetEmailController,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    required GlobalKey<FormState> formKey,
    Center? child,
  }) {
    return AlertDialog(
      title: Text(
        "Reestablecer contraseña",
        style: Theme.of(context).dialogTheme.titleTextStyle,
      ),
      elevation: 24.0,
      content: Container(
        width: 300.0,
        height: 170.0,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListBody(
              children: <Widget>[
                Text(
                  "Ingrese su correo",
                  style: Theme.of(context).dialogTheme.contentTextStyle,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: AppColors.purple1,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: CustomTextField.customTextFormField(
                    controller: resetEmailController,
                    customTextStyle: Theme.of(context).dialogTheme.contentTextStyle!,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    fillColor: Theme.of(context).colorScheme.surface,
                    borderColor: Theme.of(context).colorScheme.primary,
                    focusedBorderColor: Theme.of(context).colorScheme.primary,
                    enabledBorderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 3.0,
                    focusedBorderWidth: 5.0,
                    enabledBorderWidth: 3.0,
                    contentVerticalPadding: 8.0,
                    contentHorizontalPadding: 16.0,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Añade un correo electrónico.';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Añade un correo electrónico válido.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Reestablecer contraseña',
                      style: CustomTextStyle.whiteSemiBold14WithShadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cerrar', style: Theme.of(context).dialogTheme.contentTextStyle),
        ),
      ],
    );
  }


  /// Notificación emergente personalizada que notifica al usuario que se le ha enviado un correo para reestablecer la contraseña.
  ///
  /// Parámetros:
  /// - 'context': Contexto sobre el lugar de la aplicación dónde se mostrará la notificación.
  /// - 'title': Título de la notificación.
  /// - 'message': Contenido de la notificación.
  /// - 'onConfirm': Función que se ejecuta cuando el usuario presiona el botón de confirmación.
  static void showResetPasswordEmailNotificationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    required String email,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Correo de reestablecimiento de contraseña enviado.',
              style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Text(
              'Hemos enviado un correo para reestablecer la contraseña de la cuenta \'$email\'. Por favor, revise su bandeja de entrada y siga los pasos indicados.',
              style: Theme.of(context).dialogTheme.contentTextStyle),
          actions: [
            TextButton(
              onPressed: () {
                CustomNavigator.instantNavigationPop(context);
                onConfirm(); // Llama la función de confirmación
              },
              child: Text(
                  'Cerrar',
                  style: Theme.of(context).dialogTheme.contentTextStyle),
            ),
          ],
        );
      },
    );
  }

  /// Notificación emergente personalizada que notifica al usuario que no existe ninguna cuenta asociada al correo introducido.
  ///
  /// Parámetros:
  /// - 'context': Contexto sobre el lugar de la aplicación dónde se mostrará la notificación.
  /// - 'title': Título de la notificación.
  /// - 'message': Contenido de la notificación.
  /// - 'onConfirm': Función que se ejecuta cuando el usuario presiona el botón de confirmación.
  static void showAccountNotFoundDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    required String email,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Cuenta no encontrada.',
              style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Text(
              'No hemos encontrado ninguna cuenta asociada al correo proporcionado. Por favor, revise el correo introducido e inténtelo más tarde.',
              style: Theme.of(context).dialogTheme.contentTextStyle),
          actions: [
            TextButton(
              onPressed: () {
                onConfirm(); // Llama la función de confirmación
              },
              child: Text(
                  'Confirmar',
                  style: Theme.of(context).dialogTheme.contentTextStyle),
            ),
          ],
        );
      },
    );
  }

  /// Diálogo de confirmación personalizado.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [title]: El título del diálogo.
  /// - [message]: El contenido del diálogo.
  /// - [onConfirm]: Función que se ejecuta cuando el usuario confirma la acción.
  /// - [onCancel]: Función que se ejecuta cuando el usuario cancela la acción.
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (onCancel != null) {
                  onCancel(); // Llama a la función de cancelación si existe
                }
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                onConfirm(); // Llama a la función de confirmación
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  /// Diálogo de error personalizado.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [errorMessage]: El mensaje de error a mostrar.
  /// - [onDismiss]: Función que se ejecuta cuando el usuario cierra el diálogo.
  static void showErrorDialog({
    required BuildContext context,
    required String errorMessage,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (onDismiss != null) {
                  onDismiss(); // Llama a la función de cierre si existe
                }
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

}


