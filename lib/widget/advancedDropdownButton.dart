import 'package:flutter/material.dart';

class AdvancedDropdownButton extends StatefulWidget {
  final List<String> items;
  final String hint;
  final Function(String)? onChanged;

  const AdvancedDropdownButton({
    required this.items,
    required this.hint,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _AdvancedDropdownButtonState createState() => _AdvancedDropdownButtonState();
}

class _AdvancedDropdownButtonState extends State<AdvancedDropdownButton> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 173,
      height: 28,
      padding: const EdgeInsets.fromLTRB(10, 4, 8, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            widget.hint,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
          ),
          value: selectedValue,
          items: widget.items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
            if (widget.onChanged != null && value != null) {
              widget.onChanged!(value);
            }
          },
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 18),
          dropdownColor: Colors.white,
          elevation: 4,
          isExpanded: true,
        ),
      ),
    );
  }
}
