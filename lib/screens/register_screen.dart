import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_dialog.dart';
import '../components/custom_navigator.dart';
import '../components/custom_text_field.dart';
import '../components/custom_text_style.dart';
import '../model/user.dart';
import '../routes/app_routes.dart';
import 'package:http/http.dart' as http;

/// Pantalla de registro de usuarios.
///
/// Esta clase contiene la interfaz para que los usuarios puedan
/// registrarse en la aplicación. Incluye validaciones para los campos de nombre de usuario, email y contraseña,
/// manejo de errores y funciones para integrarse con Firebase Authentication, Firestore y Stripe.
///
/// Componentes principales:
/// - Validación de los campos en tiempo real.
/// - Integración con Firebase para autenticar y guardar datos al realizar el registro de usuario.
/// - Creación de clientes en Stripe para futuras transacciones.
/// - Gestión de estados y pantalla de carga durante las operaciones asincrónicas.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Claves para manejar los formularios
  final _formKey = GlobalKey<FormState>();

  /// Controladores de texto para capturar los datos insertados por el usuario.
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Instancia de FirebaseAuth para autenticación.
  final _auth = FirebaseAuth.instance;

  /// Instancia de FirebaseFirestore para almacenamiento de datos.
  final _firestore = FirebaseFirestore.instance;

  /// Estado para manejar la visualización del indicador de carga.
  bool _isLoading = false;


  /// Método para registrar un nuevo usuario.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Valida el formulario de registro.
  /// 2. Crea un usuario en Firebase Authentication y un cliente en Stripe de forma simultánea.
  /// 3. Guarda los datos del usuario en Firestore.
  /// 4. Almacena algunos datos localmente en SharedPreferences.
  /// 5. Redirige al usuario a la pantalla principal y muestra un mensaje de bienvenida.
  void _register() async {

    /// 1. Método que valida el formulario y muestra la pantalla de carga mientras se realizan
    /// las operaciones.
    if (_formKey.currentState?.validate() ?? false) {
      /// Muestra la pantalla de carga.
      setState(() {
        _isLoading = true;
      });

      /// Método que registra un nuevo usuario realizando las siguientes acciones:
      /// 1. Crea un usuario en Firebase Authentication.
      /// 2. Crea un cliente en Stripe.
      /// 3. Genera un objeto `UserModel` con los datos del usuario.
      /// 4. Guarda la información del usuario en Firestore y en `shared_preferences`.
      /// 5. Redirige al usuario a la pantalla principal y muestra un mensaje de bienvenida.
      try {
        /// Creación del usuario en Firebase Auth y cliente en Stripe en paralelo
        /// con los datos recogidos en los campos de texto.
        /// Se inician ambas tareas simultáneamente para optimizar el tiempo de espera.
        final createUserFuture = _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final createStripeCustomerFuture = _createStripeCustomer(
          _userNameController.text.trim(),
          _emailController.text.trim(),
        );

        /// Espera de ambos resultados al mismo tiempo y guardado de los resultados en la variable 'results'.
        final results = await Future.wait([
          createUserFuture,
          createStripeCustomerFuture,
        ]);

        /// Extracción de los resultados obtenidos.
        UserCredential userCredential = results[0] as UserCredential;
        String stripeCustomerId = results[1] as String;

        /// Obtención del UID del usuario creado en Firebase.
        String uid = userCredential.user?.uid ?? '';

        /// Creación de un objeto `UserModel` con los datos del usuario.
        UserModel newUser = UserModel(
          uid: uid,
          name: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          accountState: 'active',
          stripeCustomerId: stripeCustomerId,
          createdAt: DateTime.now(),
          accumulatedPoints: 0,
          address: Address(
            city: '',
            country: '',
            mobile: '',
            postalCode: '',
            province: '',
            streetAddress: '',
          ),
        );

        /// Guardado de los datos del usuario en Firestore.
        await _firestore.collection('users').doc(uid).set(
            newUser.toFirestore());

        /// Guardado de los datos del usuario en `shared_preferences` para acceso rápido.
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', uid);
        prefs.setString('stripeCustomerId', stripeCustomerId);
        prefs.setString('email', _emailController.text);
        prefs.setString('name', _userNameController.text);
        prefs.setString('accountState', "active");

        /// Redirección del usuario a la pantalla principal de la aplicación.
        CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
          context,
          AppRoutes.customBotomNavigationBarController,
        );

        /// Muestra del diálogo de bienvenida para confirmar al usuario que el registro fue exitoso.
        CustomDialog.showWelcomeNewUserDialog(
          context: context,
          onConfirm: () {
            CustomNavigator.instantNavigationPop(context);
          },
        );
      } on Exception catch (e) {
        _Error(e);
      }

      /// Finalización de la pantalla de carga.
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Maneja los errores durante el proceso de registro de usuario.
  ///
  /// Este método recibe una excepción (`Exception e`), analiza su tipo
  /// y genera un mensaje de error adecuado para el usuario.
  /// Si el error proviene de Firebase Authentication, se identifican códigos de error específicos
  /// (como email ya registrado). Si no, se muestra un mensaje genérico.
  void _Error(Exception e) {
    String errorMessage;

    /// Verificación si la excepción es un error de Firebase Authentication.
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
          'Ya existe una cuenta asociada a este correo electrónico.';
          break;

      /// Error genérico de Firebase.
        default:
          errorMessage =
          'Ocurrió un error al registrar el usuario. Por favor, inténtalo de nuevo.';
      }
    } else {
      /// Si la excepción no es de Firebase, se usa un mensaje de error genérico.
      errorMessage =
      'Ocurrió un error al registrar el usuario. Por favor, inténtalo de nuevo.';
    }

    /// Muestra de un cuadro de diálogo con el mensaje de error.
    _showErrorDialog(errorMessage);
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
          title: Text('Error de registro.'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar.',
                style: Theme
                    .of(context)
                    .dialogTheme
                    .contentTextStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Método que crea un cliente en Stripe a través de una solicitud HTTP POST.
  ///
  /// Este método envía una petición a una Firebase Function en la nube, proporcionando
  /// el nombre de usuario y correo electrónico del nuevo cliente.
  ///
  /// Si la operación es exitosa, retorna el ID del cliente de Stripe.
  /// Si hay un error, se lanza una excepción.
  Future<String> _createStripeCustomer(String username, String email) async {
    try {
      /// Realización de una solicitud POST a la función para crear un cliente en Stripe.
      final response = await http.post(
        Uri.parse(
            'https://europe-west3-freaking-76982.cloudfunctions.net/createStripeCustomer'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': username,
        }),
      );

      /// Verificación que comprueba si la respuesta es exitosa (código 200).
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// Retorna el ID del cliente de Stripe.
        return data['id'];
      } else {
        /// Si la respuesta no es exitosa, se lanza una excepción con el mensaje de error recibido.
        throw Exception('Error creando el cliente en Stripe: ${response.body}');
      }
    } catch (e) {
      // 3. Captura y maneja cualquier error durante la solicitud HTTP.
      throw Exception('Error en la creación del cliente de Stripe: $e');
    }
  }


  /// Widget que construye la interfaz de la pantalla de registro.
  ///
  /// Este widget muestra un formulario de registro con campos para nombre de usuario,
  /// correo electrónico y contraseña, junto con validaciones de entrada.
  ///
  /// También incluye un indicador de carga mientras se procesa el registro.
  @override
  Widget build(BuildContext context) {
    /// Obtención del ancho de la pantalla para ajustar el diseño dinámicamente.
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(

      /// Establece el color de fondo de la pantalla basado en el tema actual.
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
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
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                TextButton(

                                  /// Opción deshabilitada porque ya estamos en la pantalla "Registro".
                                  onPressed: null,
                                  child: Text(
                                    'Registro',
                                    style: CustomTextStyle
                                        .dynamicColorBold16WithShadow(context),
                                  ),
                                ),

                                /// Línea inferior para resaltar la pestaña seleccionada.
                                Container(
                                  height: 3,
                                  width: 80,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              ],
                            ),

                            /// Botón para cambiar a la pantalla de inicio de sesión.
                            TextButton(
                              onPressed: () {
                                CustomNavigator
                                    .instantNavigationPushNamedAndRemoveUntil(
                                    context, AppRoutes.loginScreen);
                              },
                              child: Text('Inicio de sesión',
                                  style: CustomTextStyle
                                      .dynamicColorBold16WithShadow(context)
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// Mensaje de bienvenida.
                        Text('¿Primera vez por aquí? ¡Regístrate!',
                            style: CustomTextStyle.dynamicColorBold14WithShadow(
                                context)),

                        const SizedBox(height: 16),

                        /// Campo de entrada: Nombre de usuario.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Nombre de usuario',
                              style: CustomTextStyle
                                  .dynamicColorBold14WithShadow(context)),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField.customTextFormField(

                          /// Controlador para capturar el texto ingresado.
                          controller: _userNameController,
                          customTextStyle: CustomTextStyle
                              .dynamicColorSemiBold14WithShadow(context),
                          cursorColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          fillColor: Theme
                              .of(context)
                              .colorScheme
                              .surface,
                          borderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          focusedBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          enabledBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          borderWidth: 3.0,
                          focusedBorderWidth: 5.0,
                          enabledBorderWidth: 3.0,
                          contentVerticalPadding: 8.0,
                          contentHorizontalPadding: 16.0,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Añade un nombre de usuario.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        /// Campo de entrada: Email.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email',
                              style: CustomTextStyle
                                  .dynamicColorBold14WithShadow(context)),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField.customTextFormField(
                          controller: _emailController,
                          customTextStyle: CustomTextStyle
                              .dynamicColorSemiBold14WithShadow(context),
                          cursorColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          fillColor: Theme
                              .of(context)
                              .colorScheme
                              .surface,
                          borderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          focusedBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          enabledBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          borderWidth: 3.0,
                          focusedBorderWidth: 5.0,
                          enabledBorderWidth: 3.0,
                          contentVerticalPadding: 8.0,
                          contentHorizontalPadding: 16.0,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Añade un correo electrónico.';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(
                                value)) {
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
                              style: CustomTextStyle
                                  .dynamicColorBold14WithShadow(context)),
                        ),
                        const SizedBox(height: 10),
                        CustomPasswordTextFormFieldWithButton(
                          controller: _passwordController,
                          customTextStyle: CustomTextStyle
                              .dynamicColorSemiBold14WithShadow(context),
                          cursorColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          fillColor: Theme
                              .of(context)
                              .colorScheme
                              .surface,
                          borderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          focusedBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          enabledBorderColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
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

                        /// Botón para enviar el formulario y registrar al usuario.
                        CustomButton.customElevatedButtonWithText(
                          onPressed: _register,
                          text: 'Entrar',
                          foregroundColor: AppColors.white,
                          backgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          customTextStyle: CustomTextStyle
                              .whiteSemiBold14WithShadow,
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
