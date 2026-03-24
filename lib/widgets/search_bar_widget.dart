import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class KanjiSearchBar extends StatefulWidget {
  const KanjiSearchBar({super.key, this.focusNode, this.onClose});

  final FocusNode? focusNode;
  final VoidCallback? onClose;

  @override
  State<KanjiSearchBar> createState() => _KanjiSearchBarState();
}

class _KanjiSearchBarState extends State<KanjiSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<AppState>().setSearchQuery(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: _onChanged,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : const Color(0xFF2C3E50),
      ),
      decoration: InputDecoration(
        hintText: 'Search kanji...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white38 : const Color(0xFF8A9AAA),
        ),
        prefixIcon: widget.onClose != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, size: 18,
                    color: isDark ? Colors.white70 : const Color(0xFF3A4A5A)),
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              )
            : Icon(Icons.search, size: 18,
                color: isDark ? Colors.white70 : const Color(0xFF3A4A5A)),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 16,
                    color: isDark ? Colors.white54 : const Color(0xFF5A6A7A)),
                onPressed: () {
                  _controller.clear();
                  context.read<AppState>().setSearchQuery('');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.3 : 0.8),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        isDense: true,
      ),
    );
  }
}
