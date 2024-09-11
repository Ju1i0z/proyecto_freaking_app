import 'package:flutter/material.dart';
import 'package:freaking/onboarding_screens/onboarding_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:freaking/routes/app_routes.dart';

import '../components/custom_navigator.dart';

/// Clase que controla la vista de las pantallas de presentación de la aplicación.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingViewState();

  }

  class _OnboardingViewState extends State<OnboardingView>{

    /// Instancia de la clase `OnboardingItems` que contiene los datos de las pantallas de presentación.
    final onboardingItems = OnboardingItems();

    /// Instancia de la clase `PageController` que se utiliza para controlar la navegación entre diferentes pantallas.
    final pageController = PageController();

    /// Variable booleana que indica si es la última pantalla de presentación.
    bool isLastPage = false;

  /// Widget que conforma la vista de las pantallas de presentación de la aplicación.
  ///
  /// Este widget construye una vista de introducción para la aplicación que utiliza 'PageView'
  /// para permitir la navegación horizontal entre las pantallas, controla el estado de la página
  /// actual con 'pageController' y hace uso de la variable 'isLastPage' para identificar si es la última página.
  ///
  /// Parámetros:
  /// - `isLastPage`: Booleano que indica si la página actual es la última página del onboarding.
  /// - `pageController`: Instancia de la clase 'PageController' que controla el desplazamiento de las páginas del PageView.
  /// - `onboardingItems`: Instancia de la clase 'OnboardingItems' que contiene los elementos de la introducción, incluyendo título, descripción e imagen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: AppColors.purple1,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isLastPage ? getStarted() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => pageController.jumpToPage(onboardingItems.items.length - 1),
              child: const Text("Saltar",
                  style: TextStyle(color: AppColors.green, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),

            SmoothPageIndicator(
              controller: pageController,
              count: onboardingItems.items.length,
              onDotClicked: (index) => pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 600), curve: Curves.easeIn),
              effect: const WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: AppColors.green,
              ),
            ),

            TextButton(
              onPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
              ),
              child: const Text("Siguiente", style: TextStyle(color: AppColors.green, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.purple1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: PageView.builder(
            onPageChanged: (index) => setState(() => isLastPage = onboardingItems.items.length - 1 == index),
            itemCount: onboardingItems.items.length,
            controller: pageController,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(onboardingItems.items[index].image),
                  const SizedBox(height: 15),
                  Text(
                    onboardingItems.items[index].title,
                    style: const TextStyle(color: AppColors.green, fontSize: 30, fontFamily: 'Poppins',fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      onboardingItems.items[index].description,
                      style: const TextStyle(color: AppColors.green, fontSize: 17, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Método que retorna un botón para finalizar las pantallas de presentación.
  ///
  /// Este método retorna un botón que al presionarlo se guarda en las preferencias compartidas
  /// que el proceso de onboarding ha sido completado para que la próxima vez que se inicie la
  /// aplicación no aparezcan las pantallas de presentación y posteriormente, se navega a la pantalla de registro.
  Widget getStarted(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.green
      ),
      width: MediaQuery.of(context).size.width * .9,
        height: 55,
        child: TextButton(
            onPressed: () async{
              final sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setBool("onboarding_screens", true);
              if(!mounted)return;
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
              CustomNavigator.instantNavigationPushNamedAndRemoveUntil(context, AppRoutes.registerScreen);
            },
            child: const Text("Comenzar", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            )
        )
    );
  }
}