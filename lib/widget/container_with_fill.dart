import 'package:flutter/material.dart';

class CustomButtonContainer extends StatelessWidget {
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double height;
  final VoidCallback onPressed;
  final String text;

  CustomButtonContainer({
    this.borderRadius = 8.0,
    this.backgroundColor = Colors.blue,
    this.padding = const EdgeInsets.all(8.0),
    this.height = 40.0, // Default height
    required this.onPressed,
    required this.text,

  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height, // Set the height of the container
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor,
          ),
          padding: padding,
          child: Center(child: Text(text)),
      ),
      ),
    );
  }
}
