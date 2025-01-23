import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    
    
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 41,
          width: 41, // Adjust width to fit the circle
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.check, // Check icon
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10), 
        Expanded(
          child: Text(
            message, 
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: Container(
            height: 41,
            width: 41, 
            child: const Icon(
              Icons.close, // Close icon
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black, // Background color of the Snackbar
    behavior: SnackBarBehavior.floating, // Allows floating Snackbar
    duration: const Duration(seconds: 1), // Duration before it disappears
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), 
    ),
  );

  // Show the Snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
