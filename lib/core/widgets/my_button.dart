import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.data,
    required this.onTap,
    this.borderColor = const Color(0xCCCAC8C8),
    this.backgroundColor = Colors.white,
    this.gradient,
    this.iconPath,
  });

  final String data;
  final void Function() onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Gradient? gradient;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
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
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            : Text(
                data,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
