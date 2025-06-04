import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import 'package:freaking/routes/app_routes.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_dialog.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_field.dart';
import '../components/custom_text_style.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// Pantalla de inicio de sesión.
///
/// Esta clase proporciona la interfaz para que los usuarios puedan iniciar sesión en la aplicación.
/// Permite la autenticación mediante Firebase Authentication y la recuperación de datos del usuario desde Firestore.
/// También maneja errores comunes y muestra mensajes apropiados al usuario.
///
/// Componentes principales:
/// - Validación de los campos en tiempo real.
/// - Inicio de sesión con Firebase Authentication.
/// - Recuperación y almacenamiento de datos del usuario en SharedPreferences.
/// - Manejo de errores y pantalla de carga durante el proceso de autenticación.

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Claves para manejar los formularios
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  /// Controladores de texto para capturar los datos insertados por el usuario.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  /// Instancia de FirebaseAuth para autenticación.
  final _auth = FirebaseAuth.instance;
  /// Estado para manejar la visualización del indicador de carga.
  bool _isLoading = false;

  /// Método para iniciar sesión con correo y contraseña.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Valida el formulario de inicio de sesión.
  /// 2. Autentica al usuario en Firebase Authentication.
  /// 3. Recupera los datos del usuario desde Firestore.
  /// 4. Verifica si la cuenta está deshabilitada y maneja posibles errores.
  /// 5. Almacena algunos datos localmente en SharedPreferences.
  /// 6. Redirige al usuario a la pantalla principal y muestra un mensaje de bienvenida.
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        /// Verificación que comprueba si el usuario existe antes de intentar loguearse.
        bool userExists = await checkIfUserExists(_emailController.text.trim());

        if (!userExists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No se encontró una cuenta asociada a este correo electrónico.',
          );
        }

        /// Intento de inicio de sesión solo si el correo existe.
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (userDoc.exists) {
            String accountState = userDoc['accountState'] ?? 'active';
            if (accountState == 'disabled') {
              throw FirebaseAuthException(
                code: 'account-disabled',
                message: 'Tu cuenta está en proceso de eliminación. No puedes iniciar sesión.',
              );
            }

            String email = userDoc['email'];
            String name = userDoc['name'];
            String stripeCustomerId = userDoc['stripeCustomerId'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('name', name);
            await prefs.setString('stripeCustomerId', stripeCustomerId);

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.customBotomNavigationBarController,
            );

            CustomDialog.showWelcomeOldUserDialog(
              context: context,
              onConfirm: () {
                CustomNavigator.instantNavigationPop(context);
              },
            );
          } else {
            print("No se encontró el documento del usuario en Firestore.");
          }
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException code: ${e.code}');

        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No se encontró una cuenta asociada a este correo electrónico.';
            break;
          case 'invalid-credential':
            errorMessage = 'La contraseña introducida es incorrecta.';
            break;
          case 'too-many-requests':
            errorMessage = 'Demasiados intentos fallidos. Inténtalo de nuevo más tarde.';
            break;
          case 'account-disabled':
            errorMessage = 'Esta cuenta ha sido deshabilitada. \n\n Para más información contacta con soporte. \n\n'
                'Para cualquier duda o asistencia puede contactar con nosotros a través del número 954822717 de 8:00 a 21:00 de lunes a viernes o enviar un correo a la dirección 41003066.edu@juntadeandalucia.es';
            break;
          default:
            errorMessage = 'Ocurrió un error durante el inicio de sesión. Inténtalo nuevamente.';
        }

        _showErrorDialog(errorMessage);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  /// Muestra del cuadro de diálogo de error.
  ///
  /// Este método lanza un AlertDialog con el mensaje de error recibido
  /// como parámetro para informar al usuario del problema.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de inicio de sesión.'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar',
                style: CustomTextStyle.dynamicColorBold14WithShadow(
                    context),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Método que verifica si un usuario existe en la base de datos remota.
  ///
  /// Este método realiza una solicitud HTTP POST para verificar
  /// si un usuario con el correo electrónico proporcionado existe en la base de datos.
  ///
  /// Parámetros:
  /// - `email`: El correo electrónico del usuario que se desea verificar.
  ///
  /// Retorna:
  /// - `true` si el usuario existe en la base de datos.
  /// - `false` si el usuario no existe.
  ///
  /// Lanza:
  /// - `Exception` si ocurre un error durante la solicitud HTTP o si la respuesta no es válida.
  Future<bool> checkIfUserExists(String email) async {
    /// URL  que verifica la existencia del usuario.
    final url = Uri.parse('https://europe-west3-freaking-76982.cloudfunctions.net/checkIfUserExists');

    try {
      /// Realiza una solicitud HTTP POST al endpoint con el correo electrónico proporcionado.
      final response = await http.post(
        url,
        /// Especifica el tipo de contenido como JSON.
        headers: {
          'Content-Type': 'application/json',
        },
        /// Envía el correo electrónico en el cuerpo de la solicitud.
        body: jsonEncode({
          'email': email,
        }),
      );

      /// Verificación que comprueba si la respuesta del servidor es exitosa (código 200).
      if (response.statusCode == 200) {
        /// Decodificación de la respuesta JSON.
        final data = jsonDecode(response.body);

        /// Retorno del valor booleano que indica si el usuario existe.
        return data['exists'];
      } else {
        /// Si la respuesta no es exitosa, lanza una excepción con el mensaje de error.
        throw Exception('Error al verificar la existencia del usuario: \${response.body}');
      }
    } catch (e) {
      /// Captura de cualquier excepción que ocurra durante la solicitud HTTP.
      print('Error verificando si el usuario existe: \$e');

      /// Lanzamiento de una excepción con un mensaje genérico.
      throw Exception('Error al verificar el usuario.');
    }
  }

  /// Widget que construye la interfaz de la pantalla de inicio de sesión.
  ///
  /// Este widget muestra un formulario de inicio de sesión con campos para correo electrónico
  /// y contraseña, junto con validaciones de entrada.
  ///
  /// También incluye un enlace para recuperar la contraseña y un indicador de carga
  /// mientras se procesa el inicio de sesión.
  @override
  Widget build(BuildContext context) {
    /// Obtención del ancho de la pantalla para ajustar el diseño dinámicamente.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      /// Establece el color de fondo de la pantalla basado en el tema actual.
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          /// Permite el desplazamiento cuando el contenido es más grande que la pantalla.
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(46, 46, 46, 46),
              child: Center(
                child: Container(
                  /// Limita el ancho del formulario para dispositivos más grandes.
                  width: screenWidth > 425 ? 425 : double.infinity,
                  child: Form(
                    /// Clave del formulario para validaciones.
                    key: _formKey,
                    /// Validación del formulario en tiempo real.
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// Logo de la aplicación.
                        CustomContainer().logoIcon(context),

                        /// Selector de pantallas (Registro / Inicio de sesión).
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            /// Botón para cambiar a la pantalla de registro.
                            TextButton(
                              onPressed: () {
                                CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
                                    context, AppRoutes.registerScreen);
                              },
                              child: Text(
                                'Registro',
                                style: CustomTextStyle.dynamicColorBold16WithShadow(context),
                              ),
                            ),
                            /// Opción deshabilitada porque ya estamos en la pantalla "Inicio de sesión".
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                TextButton(
                                  onPressed: null,
                                  child: Text(
                                      'Inicio de sesión',
                                      style: CustomTextStyle.dynamicColorBold16WithShadow(context)
                                  ),
                                ),
                                /// Línea inferior para resaltar la pestaña seleccionada.
                                Container(
                                  height: 3,
                                  width: 140,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// Mensaje de bienvenida.
                        Text('¿De vuelta? ¡Te esperábamos!',
                            style: CustomTextStyle.dynamicColorBold14WithShadow(context)),

                        const SizedBox(height: 16),

                        /// Campo de entrada: Email.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email',
                              style: CustomTextStyle.dynamicColorBold14WithShadow(context)),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField.customTextFormField(
                          /// Controlador para capturar el texto ingresado.
                          controller: _emailController,
                          customTextStyle: CustomTextStyle.dynamicColorSemiBold14WithShadow(context),
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
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Añade un correo electrónico válido.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        /// Campo de entrada: Contraseña.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Contraseña',
                              style: CustomTextStyle.dynamicColorBold14WithShadow(context)),
                        ),
                        const SizedBox(height: 10),
                        CustomPasswordTextFormFieldWithButton(
                          controller: _passwordController,
                          customTextStyle: CustomTextStyle.dynamicColorSemiBold14WithShadow(context),
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
                              return 'Añade tu contraseña.';
                            } else if (value.length < 8) {
                              return 'Se necesitan al menos 8 caracteres.';
                            } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Se necesita al menos una letra mayúscula.';
                            } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Se necesita al menos un número.';
                            } else if (!RegExp(r'[!@#$&*~]').hasMatch(value)) {
                              return 'Se necesita un carácter especial (!@#\$&*~).';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// Enlace para recuperar la contraseña.
                        Text('¿Olvidaste tu contraseña?',
                            style: CustomTextStyle.dynamicColorBold14WithShadow(context)),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Stack(
                                      children: [
                                        /// Diálogo para recuperar la contraseña.
                                        CustomDialog.buildResetPasswordDialog(
                                          context: context,
                                          resetEmailController: _resetEmailController,
                                          onConfirm: () async {
                                            if (_formKey2.currentState!.validate()) {
                                              /// Activación del estado de carga
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              try {
                                                String email = _resetEmailController.text.trim();
                                                bool exists = await checkIfUserExists(email);

                                                if (exists) {
                                                  await FirebaseAuth.instance
                                                      .sendPasswordResetEmail(email: email);
                                                  /// Desactivación del estado de carga.
                                                  setState(() {
                                                    _isLoading = false;
                                                  });

                                                  CustomNavigator.instantNavigationPop(context);

                                                  /// Muestra de un diálogo de notificación de éxito.
                                                  CustomDialog.showResetPasswordEmailNotificationDialog(
                                                    context: context,
                                                    email: email,
                                                    onConfirm: () {
                                                      CustomNavigator.instantNavigationPop(context);
                                                    },
                                                  );
                                                } else {
                                                  /// Desactivación del estado de carga.
                                                  setState(() {
                                                    _isLoading = false;
                                                  });

                                                  /// Muestra un diálogo si la cuenta no existe.
                                                  CustomDialog.showAccountNotFoundDialog(
                                                    context: context,
                                                    email: email,
                                                    onConfirm: () {
                                                      CustomNavigator.instantNavigationPop(context);
                                                    },
                                                  );
                                                }
                                              } catch (e) {
                                                /// Desactivación del estado de carga en caso de error.
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                print("Error: $e");
                                              }
                                            }
                                          },
                                          onCancel: () {
                                            CustomNavigator.instantNavigationPop(context);
                                          },
                                          formKey: _formKey2,
                                        ),
                                        /// Muestra un indicador de carga cuando _isLoading es true.
                                        if (_isLoading)
                                          Container(
                                            color: Colors.black.withOpacity(0.5),
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text(
                            'Recuperar contraseña',
                            style: CustomTextStyle.dynamicColorBold16WithShadow(context),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Botón para enviar el formulario y realizar el inicio de sesión.
                        CustomButton.customElevatedButtonWithText(
                          onPressed: _login,
                          text: 'Entrar',
                          foregroundColor: AppColors.white,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Muestra un indicador de carga cuando _isLoading es true.
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                /// Indicador de carga animado.
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}