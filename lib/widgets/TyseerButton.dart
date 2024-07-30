import 'package:flutter/material.dart';
import 'package:tayseer_insight/globals.dart';

class TyseerButton extends StatelessWidget 
{

  final double buttonWidth;
  final double buttonHeight;
  final String text;
  final VoidCallback onPressed;
   
   TyseerButton({
    required this.buttonWidth,
    required this.buttonHeight,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      height: buttonHeight, // Make the height equal to the width for a square button
      child: ButtonTheme(
        minWidth: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Color(0xff22160B), // Color of the border
              style: BorderStyle.solid, // Style of the border
              width: 0.8, // Width of the border
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
              foregroundColor: Colors.brown[100], // Text Color
              backgroundColor: Color(0xff22160B),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    )
    );
  }
}

 