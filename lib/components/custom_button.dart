import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../colors/app_colors.dart';

/// Clase que proporciona widgets de botones personalizados.
///
/// Esta clase incluye métodos para crear varios tipos de botones personalizados
/// con estilos y funcionalidades específicas.
class CustomButton {

  /// ElevatedButton personalizado con forma circular y que contiene
  /// un icono centrado y un efecto de sombra.
  ///
  /// Este widget envuelve un `ElevatedButton` con decoración adicional para hacerlo circular,
  /// aplica una sombra y centra un icono dentro del botón.
  ///
  /// Parámetros:
  /// - `onPressed`: Función de devolución de llamada que se activa cuando se presiona el botón.
  /// - `icon`: Widget `SvgPicture` que se muestra en el centro del botón.
  /// - `backgroundColor`: Color que se utiliza como fondo del botón.
  /// - `size`: Diámetro del ElevatedButton.
  static Widget customCircularElevatedButtonWithIcon({
    required VoidCallback onPressed,
    required SvgPicture icon,
    required Color backgroundColor,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Center(
            child: SimpleShadow(
              opacity: 0.5,
              color: Colors.black,
              offset: const Offset(0, 4),
              sigma: 3,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  /// ElevatedButton personalizado con texto y esquinas redondeadas.
  ///
  /// Este widget envuelve un `ElevatedButton` con una forma rectangular de esquinas redondeadas,
  /// aplica un efecto de sombra y permite personalizar el texto, colores y estilo tipográfico.
  ///
  /// Parámetros:
  /// - `onPressed`: Función de devolución de llamada que se activa cuando se presiona el botón.
  /// - `text`: Texto que se muestra dentro del botón.
  /// - `foregroundColor`: Color del texto del botón.
  /// - `backgroundColor`: Color de fondo del botón.
  /// - `customTextStyle`: Estilo tipográfico aplicado al texto del botón.
  static Widget customElevatedButtonWithText({
    required VoidCallback onPressed,
    required String text,
    required Color foregroundColor,
    required Color backgroundColor,
    required TextStyle customTextStyle,
  }) {
    return Container(
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 4,
        ),
        child: Text(text, style: customTextStyle),
      ),
    );
  }

  /// ElevatedButton personalizado con forma cuadrada de esquinas redondeadas e icono centrado.
  ///
  /// Este widget envuelve un `ElevatedButton` con un diseño cuadrado de esquinas redondeadas,
  /// aplica una sombra y coloca un icono en el centro del botón.
  ///
  /// Parámetros:
  /// - `onPressed`: Función de devolución de llamada que se activa cuando se presiona el botón.
  /// - `icon`: Widget `SvgPicture` que se muestra en el centro del botón.
  /// - `backgroundColor`: Color de fondo del botón.
  /// - `size`: Tamaño del botón (ancho y alto).
  static Widget CustomRoundedSquareElevatedButtonWithIcon({
    required VoidCallback onPressed,
    required SvgPicture icon,
    required Color backgroundColor,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Center(
            child: SimpleShadow(
              opacity: 0.5,
              color: Colors.black,
              offset: const Offset(0, 4),
              sigma: 3,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  static Widget customElevatedButtonWithTextAndPrice({
    required VoidCallback onPressed,
    required String text,
    required String price,
    required Color backgroundColor,
    required TextStyle customTextStyle,
    required TextStyle customPriceStyle,
  }) {
    return Container(
      width: 264,
      height: 34,
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
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            elevation: 4,
          ),
          child: Row(children: [
            Text(text, style: customTextStyle),
            const SizedBox(width: 20,),
            Text(price, style: customPriceStyle),
          ]
            ,)

      ),
    );
  }

  static Widget customElevatedCartButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    required Color foregroundColor,
    required Color backgroundColor,
    required TextStyle customTextStyle,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth < 375 ? 110 : 120,
      height: screenWidth < 375 ? 25 : 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          elevation: 4,
        ),
        child: Text(text, style: customTextStyle),
      ),
    );
  }

  /// Widget estático que muestra el control de cantidad “– n +” dentro de
  /// un contorno amarillo redondeado con sombra. Cada elemento (–, número, +)
  /// tiene su propio pequeño efecto de sombra.
  ///
  /// - `quantity`: valor actual a mostrar.
  /// - `onIncrement`: callback que se ejecuta al pulsar “+”.
  /// - `onDecrement`: callback que se ejecuta al pulsar “–”.
  /// - `width`: ancho fijo que tendrá el botón completo.
  static Widget customQuantityModifierButton({
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required BuildContext context,
  }) {
    return SizedBox(
      width: 110,
      child: GestureDetector(
        // Evita que los taps “caigan” al detector de la tarjeta de fondo.
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.black2_5
                : AppColors.purple1,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              /// ESPACIO IZQUIERDO: si quantity > 1 muestro el “–” con sombra,
              /// si es 1, un SizedBox (mismo tamaño) para mantener la posición.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: quantity > 1
                      ? InkWell(
                    onTap: onDecrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  )
                      : const SizedBox(width: 28, height: 28),
                ),
              ),

              /// CENTRO: cantidad con sombra de texto.
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// ESPACIO DERECHO: botón “+” con sombra.
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: onIncrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget customElevatedDetailsScreenButton({
    required VoidCallback onPressed,
    required String text,
    required Color foregroundColor,
    required Color backgroundColor,
    required TextStyle customTextStyle,
    required double buttonHeight,
    required double buttonWidth,
    required SvgPicture icon,
    required SvgPicture topLeftIcon,
    required SvgPicture topRightIcon,
    required SvgPicture bottomLeftIcon,
    required SvgPicture bottomRightIcon,
  }) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 4,
              minimumSize: Size(buttonWidth, buttonHeight),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: customTextStyle,
                  ),
                  const SizedBox(height: 10),
                  icon,
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: topLeftIcon,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: topRightIcon,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: bottomLeftIcon,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: bottomRightIcon,
          ),
        ],
      ),
    );
  }

}