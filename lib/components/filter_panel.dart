import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freaking/colors/app_colors.dart';
import 'package:freaking/components/custom_button.dart';
import '../model/category.dart';
import 'custom_text_style.dart';


/// Panel de filtros de productos.
///
/// Este widget se muestra como una ventana modal y permite al usuario filtrar la lista de productos
/// mediante un rango de precio y la selección de categorías y subcategorías.
/// - Carga dinámicamente las categorías desde Firestore.
/// - Inicializa su estado a partir de filtros previos recibidos.
/// - Muestra un `RangeSlider` para el precio.
/// - Despliega `ExpansionTile` para cada categoría, con checkbox para categorías e subcategorías.
/// - Devuelve los filtros seleccionados al widget padre al pulsar “APLICAR FILTRO”.
///
/// Además gestiona la expansión automática de las categorías según la selección previa
/// y oculta el teclado al aplicar o cerrar el panel.
///
class FilterPanel extends StatefulWidget {
  /// Mapa que contendrá todos los filtros que ya estaban activos.
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  /// Constructor que obliga a proporcionar ambos argumentos (required), garantizando que el panel siempre se inicialice con filtros previos
  /// y la función para devolver resultados.
  FilterPanel({
    required this.onFiltersApplied,
    required this.initialFilters,
  });

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {

  /// Variable que guardará el rango mínimo y máximo del slider de precio,
  /// se marca late porque se inicializa más tarde, tras recibir los datos de initialFilters.
  late RangeValues _priceRange;
  /// Variable que guarda el conjunto de IDs de las categorías padre que el usuario ha seleccionado.
  late Set<String> _selectedParentCategories;
  /// Mapa que para cada categoría padre (clave String), almacena el conjunto de IDs de subcategorías seleccionadas.
  late Map<String, Set<String>> _selectedSubCategories;
  /// Variable booleana que controla si aún se están leyendo datos de Firestore. Mientras sea true,
  /// el build() mostrará un CircularProgressIndicator.
  bool _isLoading = true;
  /// Lista de objetos Category que no tienen padre “categorías principales”.
  List<Category> _parentCategories = [];
  /// Mapa de ID de padre → lista de Category hijas. Se construye iterando sobre todas las categorías cargadas.
  Map<String, List<Category>> _subCategoriesMap = {};
  /// Mapa de ID de padre → booleano que indica si su ExpansionTile está abierto o cerrado, para recordar su estado al reabrir el panel.
  Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    /// LLamada de la función _loadCategories() que carga las categorías desde Firebase.
    _loadCategories();
  }


  /// Método para cargar y preparar las categorías desde Firestore.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Consulta todos los documentos de la colección `categories`.
  /// 2. Convierte cada documento en un objeto `Category`.
  /// 3. Filtra las categorías padre (con `parentCategoryId` como cadena vacía).
  /// 4. Agrupa las subcategorías bajo cada categoría padre.
  /// 5. Inicializa el estado interno del panel (rango de precio, selección de categorías padres e hijas y
  ///    expansión de tiles) a partir de los parámetros recibidos de `initialFilters`.
  /// 6. Actualiza la UI mediante `setState` y oculta el indicador de carga.
  /// 7. Captura y manejo de posibles errores.
  ///
  Future<void> _loadCategories() async {
    try {
      /// 1. Obtención de un snapshot de todos los documentos en `categories` de Firebase.
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();

      /// 2. Mapeo de cada documento obtenido a un objeto `Category`.
      final allCategories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();

      /// 3. Filtración de las categorías padre (sin `parentCategoryId` o vacías).
      final parentCategories = allCategories.where((c) => c.parentCategoryId == null || c.parentCategoryId!.isEmpty).toList();

      /// 4. Construcción de un mapa (categoría padre → lista de subcategorías).
      final subCategoriesMap = <String, List<Category>>{};
      for (var parentCategory in parentCategories) {
        final subCategories = allCategories.where((c) => c.parentCategoryId == parentCategory.id).toList();
        print('ParentCategory "${parentCategory.name}" (${parentCategory.id}) → ${subCategories.length} subCategories');
        subCategoriesMap[parentCategory.id] = subCategories;
      }

      /// 5. Actualización del estado del widget con los datos obtenidos:
      setState(() {
        /// Guardado de las categorías padre y el mapa de subcategorías.
        _parentCategories = parentCategories;
        _subCategoriesMap = subCategoriesMap;

        /// Inicialización del rango de precio desde `initialFilters`.
        _priceRange = widget.initialFilters['priceRange'] as RangeValues;

        /// Reconstrucción de la selección de categorías padre.
        _selectedParentCategories = Set.from(widget.initialFilters['selectedParentCategories'] as List<String>);

        /// Agrupación de los IDs de subcategorías seleccionadas por cada categoría padre.
        final initialSubcategoryIds = widget.initialFilters['selectedSubCategories'] as List<String>;
        _selectedSubCategories = {
          for (var parentCategory in parentCategories)
            parentCategory.id: initialSubcategoryIds.where((id) => subCategoriesMap[parentCategory.id]!.any((c) => c.id == id)).toSet()
        };

        /// Se determina qué tiles deben iniciarse expandidos:
        /// Se marcan las categorías padre si están seleccionadas o tienen algún hijo seleccionado.
        _expandedCategories = {
          for (var parentCategory in parentCategories)
            parentCategory.id: _selectedParentCategories.contains(parentCategory.id)
                || (_selectedSubCategories[parentCategory.id]?.isNotEmpty ?? false)
        };

        /// Se oculta el indicador de carga.
        _isLoading = false;
      });

    } catch (e, st) {
      /// 6. En caso de error, se registra y se oculta el indicador de carga.
      print('Error cargando categorías: $e\n$st');
      // Asegurarnos de inicializar incluso si falla:
      setState(() {
        _parentCategories = [];
        _subCategoriesMap    = {};
        _selectedParentCategories = {};
        _selectedSubCategories     = {};
        _expandedCategories        = {};
        _isLoading = false;
      });
    }
  }


  /// Alterna la selección de una categoría padre.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Verifica si la categoría padre (`parentCategoryId`) ya está seleccionada.
  /// 2. Si está seleccionada, la desmarca y elimina todas sus subcategorías del estado.
  /// 3. Si no está seleccionada, la marca y añade todas sus subcategorías al estado.
  /// 4. Llama a `setState` para actualizar la UI con la nueva selección.
  ///
  /// @param parentCategoryId: ID de la categoría padre a alternar.
  void _toggleParentCategory(String parentCategoryId) {
    setState(() {
      if (_selectedParentCategories.contains(parentCategoryId)) {
        /// Desmarcar padre y limpiar sus subcategorías
        _selectedParentCategories.remove(parentCategoryId);
        _selectedSubCategories[parentCategoryId]!.clear();
      } else {
        /// Marcar padre y añadir todas sus subcategorías
        _selectedParentCategories.add(parentCategoryId);
        _selectedSubCategories[parentCategoryId]!.addAll(_subCategoriesMap[parentCategoryId]!.map((c) => c.id));
      }
    });
  }

  /// Alterna la selección de una subcategoría dentro de una categoría padre.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Verifica si la subcategoría (`subCategoryId`) ya está seleccionada bajo el padre (`parentCategoryId`).
  /// 2. Si está seleccionada, la desmarca; si no, la marca.
  /// 3. Sincroniza el estado de la categoría padre:
  ///    - Si ahora están todas las subcategorías seleccionadas, marca el padre.
  ///    - Si falta alguna, desmarca el padre.
  /// 4. Llama a `setState` para actualizar la UI con los cambios.
  ///
  /// @param parentCategoryId: ID de la categoría padre que contiene la subcategoría.
  /// @param subCategoryId: ID de la subcategoría a alternar.
  void _toggleSubcategory(String parentCategoryId, String subCategoryId) {
    setState(() {
      final set = _selectedSubCategories[parentCategoryId]!;
      if (set.contains(subCategoryId)) {
        /// Desmarcar subcategoría
        set.remove(subCategoryId);
      } else {
        /// Marcar subcategoría
        set.add(subCategoryId);
      }

      /// Sincronizar padre según la selección de todas las subcategorías
      if (set.length == _subCategoriesMap[parentCategoryId]!.length) {
        _selectedParentCategories.add(parentCategoryId);
      } else {
        _selectedParentCategories.remove(parentCategoryId);
      }
    });
  }


  /// Método para aplicar los filtros seleccionados y cerrar el panel.
  ///
  /// Este método realiza las siguientes tareas:
  /// 1. Oculta el teclado desenfocando cualquier campo activo.
  /// 2. Simplifica la estructura de subcategorías seleccionadas en una lista simple.
  /// 3. Invoca el callback `onFiltersApplied` del widget padre, pasando un mapa con:
  ///    - `priceRange`: el rango de precios seleccionado.
  ///    - `selectedParentCategories`: lista de IDs de categorías padre marcadas.
  ///    - `selectedSubCategories`: lista de IDs de subcategorías marcadas.
  /// 4. Cierra el panel de filtros.
  ///
  void _applyFilters() {
    /// Se oculta el teclado si está abierto.
    FocusScope.of(context).unfocus();

    /// Simplificación de las subcategorías seleccionadas en una lista simple.
    final allSelectedSubCategories = <String>[];
    _selectedSubCategories.forEach((_, subCategories) => allSelectedSubCategories.addAll(subCategories));

    /// Envío los filtros al widget padre.
    widget.onFiltersApplied({
      'priceRange': _priceRange,
      'selectedParentCategories': _selectedParentCategories.toList(),
      'selectedSubCategories': allSelectedSubCategories,
    });

    /// Cierre del panel de filtros.
    Navigator.of(context).pop();
  }


  /// Widget que onstruye la interfaz del panel de filtros.
  ///
  /// Este widget realiza las siguientes tareas:
  /// 1. Comprueba si los datos aún están cargando y muestra un indicador de carga si es necesario.
  /// 2. Obtiene la altura disponible de la pantalla para dimensionar el contenedor.
  /// 3. Muestra un `AnimatedContainer` con animación de 300 ms y padding general.
  /// 4. Dentro de un `SizedBox`, organiza la columna principal con:
  ///    - Cabecera (título y botón de cierre).
  ///    - Dividers personalizados.
  ///    - Sección expandible de precio con un `RangeSlider` y visualización del rango.
  ///    - Sección de categorías padre como `ExpansionTile`, cada uno con:
  ///      • Checkbox propio de categoría padre.
  ///      • Grid de botones seleccionables para subcategorías.
  ///    - Botón “APLICAR FILTRO” que invoca `_applyFilters`.
  ///
  @override
  Widget build(BuildContext context) {
    /// 1. Si aún no ha cargado, mostramos indicador centrado.
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    /// Calculo de la altura de la pantalla para el contenedor.
    final screenHeight = MediaQuery.of(context).size.height;

    /// Uso de un AnimatedContainer como contenedor principal con padding uniforme.
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16),
      child: SizedBox(
        /// Limitación de la altura a un 72% de la pantalla.
        height: screenHeight * 0.72,
        child: Column(
          children: [
            /// Cabecera con título y botón de cierre.
            Row(
              children: [
                Text('Filtro de productos',
                    style: CustomTextStyle.dynamicColorSemiBold20WithShadow(context)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            /// Línea divisoria con color según el tema actual de la aplicación.
            Divider(
              thickness: 3,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.purple3
                  : AppColors.green,
            ),
            /// Área expandible con secciones de precio y categorías.
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  /// Sección de rango de precio.
                  Text('Precio',
                      style:
                      CustomTextStyle.dynamicColorSemiBold18WithShadow(context)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      valueIndicatorTextStyle:
                      CustomTextStyle.whiteSemiBold20WithShadow,
                      valueIndicatorColor:
                      Theme.of(context).colorScheme.primary,
                      activeTrackColor:
                      Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      thumbColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000,
                      divisions: 50,
                      labels: RangeLabels(
                          _priceRange.start.round().toString(),
                          _priceRange.end.round().toString()),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                      'Rango: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                      style:
                      CustomTextStyle.dynamicColorSemiBold16WithShadow(context)),
                  SizedBox(height: 20),
                  /// Sección de categorías y subcategorías.
                  Text('Categorías',
                      style:
                      CustomTextStyle.dynamicColorSemiBold18WithShadow(context)),
                  /// Se recorre _parentCategories y, usando el spread operator (…),
                  /// se genera un ExpansionTile por cada categoría padre en la lista de subcategorias.
                    ..._parentCategories.map((parent) {
                    final subCategories = _subCategoriesMap[parent.id]!;
                    return ExpansionTile(
                      /// Expansión inicial de cada categoría padre controlada
                      initiallyExpanded: _expandedCategories[parent.id] ?? false,
                      /// Actualización del estado cada vez que el usuario abra o cierre el panel de filtros.
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedCategories[parent.id] = expanded;
                        });
                      },
                      collapsedIconColor: Theme.of(context).colorScheme.primary,
                      iconColor: Theme.of(context).colorScheme.primary,
                      childrenPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      tilePadding: EdgeInsets.zero,
                      collapsedBackgroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      collapsedShape: RoundedRectangleBorder(),
                      shape: RoundedRectangleBorder(),
                      title: Row(
                        children: [
                          Expanded(
                              child: Text(parent.name,
                                  style: CustomTextStyle.dynamicColorSemiBold16WithShadow(context))),
                          IconButton(
                            icon: Icon(
                              _selectedParentCategories.contains(parent.id)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _toggleParentCategory(parent.id),
                          )
                        ],
                      ),
                      /// Contenedor para el GridView de las subcategorías con padding.
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          /// Uso de un GridView.builder para mostrar cada subcategoría en forma de botón.
                          child: GridView.builder(
                            /// Propiedad que hace que el grid mida sólo el espacio que necesita, en lugar de ocupar más.
                            shrinkWrap: true,
                            /// Propiedad que  desactiva su propio scroll, por lo que el ListView padre es el que gestiona
                            /// el desplazamiento de toda la pantalla.
                            physics: NeverScrollableScrollPhysics(),
                            /// Definición de la cuadrícula que crea un diseño con un número fijo de mosaicos a lo largo del eje transversal.
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, /// 3 columnas.
                              crossAxisSpacing: 6, /// 6 px entre columnas.
                              mainAxisSpacing: 12, /// 12 px entre filas.
                              childAspectRatio: 2.5, /// cada celda es 2.5 veces más ancha que alta (ancho/alto = 2.5).
                            ),
                            /// Número de elementos que contendrá el GridView.
                            itemCount: subCategories.length,
                            /// Construcción de cada celda
                            itemBuilder: (_, i) {
                              /// Obtención de la subcategoría.
                              final subcategory = subCategories[i];
                              /// Variable que comprobará si la subcategoría está seleccionada.
                              final isSelected = _selectedSubCategories[parent.id]!.contains(subcategory.id);
                              /// Se envuelve el botón en un SizedBox forzando cada celda a tener 70 px de alto.
                              return SizedBox(
                                height: 70,
                                  /// ElevatedButton que cambia de apariencia según si está seleccionada o no (_toggleSubcategory).
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                    side: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                  onPressed: () =>
                                      _toggleSubcategory(parent.id, subcategory.id),
                                  child: Text(
                                    subcategory.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    );
                  }),
                ],
              ),
            ),
            /// Línea divisoria final.
            Divider(
              thickness: 3,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.purple3
                  : AppColors.green,
            ),

            /// Botón de acción para aplicar los filtros seleccionados.
            CustomButton.customElevatedButtonWithText(
              onPressed: _applyFilters,
              text: 'APLICAR FILTRO',
              foregroundColor: AppColors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              customTextStyle: CustomTextStyle.whiteSemiBold14WithShadow,
            ),
          ],
        ),
      ),
    );
  }
}


