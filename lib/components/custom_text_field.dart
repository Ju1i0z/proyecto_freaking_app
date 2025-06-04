import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freaking/components/custom_text_style.dart';
import 'package:simple_shadow/simple_shadow.dart';

import 'package:freaking/colors/app_colors.dart';

class CustomTextField {

  /// Función para crear un campo de texto personalizado.
  ///
  /// Esta función devuelve un `Widget` que representa un campo de texto personalizado con varias configuraciones estéticas y de comportamiento.
  ///
  /// Parámetros:
  /// - `controller`: Controlador del texto.
  /// - `customTextStyle`: Estilo personalizado para el texto en el campo.
  /// - `cursorColor`: Color del cursor en el campo.
  /// - `fillColor`: Color de fondo del campo.
  /// - `borderColor`: Color del borde del campo.
  /// - `focusedBorderColor`: Color del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderColor`: Color del borde cuando el campo está habilitado.
  /// - `borderWidth`: Ancho del borde.
  /// - `focusedBorderWidth`: Ancho del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderWidth`: Ancho del borde cuando el campo está habilitado.
  /// - `contentVerticalPadding`: Padding vertical del contenido dentro del campo.
  /// - `contentHorizontalPadding`: Padding horizontal del contenido dentro del campo.
  /// - `validator`: Función de validación que devuelve un mensaje de error en caso de no pasar la validación.
  static Widget customTextFormField({
    required TextEditingController controller,
    required TextStyle customTextStyle,
    required Color cursorColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color enabledBorderColor,
    required double borderWidth,
    required double focusedBorderWidth,
    required double enabledBorderWidth,
    required double contentVerticalPadding,
    required double contentHorizontalPadding,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: fillColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: customTextStyle,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: contentVerticalPadding,
            horizontal: contentHorizontalPadding,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: focusedBorderColor,
              width: focusedBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: enabledBorderColor,
              width: enabledBorderWidth,
            ),
          ),
          errorStyle: CustomTextStyle.redSemiBold10, // Estilo para mensajes de error.
        ),
        validator: validator, // Función de validación.
      ),
    );
  }

  /// Función para crear un campo de texto simple.
  ///
  /// Esta función devuelve un `Widget` que representa un campo de texto simple sin funcionalidades adicionales.
  ///
  /// Parámetros:
  /// - `controller`: Controlador del texto.
  /// - `customTextStyle`: Estilo personalizado para el texto en el campo.
  /// - `cursorColor`: Color del cursor en el campo.
  /// - `fillColor`: Color de fondo del campo.
  /// - `borderColor`: Color del borde del campo.
  /// - `focusedBorderColor`: Color del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderColor`: Color del borde cuando el campo está habilitado.
  /// - `borderWidth`: Ancho del borde.
  /// - `focusedBorderWidth`: Ancho del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderWidth`: Ancho del borde cuando el campo está habilitado.
  /// - `contentVerticalPadding`: Padding vertical del contenido dentro del campo.
  /// - `contentHorizontalPadding`: Padding horizontal del contenido dentro del campo.
  static Widget customField({
    required TextEditingController controller,
    required TextStyle customTextStyle,
    required Color cursorColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color enabledBorderColor,
    required double borderWidth,
    required double focusedBorderWidth,
    required double enabledBorderWidth,
    required double contentVerticalPadding,
    required double contentHorizontalPadding,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: fillColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: customTextStyle,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: contentVerticalPadding,
            horizontal: contentHorizontalPadding,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: focusedBorderColor,
              width: focusedBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: enabledBorderColor,
              width: enabledBorderWidth,
            ),
          ),
        ),
      ),
    );
  }

  /// Función para crear un campo de texto con funcionalidades de filtrado.
  ///
  /// Esta función devuelve un `Widget` que representa un campo de texto con opciones adicionales,
  /// como un ícono interactivo, manejo de eventos al enviar el texto y cambios en el contenido.
  ///
  /// Parámetros:
  /// - `controller`: Controlador del texto.
  /// - `customTextStyle`: Estilo personalizado para el texto en el campo.
  /// - `cursorColor`: Color del cursor en el campo.
  /// - `fillColor`: Color de fondo del campo.
  /// - `borderColor`: Color del borde del campo.
  /// - `focusedBorderColor`: Color del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderColor`: Color del borde cuando el campo está habilitado.
  /// - `borderWidth`: Ancho del borde.
  /// - `focusedBorderWidth`: Ancho del borde cuando el campo está en estado enfocado.
  /// - `enabledBorderWidth`: Ancho del borde cuando el campo está habilitado.
  /// - `contentVerticalPadding`: Padding vertical del contenido dentro del campo.
  /// - `contentHorizontalPadding`: Padding horizontal del contenido dentro del campo.
  /// - `hintText`: Texto de sugerencia que se muestra cuando el campo está vacío.
  /// - `hintStyle`: Estilo del texto de sugerencia.
  /// - `prefixIcon`: Ícono que se muestra antes del texto en el campo.
  /// - `onIconTap`: Función que se ejecuta al hacer clic en el ícono.
  /// - `onFieldSubmitted`: Función que se ejecuta cuando se envía el texto del campo.
  /// - `onChanged`: Función que se ejecuta cuando el contenido del campo cambia.
  static TextFormField filterField({
    required TextEditingController controller,
    required TextStyle customTextStyle,
    required Color cursorColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color enabledBorderColor,
    required double borderWidth,
    required double focusedBorderWidth,
    required double enabledBorderWidth,
    required double contentVerticalPadding,
    required double contentHorizontalPadding,
    required String hintText,
    required TextStyle hintStyle,
    required SvgPicture prefixIcon,
    required VoidCallback onIconTap,
    required void Function(String)? onFieldSubmitted,
    required void Function(String)? onChanged,
  }) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      style: customTextStyle,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 10.0, top: 5.0),
          child: SimpleShadow(
            opacity: 0.5,
            color: Colors.black,
            offset: const Offset(0, 4),
            sigma: 3,
            child: GestureDetector(
              onTap: onIconTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                child: prefixIcon,
              ),
            ),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: focusedBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: enabledBorderColor,
            width: enabledBorderWidth,
          ),
        ),
      ),
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
    );
  }


}

class CustomPasswordTextFormFieldWithButton extends StatefulWidget {
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
  final String? Function(String?)? validator;

  const CustomPasswordTextFormFieldWithButton({
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
    required this.validator,
  });

  @override
  _CustomPasswordTextFormFieldWithButtonState createState() => _CustomPasswordTextFormFieldWithButtonState();
}

class _CustomPasswordTextFormFieldWithButtonState extends State<CustomPasswordTextFormFieldWithButton> {
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
            child: TextFormField(
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
                errorStyle: CustomTextStyle.redSemiBold10, // Estilo para mensajes de error.
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(25)),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              obscureText: _obscureText, // Controla la visibilidad del texto ingresado.
              validator: widget.validator, // Función de validación.
            ),
          ),
        ],
      ),
    );
  }


}



