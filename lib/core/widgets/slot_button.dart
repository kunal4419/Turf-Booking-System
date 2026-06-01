import 'package:flutter/material.dart';
import '../../models/slot.dart';

class SlotButton extends StatelessWidget {
  final Slot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const SlotButton({
    Key? key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (!slot.isAvailable) {
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey.shade600;
      borderColor = Colors.grey.shade300;
    } else if (isSelected) {
      bgColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      borderColor = Theme.of(context).primaryColor;
    } else {
      bgColor = Colors.white;
      textColor = Colors.black87;
      borderColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          slot.displayLabel,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            decoration: slot.isAvailable ? null : TextDecoration.lineThrough,
          ),
        ),
      ),
    );
  }
}
