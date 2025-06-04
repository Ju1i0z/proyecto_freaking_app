import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freaking/components/custom_text_style.dart';
import 'package:freaking/routes/app_routes.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:freaking/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/custom_bottomNavigationBar_controller.dart';
import 'onboarding_screens/onboarding_view.dart';
import 'firebase_options.dart';


// Función principal que se ejecuta al iniciar la aplicación.
Future<void> main() async {
  // Método estático proporcionado por Flutter que asegura que los widgets estén inicializados antes de realizar cualquier operación.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con un nombre personalizado y las configuraciones específicas de la plataforma.
  await Firebase.initializeApp(
    name: 'freaking',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Obtención de una instancia de SharedPreferences para acceder a datos persistentes.
  final prefs = await SharedPreferences.getInstance();

  // Verificación para comprobar si el usuario vió las pantallas de onboarding por primera vez y asigna `false` por defecto si no existe el valor.
  final onboarding = prefs.getBool("onboarding") ?? false;

  // Verificación para comprobar si hay datos de usuario guardados en shared_preferences.
  final stripeCustomerId = prefs.getString('stripeCustomerId') ?? '';

  // Método que ejecuta la aplicación, pasando los datos iniciales como parámetros.
  runApp(MyApp(onboarding: onboarding, stripeCustomerId: stripeCustomerId));
}

// Clase principal de la aplicación.
class MyApp extends StatelessWidget {
  // Variable que indica si el usuario ya pasó por las pantallas de onboarding.
  final bool onboarding;
  // Variable que refleja el ID de cliente de Stripe para identificar un usuario.
  final String stripeCustomerId;

  // Constructor de la clase.
  const MyApp({
    super.key,
    required this.onboarding,
    required this.stripeCustomerId,
  });


  @override
  Widget build(BuildContext context) {
    // Widget que construye la estructura de la aplicación.
    return MaterialApp(
      // Título de la aplicación.
      title: 'Freaking',
      // Tema claro de la aplicación.
      theme: ThemeData(
        fontFamily: 'Poppins', // Fuente principal.
        colorScheme: ColorScheme.light(
          primary: AppColors.green, // Color principal para el texto en el tema claro.
          onPrimary: AppColors.white,
          surface: AppColors.purple1, // Color de superficies para el fondo de las pantallas principales.
          onSurface: AppColors.purple2,
          secondary: AppColors.black,
          tertiary: AppColors.white,

        ),
        textTheme: TextTheme(
          headlineLarge: CustomTextStyle.blackSemiBold20WithShadow, // Estilo de texto principal.
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.purple1, // Fondo de diálogos
          titleTextStyle: CustomTextStyle.greenBold20WithShadow, // Estilo del título en diálogos.
          contentTextStyle: CustomTextStyle.greenSemiBold16WithShadow, // Estilo del contenido en diálogos.
        ),
        useMaterial3: true, // Activa las características de Material Design 3.
      ),

      // Tema oscuro de la aplicación.
      darkTheme: ThemeData(
        fontFamily: 'Poppins', // Fuente principal.
        colorScheme: ColorScheme.dark(
          primary: AppColors.purple3, // Color principal para el texto en el tema oscuro.
          onPrimary: AppColors.black,
          surface: AppColors.black3, // Color de superficies.
          onSurface: AppColors.black3,
          secondary: AppColors.white,
          tertiary: AppColors.black2_5,
        ),
        textTheme: TextTheme(
          headlineLarge: CustomTextStyle.whiteSemiBold20WithShadow, // Estilo de texto principal.
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.black3, // Fondo de diálogos.
          titleTextStyle: CustomTextStyle.purple3Bold20WithShadow, // Estilo del título en diálogos.
          contentTextStyle: CustomTextStyle.purple3SemiBold14WithShadow, // Estilo del contenido en diálogos.
        ),
        useMaterial3: true, // Activa las características de Material Design 3.
      ),

      // Pantalla inicial de la aplicación.
      home: _getInitialScreen(),

      // Define las rutas disponibles en la aplicación.
      routes: AppRoutes.getRoutes(),
    );
  }

  // Determina cuál será la pantalla inicial según los datos persistentes.
  Widget _getInitialScreen() {
    // Si hay un usuario guardado, muestra la barra de navegación inferior.
    if (stripeCustomerId.isNotEmpty) {
      return const CustomBottomNavBarController();
      // Si el usuario completó el onboarding, muestra la pantalla de registro.
    } else if (onboarding) {
      return const RegisterScreen();
      // Si no, muestra las pantallas de onboarding.
    } else {
      return const OnboardingView();
    }
  }
}
