import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../colors/app_colors.dart';
import '../components/custom_button.dart';
import '../components/custom_containers.dart';
import '../components/custom_text_style.dart';
import 'package:auto_size_text/auto_size_text.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomContainer().header(context),
                ),
                const Positioned(
                  top: 55,
                  left: 0,
                  right: 0,
                  child: AutoSizeText(
                    "Lista de deseos",
                    style: CustomTextStyle.whiteSemiBold20,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 14,
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () {

                    },
                    icon: SvgPicture.asset('assets/svg/icon/Person.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
                  ),
                ),
                Positioned(
                  top: 40,
                  // Espacio mínimo desde la parte superior de la pantalla
                  right: 14,
                  // Espacio mínimo desde la parte derecha de la pantalla
                  child: CustomButton.customCircularElevatedButtonWithIcon(
                    onPressed: () {

                    },
                    icon: SvgPicture.asset('assets/svg/icon/Shopping.svg'),
                    backgroundColor: AppColors.purple3,
                    size: 70,
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