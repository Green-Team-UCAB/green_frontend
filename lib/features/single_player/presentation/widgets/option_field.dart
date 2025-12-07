import 'package:flutter/material.dart';

class OptionField extends StatelessWidget {
  final void Function(String) onSelected;
  final List<String> options;

    const OptionField({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, 
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true, 
      children: options.map((opt) {
        return ElevatedButton(
          onPressed: () => onSelected(opt),
          child: Text(opt),
        );
      }).toList(),
    );
  }
}