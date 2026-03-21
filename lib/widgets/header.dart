import 'package:flutter/material.dart';
import 'search_bar.dart';

class HeaderWidget extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;

  const HeaderWidget({
    super.key, 
    this.onSearchChanged, 
    this.onSearchSubmitted,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo-black.png',
            width: 98.25,
            height: 35.93,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 30,
              child: SearchBarWidget(
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted,
                onTap: onSearchTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
