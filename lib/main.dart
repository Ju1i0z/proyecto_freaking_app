import 'package:flutter/material.dart';
import 'package:freaking/routes/app_routes.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:freaking/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding_screens/onboarding_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;

  // Verificar si hay datos de usuario guardados en shared_preferences
  //final userId = prefs.getString('userId') ?? '';

  runApp(MyApp(onboarding: onboarding));
  //runApp(MyApp(onboarding: onboarding, userId: userId));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, required this.onboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freaking',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.purple3, // Iconos, Botones de navegación inferior
          onPrimary: AppColors.white,
          primaryContainer: AppColors.purple2,
          onPrimaryContainer: AppColors.white,
          secondary: AppColors.green, // Categorías, Botón "Añadir a la cesta"
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.green,
          onSecondaryContainer: AppColors.white,
          error: AppColors.red,
          onError: AppColors.white,
          surface: AppColors.purple1, // Fondo principal de la aplicación
          onSurface: AppColors.black, // Títulos, Texto
          onSurfaceVariant: AppColors.black, // Texto en tarjetas de productos
          outline: AppColors.green, // Bordes de algunas tarjetas
          shadow: AppColors.black,
          inverseSurface: AppColors.black,
          onInverseSurface: AppColors.white,
          inversePrimary: AppColors.purple2,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.purple3, // Iconos, Botones de navegación inferior
          onPrimary: AppColors.white,
          primaryContainer: AppColors.purple2,
          onPrimaryContainer: AppColors.white,
          secondary: AppColors.green, // Categorías, Botón "Añadir a la cesta"
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.green,
          onSecondaryContainer: AppColors.white,
          error: AppColors.red,
          onError: AppColors.white,
          surface: AppColors.black3, // Fondo principal de la aplicación
          onSurface: AppColors.black, // Títulos, Texto
          onSurfaceVariant: AppColors.black, // Texto en tarjetas de productos
          outline: AppColors.green, // Bordes de algunas tarjetas
          shadow: AppColors.black,
          inverseSurface: AppColors.black,
          onInverseSurface: AppColors.white,
          inversePrimary: AppColors.purple2,
        ),
        useMaterial3: true,
      ),
      home: _getInitialScreen(),
      //initialRoute: AppRoutes.home,
      routes: AppRoutes.getRoutes(),
    );
  }
  Widget _getInitialScreen() {
    // Si hay un usuario guardado, redirige a Routes(), si no, a la pantalla de registro u onboarding
    if (onboarding) {
      return const RegisterScreen();
    } else {
      return const OnboardingView();
    }
  }
}
/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //New
  static final List<Widget> _pages = <Widget>[
    const SecondPage(),
    //SvgPicture.asset('assets/svg/icon/PointsPressed.svg'),
    SvgPicture.asset('assets/svg/icon/NewsPressed.svg'),
    SvgPicture.asset('assets/svg/icon/HomePressed.svg'),
    SvgPicture.asset('assets/svg/icon/FavoritePressed.svg'),
    SvgPicture.asset('assets/svg/icon/DetailsPressed.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      *//*appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),*//*
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.black,
        items: [
          _buildBottomNavigationBarItem(
            icon: 'assets/svg/icon/Points.svg',
            activeIcon: 'assets/svg/icon/PointsPressed.svg',
          ),
          _buildBottomNavigationBarItem(
            icon: 'assets/svg/icon/News.svg',
            activeIcon: 'assets/svg/icon/NewsPressed.svg',
          ),
          _buildBottomNavigationBarItem(
            icon: 'assets/svg/icon/Home.svg',
            activeIcon: 'assets/svg/icon/HomePressed.svg',
          ),
          _buildBottomNavigationBarItem(
            icon: 'assets/svg/icon/Favorite.svg',
            activeIcon: 'assets/svg/icon/FavoritePressed.svg',
          ),
          _buildBottomNavigationBarItem(
            icon: 'assets/svg/icon/Details.svg',
            activeIcon: 'assets/svg/icon/DetailsPressed.svg',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: _pages.elementAt(_selectedIndex), //New
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -0.4,
                child: Container(
                  color: Colors.transparent, // Fondo transparente
                  child: CustomPaint(
                    painter: BottomNavBarPainter(),
                    // Opcional: Puedes colocar cualquier widget hijo aquí si es necesario
                  ),
                ),
              ),
            ],
        ),
      ),
      ],
    ),
    );
  }
}

BottomNavigationBarItem _buildBottomNavigationBarItem({
  required String icon,
  required String activeIcon,
}) {
  return BottomNavigationBarItem(
    icon: SvgPicture.asset(icon),
    label: "",
    activeIcon: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.purple3,
          width: 3,
        ),
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple3.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset(activeIcon),
        ),
      ),
    ),
  );
}

class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, -50);  // Adjusted to reduce the height
    path.quadraticBezierTo(
      size.width * 0.0, size.height * 0.2,  // Adjusted control point
      size.width * 0.2, size.height * 0.2,  // Adjusted control point
    );
    path.lineTo(size.width * 0.8, size.height * 0.2);  // Adjusted control point
    path.quadraticBezierTo(
      size.width * 1, size.height * 0.2,  // Adjusted control point
      size.width, -50,  // Adjusted to reduce the height
    );
    path.lineTo(size.width, 0);  // Adjusted height
    path.lineTo(-50, 0);  // Adjusted height
    path.close();

    canvas.clipPath(path);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segunda Página'),
      ),
      body: Center(
        child: Text('Esta es la segunda página'),
      ),
    );
  }
}*/
