import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Removedialog extends StatefulWidget {
  final Function onRemove; // Callback for remove action

  const Removedialog({Key? key, required this.onRemove}) : super(key: key);

  @override
  State<Removedialog> createState() => _RemoveDialogState();
}

class _RemoveDialogState extends State<Removedialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      child: Container(
        height: 134,
        width: screenWidth * 0.80,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove',
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            Text(
              'Are you sure you want to remove your profile photo?',
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
                    side: const BorderSide(color: Color(0xFF004C99), width: 1),
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
                    widget.onRemove(); // Call the remove callback
                    /*ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profile photo removed.")),
                    );*/
                    Navigator.of(context).pop();
                  },
                  color: Color(0xFF004C99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Remove',
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
