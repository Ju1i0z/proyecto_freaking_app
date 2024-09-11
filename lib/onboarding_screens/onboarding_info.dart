/// Clase que representa la información de una pantalla de introducción.
///
/// Esta clase almacena el título, la descripción y la imagen que se mostrarán en una pantalla
/// de introducción. Es útil para estructurar los datos necesarios para una experiencia de usuario
/// introductoria.
class OnboardingInfo{
  final String title;
  final String description;
  final String image;

  OnboardingInfo({required this.title, required this.description, required this.image});

}