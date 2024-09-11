import 'onboarding_info.dart';

/// Clase que hace uso de la clase 'OnboardingInfo' y que contiene una lista
/// de las pantallas de la presentación de la applicación.
class OnboardingItems{
  List<OnboardingInfo> items = [

    OnboardingInfo(
        title: "¡Bievenido a Freaking!",
        description: "¡Nos alegra encontrarte por aquí! Desde Freaking,"
            " te damos las gracias por dejarnos acompañarte en tu próxima aventura. "
            "¡Permítenos ayudarte a que tu pasión no se apague!",
        image: "assets/gif/onboardingGif1.gif"),


    OnboardingInfo(
        title: "¡Comencemos!",
        description: "Encuentra prendas o artículos tan locos y únicos como tú "
            "para llevar tu fanatismo al siguiente nivel, de forma sencilla, "
            "desde cualquier parte con la nueva app de Freaking. ¡Vamos!, ¿A qué esperas?",
        image: "assets/gif/onboardingGif2.gif"),

  ];


}