import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.data,
    required this.onTap,
    this.borderColor = const Color(0xCCCAC8C8),
    this.backgroundColor = Colors.white,
    this.iconPath,
    this.textColor = Colors.black,
    this.enabled = true,
  });

  final String data;
  final void Function() onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final String? iconPath;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: iconPath != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(iconPath!, width: 24, height: 24),
                SizedBox(width: 40),
                Text(
                  data,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Text(
              data,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );
  }
}
