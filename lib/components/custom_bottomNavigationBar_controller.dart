import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:freaking/screens/details_screen.dart';
import 'package:freaking/screens/favorite_screen.dart';
import 'package:freaking/screens/home_screen.dart';
import 'package:freaking/screens/news_screen.dart';
import 'package:freaking/screens/points_store_screen.dart';

/// Clase controlador del BottomNavigationBar personalizado.
///
/// Este widget proporciona una barra de navegación inferior que muestra una página central predefinida,
/// contiene íconos personalizados y un resaltado circular para el elemento seleccionado.
///
/// El widget gestiona el estado del índice seleccionado y proporciona navegación entre las pantallas
/// `PointsStoreScreen`, `NewsScreen`, `HomeScreen`, `FavoriteScreen` y `DetailsScreen`.
class CustomBottomNavBarController extends StatefulWidget {
  const CustomBottomNavBarController({super.key});

  /// Estado para el widget de la barra de navegación inferior.
  ///
  /// Esta función configura el estado necesario para que funcione la barra de navegación inferior.
  /// Devuelve una instancia de `_CustomBottomNavBarControllerState`, donde se maneja la lógica del widget.
  @override
  _CustomBottomNavBarControllerState createState() => _CustomBottomNavBarControllerState();
}

/// Clase que maneja el estado y la lógica del menú del BottomNavigationBar.
///
/// Esta clase controla el botón que está seleccionado y actualiza la pantalla
/// cuando se presiona un botón diferente la barra de naveación inferior.
class _CustomBottomNavBarControllerState extends State<CustomBottomNavBarController> {
  /// Variable que representa el indice seleccionado y que por defecto
  /// está seleccionado el índice 2.
  int _selectedIndex = 2;

  /// Función que maneja el evento de toque en los elementos de la barra de navegación inferior.
  /// Actualiza el estado para reflejar el índice actual seleccionado.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Lista de widgets que contiene las clases de las patallas que se manejan cuando
  /// se selecciona cada botón del menú.
  static final List<Widget> _pages = <Widget>[
    const PointsStoreScreen(),
    const NewsScreen(),
    const HomeScreen(),
    const FavoriteScreen(),
    const DetailsScreen()
  ];

  /// Item del BottomNavigationBar personalizado.
  ///
  /// Este método construye un ítem del BottomNavigationBar personalizado que incluye
  /// iconos pedidos por parámetros para cuando el item esté seleccionado o no
  /// y añade sombra a estos.
  ///
  /// Parámetros:
  /// - `icon`: Icono por defecto del item cuando este no está seleccionado.
  /// - `activeIcon`: Icono que se muestra cuando el ítem está seleccionado.
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

  /// Widget que forma el BottomNavigationBar personalizado de la aplicación.
  ///
  /// Widget que conforma el BottomNavigationBar personalizado principal de la aplicación y que se sirve del método
  /// '_buildBottomNavigationBarItem' para crear los items personalizdos del BottomNavigationBar,
  /// la variable '_selectedIndex' para controlar el índice actual y la lista de pantallas y función '_onItemTapped'
  /// para controlar el botón que se pulsa en el BottomNavigationBar.
  ///
  /// Parámetros:
  /// - `showUnselectedLabels`: Indica que no se muestra la etiqueta de los botones no seleccionados ya que está en 'False'.
  /// - `showSelectedLabels`: Indica que no se muestra la etiqueta del botón seleccionado ya que está en 'False'.
  /// - `type`: Indica el tipo del BottomNavigationBar, en este caso, fijo.
  /// - `backgroundColor`: Indica el color de fondo de la barra de navegación.
  /// - `items`: Lista de BottomNavigationBarItem que se mostrarán en la barra de navegación, cada uno con un ícono para el estado seleccionado y no seleccionado.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
                  child: _pages.elementAt(_selectedIndex),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -0.4,
                  child: Container(
                    color: Colors.transparent,
                    child: CustomPaint(
                      painter: BottomNavBarPainter(),
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

/// Clase que extiende de la clase CustomPainter y que dibuja un fondo personalizado
/// para el BottomNavigationBar.
///
/// Esta clase utiliza un lienzo para dibujar un fondo con curvas suaves en el menú
/// de navegación inferior.
class BottomNavBarPainter extends CustomPainter {
  // Sobrescribe el método `paint` de la clase `CustomPainter`. Este método se encarga de dibujar en el lienzo.
  @override
  void paint(Canvas canvas, Size size) {
    // Crea un objeto `Paint` que define cómo se dibuja en el lienzo.
    final paint = Paint()
      ..color = AppColors.black  // Establece el color de la pintura a negro.
      ..style = PaintingStyle.fill;  // Establece el estilo de pintura a relleno (fill).

    // Crea un objeto `Path` para definir una forma personalizada.
    final path = Path();

    // Mueve el punto de inicio del `Path` a (0, -50).
    path.moveTo(0, -50);  // Ajustado para reducir la altura.

    // Dibuja una curva cuadrática desde el punto actual a (size.width * 0.2, size.height * 0.2)
    // usando el punto de control (size.width * 0.0, size.height * 0.2).
    path.quadraticBezierTo(
      size.width * 0.0, size.height * 0.2,  // Punto de control ajustado.
      size.width * 0.2, size.height * 0.2,  // Punto de destino ajustado.
    );

    // Dibuja una línea recta desde el punto actual a (size.width * 0.8, size.height * 0.2).
    path.lineTo(size.width * 0.8, size.height * 0.2);  // Punto de destino ajustado.

    // Dibuja otra curva cuadrática desde el punto actual a (size.width, -50)
    // usando el punto de control (size.width * 1, size.height * 0.2).
    path.quadraticBezierTo(
      size.width * 1, size.height * 0.2,  // Punto de control ajustado.
      size.width, -50,  // Punto de destino ajustado para reducir la altura.
    );

    // Dibuja una línea recta desde el punto actual a (size.width, 0).
    path.lineTo(size.width, 0);  // Altura ajustada.

    // Dibuja una línea recta desde el punto actual a (-50, 0).
    path.lineTo(-50, 0);  // Altura ajustada.

    // Cierra el camino, conectando el punto actual de vuelta al punto de inicio.
    path.close();

    // Recorta el área de dibujo para que solo lo que esté dentro del camino definido se dibuje.
    canvas.clipPath(path);

    // Dibuja el camino en el lienzo usando la pintura definida anteriormente.
    canvas.drawPath(path, paint);
  }

  // Sobrescribe el método `shouldRepaint` para indicar si el pintor debe volver a pintar.
  // Como el diseño es estático y no cambia, devuelve `false`.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
