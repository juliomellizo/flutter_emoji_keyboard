import 'dart:io';
import 'package:emoji_keyboard_flutter/src/util/emoji.dart';
import 'package:emoji_keyboard_flutter/src/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'bottom_bar.dart';
import 'category_bar.dart';
import 'emoji_page.dart';
import 'emoji_searching.dart';

/// Teclado de Emojis personalizado.
/// Incluye la barra de categorías, la barra inferior y las páginas de emojis.
class EmojiKeyboard extends StatefulWidget {
  final TextEditingController emotionController;
  final double emojiKeyboardHeight;
  final bool showEmojiKeyboard;
  final bool darkMode;
  final Function(String)? onEmojiSelected;

  EmojiKeyboard({
    Key? key,
    required this.emotionController,
    this.emojiKeyboardHeight = 350,
    this.showEmojiKeyboard = true,
    this.darkMode = false,
    this.onEmojiSelected,
  }) : super(key: key);

  @override
  _EmojiKeyboardState createState() => _EmojiKeyboardState();
}

class _EmojiKeyboardState extends State<EmojiKeyboard> {
  // Controladores y variables necesarias
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusSearchEmoji = FocusNode();
  final Storage storage = Storage();

  List<String> searchedEmojis = [];
  List<Emoji> recentEmojis = [];
  bool searchMode = false;
  bool showBottomBar = true;

  // Claves GlobalKey para acceder al estado de los widgets hijos
  final GlobalKey<CategoryBarState> categoryBarKey =
      GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarKey = GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageKey = GlobalKey<EmojiPageState>();

  @override
  void initState() {
    super.initState();
    // Cargar emojis recientes desde el almacenamiento
    //_loadRecentEmojis();
    // Configurar el interceptor del botón de retroceso
    BackButtonInterceptor.add(_onBackPressed);
    // Escuchar cambios en la visibilidad del teclado
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible && searchMode) {
        setState(() => searchMode = false);
      }
    });
  }

  @override
  void dispose() {
    focusSearchEmoji.dispose();
    BackButtonInterceptor.remove(_onBackPressed);
    super.dispose();
  }

  // Cargar emojis recientes
  Future<void> _loadRecentEmojis() async {
    final emojis = await storage.fetchAllEmojis();
    recentEmojis = List.from(emojis, growable: true);
    print('Loaded ${recentEmojis.length} recent emojis');
    setState(() {});
  }

  // Interceptar el botón de retroceso
  bool _onBackPressed(bool stopDefaultButtonEvent, RouteInfo info) {
    if (searchMode) {
      setState(() => searchMode = false);
      return true;
    }
    return false;
  }

  // Manejar la selección de categoría
  void _onCategorySelected(int categoryIndex) {
    emojiPageKey.currentState?.navigateToCategory(categoryIndex);
  }

  // Actualizar la categoría seleccionada
  void _onPageChanged(int pageIndex) {
    categoryBarKey.currentState?.updateSelectedCategory(pageIndex);
  }

  // Mostrar u ocultar la barra inferior
  void _onEmojiScroll(bool isScrollingDown) {
    if (showBottomBar != !isScrollingDown) {
      setState(() => showBottomBar = !isScrollingDown);
    }
  }

  // Iniciar búsqueda de emojis
  void _startSearch() {
    setState(() => searchMode = true);
    focusSearchEmoji.requestFocus();
  }

  // Actualizar resultados de búsqueda
  void _onSearchTextChanged(String text) {
    setState(() {
      searchedEmojis = searchEmojis(text);
    });
  }

  // Insertar emoji en el controlador de texto
  void _insertEmoji(String emoji) {
    widget.onEmojiSelected?.call(emoji);
    //_addToRecentEmojis(emoji);
  }

  // Agregar emoji a la lista de recientes
  Future<void> _addToRecentEmojis(String emoji) async {
    final existingEmoji = recentEmojis.firstWhere(
      (e) => e.emoji == emoji,
      orElse: () => Emoji(emoji, 0),
    );

    existingEmoji.increase();

    int result;
    if (recentEmojis.contains(existingEmoji)) {
      result = await storage.updateEmoji(existingEmoji);
      print('Updated emoji: ${existingEmoji.emoji}, result: $result');
    } else {
      result = await storage.addEmoji(existingEmoji);
      print('Added emoji: ${existingEmoji.emoji}, result: $result');
      setState(() {
        recentEmojis.add(existingEmoji);
      });
    }
  }

  // Construir el widget
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final keyboardHeight = widget.showEmojiKeyboard
        ? (isPortrait ? widget.emojiKeyboardHeight : 150.0)
        : 0.0;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Teclado de emojis
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: keyboardHeight,
            color: Color(0xFF373737),
            child: Column(
              children: [
                // Barra de categorías
                CategoryBar(
                  key: categoryBarKey,
                  onCategorySelected: _onCategorySelected,
                  darkMode: widget.darkMode,
                ),
                // Páginas de emojis y barra inferior
                Expanded(
                  child: Stack(
                    children: [
                      EmojiPage(
                        key: emojiPageKey,
                        emojiKeyboardHeight: keyboardHeight,
                        onEmojiSelected: _insertEmoji,
                        onPageChanged: _onPageChanged,
                        onScroll: _onEmojiScroll,
                        recentEmojis: recentEmojis.map((e) => e.emoji).toList(),
                      ),
                      // if (showBottomBar)
                      //   Positioned(
                      //     bottom: 0,
                      //     left: 0,
                      //     right: 0,
                      //     child: BottomBar(
                      //       key: bottomBarKey,
                      //       onSearchPressed: _startSearch,
                      //       darkMode: widget.darkMode,
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Modo de búsqueda de emojis
          if (searchMode)
            Container(
              color: Color(0xFF373737),
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Campo de búsqueda
                  Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.arrow_back, color: Colors.grey.shade600),
                        onPressed: () => setState(() => searchMode = false),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          focusNode: focusSearchEmoji,
                          onChanged: _onSearchTextChanged,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar emoji',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Resultados de búsqueda
                  SizedBox(
                    height:
                        isPortrait ? MediaQuery.of(context).size.width / 8 : 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: searchedEmojis.length,
                      itemBuilder: (context, index) {
                        final emoji = searchedEmojis[index];
                        return IconButton(
                          icon: Text(emoji, style: TextStyle(fontSize: 24)),
                          onPressed: () => _insertEmoji(emoji),
                        );
                      },
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
