import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00BF6A),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        onTap: onTap,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          hintText: 'ค้นหาแพ็กเกจ เช่น ล่องเรือ, ภูเขา, ชลบุรี , ...',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black87,
            size: 18,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
        ),
      ),
    );
  }
}
