import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'emoji_grid.dart';
import 'emoji/activities.dart';
import 'emoji/animals.dart';
import 'emoji/flags.dart';
import 'emoji/foods.dart';
import 'emoji/objects.dart';
import 'emoji/smileys.dart';
import 'emoji/symbols.dart';
import 'emoji/travel.dart';

/// Página de emojis que contiene todos los grids de emojis.
class EmojiPage extends StatefulWidget {
  final double emojiKeyboardHeight;
  final Function(String) onEmojiSelected;
  final List<String> recentEmojis;
  final Function(int)? onPageChanged; // Añadido
  final Function(bool)? onScroll; // Añadido

  EmojiPage({
    Key? key,
    required this.emojiKeyboardHeight,
    required this.onEmojiSelected,
    required this.recentEmojis,
    this.onPageChanged, // Añadido
    this.onScroll, // Añadido
  }) : super(key: key);

  @override
  EmojiPageState createState() => EmojiPageState();
}

class EmojiPageState extends State<EmojiPage> {
  // Controlador de la página para manejar el desplazamiento entre categorías.
  final PageController _pageController = PageController(initialPage: 0);

  // Mapas para almacenar los emojis por categoría.
  final Map<int, List<String>> _emojisByCategory = {};
  final List<String> _categories = [
    'Recent',
    'Smileys',
    'Animals',
    'Foods',
    'Activities',
    'Travel',
    'Objects',
    'Symbols',
    'Flags',
  ];

  bool _isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    _loadEmojis();

    // Añadir listener al PageController para detectar el scroll
    _pageController.addListener(_onPageViewScroll);
  }

  // Método para navegar a una categoría específica
  void navigateToCategory(int categoryIndex) {
    _pageController.jumpToPage(categoryIndex);
  }

  // Cargar emojis de las diferentes categorías.
  void _loadEmojis() {
    // _emojisByCategory[0] = widget.recentEmojis;
    _emojisByCategory[0] = _extractEmojis(smileysList);
    _emojisByCategory[1] = _extractEmojis(animalsList);
    _emojisByCategory[2] = _extractEmojis(foodsList);
    _emojisByCategory[3] = _extractEmojis(activitiesList);
    _emojisByCategory[4] = _extractEmojis(travelList);
    _emojisByCategory[5] = _extractEmojis(objectsList);
    _emojisByCategory[6] = _extractEmojis(symbolsList);
    _emojisByCategory[7] = _extractEmojis(flagsList);
  }

  // Método actualizado
  List<String> _extractEmojis(List<dynamic> emojiList) {
    return emojiList.map((e) {
      if (e is List && e.isNotEmpty) {
        return e[0] as String;
      } else if (e is Map && e.containsKey('emoji')) {
        return e['emoji'] as String;
      } else if (e is String) {
        return e;
      } else {
        return '';
      }
    }).toList();
  }

  // Detectar el scroll en el PageView
  void _onPageViewScroll() {
    if (_pageController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        widget.onScroll?.call(true);
      }
    } else if (_pageController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        widget.onScroll?.call(false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageViewScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.emojiKeyboardHeight - 50,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _categories.length,
        onPageChanged: (index) {
          widget.onPageChanged?.call(index);
        },
        itemBuilder: (context, index) {
          final emojis = _emojisByCategory[index] ?? [];
          return EmojiGrid(
            emojis: emojis,
            onEmojiSelected: widget.onEmojiSelected,
          );
        },
      ),
    );
  }
}
