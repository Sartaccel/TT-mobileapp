import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talent_turbo_new/screens/editPhoto/snack.dart';

class DiscardDialog extends StatelessWidget {
  final Function onDiscard; // Callback for discard action

  const DiscardDialog({Key? key, required this.onDiscard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      child: Container(
        height: 144,
        width: screenWidth * 0.80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discard changes',
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            Text(
              'Are you sure you want to discard all changes?',
              style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                    side: BorderSide(color: Color(0xFF004C99), width: 1),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF004C99)),
                  ),
                  minWidth: 102,
                  height: 36,
                ),
                SizedBox(width: 15),
                MaterialButton(
                  onPressed: () {
                    onDiscard(); // Call the discard callback

                    showCustomSnackbar(context, 'Profile picture updated !');
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  color: Color(0xFF004C99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Discard',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  minWidth: 102,
                  height: 36,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
