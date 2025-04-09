import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Function(String) onSelected;

  const CustomDropdown({
    Key? key,
    required this.selected,
    required this.options,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Container(
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(color: Color(0xFF338BFF), borderRadius: BorderRadius.circular(8)),
        child: PopupMenuButton<String>(
          offset: Offset(0, 50),
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) => onSelected(value),
          itemBuilder: (context) {
            return options
                .where((item) => item != selected)
                .map(
                  (item) => PopupMenuItem<String>(
                    value: item,
                    child: SizedBox(
                      width: 170,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Text(
                          "Kho $item",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList();
          },
          child: SizedBox(
            width: 170,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kho $selected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
