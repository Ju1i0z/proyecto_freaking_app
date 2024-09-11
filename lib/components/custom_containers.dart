import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../colors/app_colors.dart';

/// Clase que contiene diferentes elementos personalizados.
///
/// Esta clase contiene Widgets y elementos visuales personalizados para distintos apartados
/// de la aplicación como el contenedor donde aparece el titulo de cada pantalla.
class CustomContainer{

  /// Widget que representa el logotipo principal de la aplicación que se situa dentro de un contenedor cuadrado con sombra.
  ///
  /// Este método construye un widget `AspectRatio` que contiene un `Stack` con un contenedor
  /// y una imagen centrada dentro de él.
  Widget logoIcon() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
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
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget que representa el contenedor curvo que aparece en la parte superior de la aplicación
  /// y actua como fondo para el encabezado de cada pantalla.
  ///
  /// Este método construye un widget `SimpleShadow` que aplica una sombra a
  /// un `ClipPath` que recorta el borde inferior de un `Container` de color negro.
  ///
  /// Parámetros preestablecidos:
  /// - `SimpleShadow`: Añade una sombra al contenedor.
  ///   - `opacity`: Opacidad de la sombra (0.5).
  ///   - `color`: Color de la sombra (negro).
  ///   - `offset`: Desplazamiento de la sombra (0 en X, 4 en Y).
  ///   - `sigma`: Radio de desenfoque de la sombra (3).
  ///
  /// - `ClipPath`: Recorta el contenedor de acuerdo con la forma definida en `_HeaderBottomClipper`.
  ///   - `clipper`: Instancia de `_HeaderBottomClipper`, que define la forma del recorte.
  ///
  /// - `Container`: Contenedor recortado con un alto de 150 píxeles y un ancho que ocupa el ancho de la pantalla.
  ///   - `height`: Altura del contenedor (150 píxeles).
  ///   - `width`: Ancho del contenedor (ancho total de la pantalla, obtenido con `MediaQuery`).
  ///   - `decoration`: Color de fondo del contenedor (negro).
  Widget header(BuildContext context) {
    return SimpleShadow(
      opacity: 0.5,
      color: Colors.black,
      offset: const Offset(0, 4),
      sigma: 3,
      child: ClipPath(
        clipper: _HeaderBottomClipper(),
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Clase que define un recorte personalizado para el contenedor que actua de fondo para el encabezado de cada pantalla.
///
/// `_HeaderBottomClipper` extiende `CustomClipper<Path>` y se utiliza para
/// crear un recorte personalizado para el widget del contenedor que actua de fondo para el encabezado de cada pantalla.
class _HeaderBottomClipper extends CustomClipper<Path> {

  /// Método que define el camino del recorte.
  ///
  /// `getClip` toma un objeto `Size` como parámetro y devuelve un objeto `Path`
  /// que describe el camino del recorte.
  ///
  /// - `size`: Tamaño del widget a recortar.
  ///
  /// El camino se define de la siguiente manera:
  /// - Mueve el punto inicial a la esquina superior izquierda.
  /// - Dibuja una línea recta hasta el punto (0, `size.height - 70`).
  /// - Dibuja una curva cuadrática desde este punto hasta la parte inferior
  ///   del widget (`size.height`), pasando por el punto de control en el centro
  ///   (`size.width / 2, size.height`).
  /// - Dibuja una línea recta desde la parte inferior hasta la esquina superior
  ///   derecha del widget.
  ///
  /// Retorna:
  /// - `Path`: El camino del recorte.
  /// -
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 70); // Parte superior izquierda
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width,
        size.height - 70); // Curva en la parte inferior
    path.lineTo(size.width, 0); // Parte superior derecha
    return path;
  }

  /// Método que determina si el clip debe volver a calcularse.
  ///
  /// `shouldReclip` toma una instancia de `CustomClipper<Path>` como parámetro
  /// y devuelve un valor booleano. En este caso, siempre retorna `false`
  /// ya que el clip no necesita recalcularse.
  ///
  /// Parámetros:
  /// - `oldClipper`: La instancia previa de `CustomClipper<Path>`.
  ///
  /// Retorna:
  /// - `bool`: `false`, indicando que el clip no necesita recalcularse.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}