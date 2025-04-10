import 'package:flutter/material.dart';

class AdvancedDropdownButton extends StatefulWidget {
  final Map<String, String> items;
  final String hint;
  final Function(String)? onChanged;
  final bool customStyle;

  const AdvancedDropdownButton({
    required this.items,
    required this.hint,
    this.onChanged,
    this.customStyle = false,
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
        color: widget.customStyle ? const Color(0xFFE9F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: widget.customStyle ? Color(0x26338BFF) : Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            widget.hint,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: widget.customStyle ? const Color(0xFF338BFF) : Colors.black54,
            ),
          ),
          value: selectedValue,
          items:
              widget.items.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: widget.customStyle ? const Color(0xFF338BFF) : Colors.black54,
                    ),
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
          icon: Icon(
            Icons.arrow_drop_down,
            color: widget.customStyle ? const Color(0xFF338BFF) : Colors.black54,
          ),
          dropdownColor: Colors.white,
          elevation: 4,
          isExpanded: true,
        ),
      ),
    );
  }
}
