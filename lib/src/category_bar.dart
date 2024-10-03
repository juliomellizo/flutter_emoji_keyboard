import 'package:flutter/material.dart';

/// Barra de categorías de emojis.
class CategoryBar extends StatefulWidget {
  final Function(int) onCategorySelected;
  final bool darkMode;

  const CategoryBar({
    Key? key,
    required this.onCategorySelected,
    required this.darkMode,
  }) : super(key: key);

  @override
  CategoryBarState createState() => CategoryBarState();
}

class CategoryBarState extends State<CategoryBar> {
  int selectedCategory = 0;

  // Actualizar categoría seleccionada externamente
  void updateSelectedCategory(int index) {
    setState(() => selectedCategory = index);
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      // Icons.access_time,
      Icons.tag_faces,
      Icons.pets,
      Icons.fastfood,
      Icons.sports_soccer,
      Icons.directions_car,
      Icons.lightbulb_outline,
      Icons.euro_symbol,
      Icons.flag,
    ];


    return Container(
      color: Colors.black.withOpacity(0.8),
      height: 50,
      child: Row(
        children: List.generate(categories.length, (index) {
          return Expanded(
            child: IconButton(
              padding: EdgeInsets.zero, // Quitar padding para ahorrar espacio
              iconSize: 24.0, // Ajusta este tamaño si es necesario
              icon: Icon(
                categories[index],
                color: selectedCategory == index ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() => selectedCategory = index);
                widget.onCategorySelected(index);
              },
            ),
          );
        }),
      ),
    );
  }
}
