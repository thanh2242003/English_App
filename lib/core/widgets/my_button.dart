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
    this.isLoading = false,
  });

  final String data;
  final void Function() onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final String? iconPath;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool effectiveEnabled = enabled && !isLoading;
    final Color effectiveBg =
        effectiveEnabled ? backgroundColor : Colors.grey.shade800;
    final Color effectiveText =
        effectiveEnabled ? textColor : Colors.grey.shade400;
    final Color effectiveBorder =
        effectiveEnabled ? borderColor : Colors.grey.shade600;

    return ElevatedButton(
      onPressed: effectiveEnabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: effectiveBorder, width: 2),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : iconPath != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(iconPath!, width: 24, height: 24),
                    const SizedBox(width: 40),
                    Text(
                      data,
                      style: TextStyle(
                        color: effectiveText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                )
              : Text(
                  data,
                  style: TextStyle(
                    color: effectiveText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
    );
  }
}
