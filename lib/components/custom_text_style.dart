import 'package:flutter/material.dart';
import 'package:freaking/colors/app_colors.dart';

/// Clase que proporciona estilos de texto personalizados.
///
/// Esta clase contiene la colección de estilos de texto predefinidos que se
/// usan en la aplicación. Cada estilo incluye su fuente, tamaño, grosor,
/// color y otro tipo de atributos de decoración como sombras.
class CustomTextStyle {

  /// Estilo de texto con fuente "Poppins", color verde, grosor en negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenBold16WithShadow = TextStyle(
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
  );

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorBold16WithShadow(BuildContext context) {
    return TextStyle(
    color: Theme.of(context).colorScheme.primary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en negrita, tamaño 12 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 12.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorBold12WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 11 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 11.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold11WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 11.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 12 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 12.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold12WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold20WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold20WithShadow2(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 18 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 18.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold18WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold16WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold16WithShadow2(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en semi-negrita, tamaño 15 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 15.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold15WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorBold14WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorBold20WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico, grosor en negrita, tamaño 18 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo actual (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 18.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorBold18WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          color: Color(0x40000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Estilo de texto con fuente "Poppins", color morado, grosor en negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color morado, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle purple3Bold16WithShadow = TextStyle(
    color: AppColors.purple3,
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
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold14WithShadow  = TextStyle(
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
  );

  /// Estilo de texto con fuente "Poppins", color dinámico (oscuro o claro), grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold14WithShadow(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico (oscuro o claro), grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold14WithShadow2(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color dinámico (oscuro o claro), grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color dinámico, definido por el modo (oscuro o claro).
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle dynamicColorSemiBold14WithShadowFilterHT(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
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
    );
  }

  /// Estilo de texto con fuente "Poppins", color morado, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color morado, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle purple3SemiBold14WithShadow  = TextStyle(
    color: AppColors.purple3,
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
  );

  /// Estilo de texto con fuente "Poppins", color rojo, grosor en semi-negrita, tamaño 10 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color rojo, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 10.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `shadows`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  /// PARA EL ERROR DE VALIDACIÓN DE LOS FORMULARIOS DE REGISTRO E INICIO DE SESIÓN.
  static const TextStyle redSemiBold10  = TextStyle(
    color: AppColors.red,
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
/*    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],*/
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 11 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 11.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold11WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 9.5 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 9.5.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold9_5WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold16WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color morado, grosor en semi-negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color morado, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle purple3SemiBold16WithShadow = TextStyle(
    color: AppColors.purple3,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenBold20WithShadow = TextStyle(
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
  );

  /// Estilo de texto con fuente "Poppins", color morado, grosor en negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color morado, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle purple3Bold20WithShadow = TextStyle(
    color: AppColors.purple3,
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
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold14WithShadow = TextStyle(
    color: AppColors.black,
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
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold20WithShadow = TextStyle(
    color: AppColors.black,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000), 
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle whiteSemiBold20WithShadow = TextStyle(
    color: AppColors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 12 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 12.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold12WithShadow = TextStyle(
    color: AppColors.black,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 16 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 16.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold16WithShadow = TextStyle(
    color: AppColors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4, 
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 10.5 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 10.5.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold10_5WithShadow = TextStyle(
    color: AppColors.black,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color negro, grosor en semi-negrita, tamaño 9 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color negro, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 9.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle blackSemiBold9WithShadow = TextStyle(
    color: AppColors.black,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000), 
        offset: Offset(0, 4), 
        blurRadius: 4, 
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color gris con opacidad al 50%, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color gris con opacidad al 50%, definido en la clase Colors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle greyOpacity50SemiBold14WithShadow = TextStyle(
    color: Colors.grey[850]!.withOpacity(0.50),
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: const [
      Shadow(
        color: Color(0x40000000), 
        offset: Offset(0, 4), 
        blurRadius: 4, 
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco con opacidad al 50%, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco con opacidad al 50%, definido en la clase Colors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static TextStyle whiteOpacity50SemiBold14WithShadow = TextStyle(
    color: Colors.white.withOpacity(0.50),
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: const [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenBold14WithShadow = TextStyle(
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
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en negrita, tamaño 18 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 18.
  /// - `fontWeight`: Grosor de letra en negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenBold18WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 20 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold20WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color verde, grosor en semi-negrita, tamaño 18 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color verde, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 18.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle greenSemiBold18WithShadow = TextStyle(
    color: AppColors.green,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, tamaño 14 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 14.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle whiteSemiBold14WithShadow = TextStyle(
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
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, tamaño 18 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 18.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle whiteSemiBold18WithShadow = TextStyle(
    color: AppColors.white,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, tamaño 11 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 11.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle whiteSemiBold11WithShadow = TextStyle(
    color: AppColors.white,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, tamaño 9 y sombra.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 9.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - `sombras`: Sombra de color negro, desplazamiento de (0, 4) y radio de desenfoque de 4.
  static const TextStyle whiteSemiBold9WithShadow = TextStyle(
    color: AppColors.white,
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        color: Color(0x40000000),
        offset: Offset(0, 4), 
        blurRadius: 4,
      ),
    ],
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, y tamaño 30.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 30.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  static const TextStyle whiteSemiBold30 = TextStyle(
    color: AppColors.white,
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  /// Estilo de texto con fuente "Poppins", color blanco, grosor en semi-negrita, y tamaño 20.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  static const TextStyle whiteSemiBold20= TextStyle(
    color: AppColors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  /// Estilo de texto con fuente "Poppins", color rojo, grosor en semi-negrita, tamaño 20
  /// y subrayado de color rojo.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color rojo, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  /// - 'decoration': Decoración de texto con línea de subrayado.
  /// - 'decorationColor': Color rojo, definido en la clase AppColors.
  /// - 'decorationThickness': Grosor de subrayado con tamaño de 2.
  static const TextStyle redSemiBold20Underlined = TextStyle(
    color: AppColors.red,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    decoration: TextDecoration.lineThrough,
    decorationColor: AppColors.red,
    decorationThickness: 2.0,
  );

  /// Estilo de texto con fuente "Poppins", color amarillo, grosor en semi-negrita, y tamaño 20.
  ///
  /// Parámetros preestablecidos:
  /// - `color`: Color blanco, definido en la clase AppColors.
  /// - `fontSize`: Tamaño de fuente de 20.
  /// - `fontWeight`: Grosor de letra en semi-negrita.
  /// - `fontFamily`: Fuente de letra 'Poppins' (ttf añadidos previamente en la carpeta fonts).
  static const TextStyle yellowSemiBold20 = TextStyle(
    color: AppColors.yellow,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

}
