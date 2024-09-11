import 'package:flutter/material.dart';
import 'package:freaking/screens/register_screen.dart';
import '../colors/app_colors.dart';
import 'package:freaking/routes/app_routes.dart';

import '../components/custom_navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController resetEmailController = TextEditingController();
  //final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /*Future<void> _login() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos los campos son obligatorios')),
        );
        return;
      }

      // Iniciar sesión con Firebase Auth
      auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Obtener datos del usuario desde Firestore
      model.User userData = await model.User.loadFromFirestore(userCredential.user!.uid);

      // Guardar datos del usuario en shared_preferences
      await userData.saveToPreferences();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión realizado correctamente')),
      );

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Routes()),
      );
    } on auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'wrong-password':
          errorMessage = 'La contraseña es incorrecta.';
          break;
        case 'user-not-found':
          errorMessage = 'No se encontró una cuenta con este correo electrónico.';
          break;
        default:
          errorMessage = 'Ocurrió un error. Por favor, inténtalo de nuevo.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }*/

  // Función para enviar correo electrónico de restablecimiento de contraseña
  /*Future<void> resetPassword(BuildContext context, String email) async {
    try {
      if (resetEmailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe ingresar un correo.')),
        );
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Notificar al usuario que se ha enviado el correo electrónico de restablecimiento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se ha enviado un correo electrónico para reestablecer su contraseña.'),
        ),
      );
    } on auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'missing-email':
          errorMessage = 'No se ha encontrado ninguna cuenta asociada al email proporcionado.';
          break;
        case 'user-not-found':
          errorMessage = 'No se encontró una cuenta con este correo electrónico.';
          break;
        default:
          errorMessage = 'Ocurrió un error. Por favor, inténtalo de nuevo.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.purple1,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(46),
          child: Center(
            child: Container(
              width: screenWidth > 425 ? 425 : double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1, // Relación de aspecto para mantenerlo cuadrado
                    child: Stack(
                      alignment: Alignment.center, // Centra los elementos dentro del Stack
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[850]!.withOpacity(0.50),
                                offset: const Offset(0, 10),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          child: Image.asset(
                            'assets/img/luffy.png',
                            width: 150, // Ancho de la imagen
                            height: 150, // Alto de la imagen
                            fit: BoxFit.contain, // Ajusta el tamaño de la imagen para que se ajuste al contenedor
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
                              context, AppRoutes.registerScreen);
                        },
                        child: const Text(
                          'Registro',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            shadows: [
                              Shadow(
                                color: Color(0x40000000),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          const TextButton(
                            onPressed: null,
                            child: Text(
                              'Inicio de Sesión',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                shadows: [
                                  Shadow(
                                    color: Color(0x40000000),
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 3,
                            width: 140,
                            color: AppColors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿De vuelta? ¡Te esperábamos!',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
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
                    child: TextField(

                      controller: emailController,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      cursorColor: AppColors.green,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 5.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contraseña',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFieldWithButton(
                    controller: passwordController,
                    customTextStyle: const TextStyle(
                      color: AppColors.green,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    cursorColor: AppColors.green,
                    fillColor: AppColors.purple1,
                    borderColor: AppColors.green,
                    focusedBorderColor: AppColors.green,
                    enabledBorderColor: AppColors.green,
                    borderWidth: 3.0,
                    focusedBorderWidth: 5.0,
                    enabledBorderWidth: 3.0,
                    contentVerticalPadding: 8.0,
                    contentHorizontalPadding: 16.0,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Reestablecer contraseña"),
                            titleTextStyle: const TextStyle(
                              color: AppColors.green,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(
                                  color: Color(0x40000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            elevation: 24.0,
                            backgroundColor: AppColors.white,
                            content: Container(
                              width: 300.0,
                              height: 300.0,
                              child: SingleChildScrollView(
                                child: ListBody(
                                  children:
                                  <Widget>[
                                    const Text(
                                      "Ingrese su correo",
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                        shadows: [
                                          Shadow(
                                            color: Color(0x40000000),
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
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
                                      child: TextField(

                                        controller: resetEmailController,
                                        style: const TextStyle(
                                          color: AppColors.green,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                          shadows: [
                                            Shadow(
                                              color: Color(0x40000000),
                                              offset: Offset(0, 4),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        cursorColor: AppColors.green,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 16.0,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                              color: AppColors.green,
                                              width: 3.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                              color: AppColors.green,
                                              width: 5.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(
                                              color: AppColors.green,
                                              width: 3.0,
                                            ),
                                          ),
                                        ),
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
                                        onPressed: () {
                                          //Navigator.pushNamed(context, '/');
                                          CustomNavigator.instantNavigationPushNamedAndRemoveUntil(context, AppRoutes.customBotomNavigationBarController);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: AppColors.white,
                                          backgroundColor: AppColors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text('Entrar', style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                          shadows: [
                                            Shadow(
                                              color: Color(0x40000000),
                                              offset: Offset(0, 4),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text(
                                  "Cerrar",
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    shadows: [
                                      Shadow(
                                        color: Color(0x40000000),
                                        offset: Offset(0, 4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Recuperar contraseña',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      onPressed: () {
                        CustomNavigator.instantNavigationPushNamedAndRemoveUntil(context, AppRoutes.customBotomNavigationBarController);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Entrar', style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
