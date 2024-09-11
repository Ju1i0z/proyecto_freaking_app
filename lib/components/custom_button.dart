import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_shadow/simple_shadow.dart';

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
}