import 'package:flutter/material.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_navigator.dart';
import '../routes/app_routes.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  //final _auth = FirebaseAuth.instance;
  //final _firestore = FirebaseFirestore.instance;
  bool hideText = true;

  /*void _register() async {
    if (userNameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String uid = userCredential.user?.uid ?? '';

      await _firestore.collection('Users').doc(uid).set({
        'name': userNameController.text,
        'email': emailController.text,
        'accumulated_points': 0,
        'address': {
          'city': '',
          'country': '',
          'mobile': '',
          'postal_code': '',
          'province': '',
          'street_address': '',
        },
        'cart': [],
        'universal_coupons': [],
      });

      // Guardar datos del usuario en shared_preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', uid);
      prefs.setString('email', emailController.text);
      prefs.setString('name', userNameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro realizado correctamente')),
      );

      CustomNavigator.instantNavigation(context, Routes());
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.purple1, // Color de fondo
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(46, 46, 46, 46),
          child: Center(
            child: Container(
              width: screenWidth > 425 ? 425 : double.infinity,
              // Establece un ancho fijo si el ancho de la pantalla es superior a 425
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                /*--------------------------------------*/  // Logo
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
                /*-----------------------------------------*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          const TextButton(
                            onPressed: null,
                            child: Text(
                              'Registro',
                              /*--------------------*/
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
                            /*--------------------*/
                            ),
                          ),
                          Container(
                            height: 3, // Altura de la línea
                            width: 80, // Ancho de la línea
                            color: AppColors.green, // Color de la línea
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          CustomNavigator.instantNavigationPushNamedAndRemoveUntil(
                              context, AppRoutes.loginScreen);
                        },
                        child: const Text('Inicio de Sesión',
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
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('¿Primera vez por aquí? ¡Registrate!',
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
                      )),

                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nombre de usuario',
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
                      controller: userNameController,
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
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // Campo de contraseña para registro

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email', style: TextStyle(
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
                    )),
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
                    child: Text('Contraseña',
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
                        )),
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
                  //Navigator.pushNamed(context, AppRoutes.customBotomNavigationBarController);
                  //Navigator.pushNamed(context, AppRoutes.homeScreen);
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
        ),
      ),
    );
  }
}

class CustomTextFieldWithButton extends StatefulWidget {
  final TextEditingController controller;
  final TextStyle customTextStyle;
  final Color cursorColor;
  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final double enabledBorderWidth;
  final double contentVerticalPadding;
  final double contentHorizontalPadding;

  const CustomTextFieldWithButton({
    super.key,
    required this.controller,
    required this.customTextStyle,
    required this.cursorColor,
    required this.fillColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.enabledBorderColor,
    required this.borderWidth,
    required this.focusedBorderWidth,
    required this.enabledBorderWidth,
    required this.contentVerticalPadding,
    required this.contentHorizontalPadding,
  });

  @override
  _CustomTextFieldWithButtonState createState() => _CustomTextFieldWithButtonState();
}

class _CustomTextFieldWithButtonState extends State<CustomTextFieldWithButton> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: widget.fillColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: widget.customTextStyle,
              cursorColor: widget.cursorColor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.contentVerticalPadding,
                  horizontal: widget.contentHorizontalPadding,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: widget.focusedBorderColor,
                    width: widget.focusedBorderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: widget.enabledBorderColor,
                    width: widget.enabledBorderWidth,
                  ),
                ),
                suffixIcon: GestureDetector(

                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(25)),
                      color: AppColors.green,
                    ),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              obscureText: _obscureText,
            ),
          ),
        ],
      ),
    );
  }

}
