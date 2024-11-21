import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final bool isLoading;

  const ControlButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 32,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isLoading
                ? SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: size,
                  ),
          ),
        ),
      ),
    );
  }
}
