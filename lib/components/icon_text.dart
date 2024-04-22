import 'package:flutter/cupertino.dart';

class IconedText extends StatelessWidget {
  IconedText({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 24.0,
    this.textStyle = const TextStyle()
  });

  final IconData icon;
  final String text;
  final double iconSize;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 4),
        Text(text, style: textStyle)
      ],
    );
  }
}