import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:timesyncr/them_controler.dart';

class Myinputfield extends StatelessWidget {
  final String titlee;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  Myinputfield({
    Key? key,
    required this.titlee,
    required this.hint,
    this.controller,
    this.widget,
  }) : super(key: key);

  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _themeController.isDarkTheme.value;

    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titlee,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          Container(
            height: 52,
            margin: EdgeInsets.only(top: 8.0),
            padding: EdgeInsets.only(
              left: 10,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: widget != null,
                    autofocus: false,
                    cursorColor: isDarkTheme ? Colors.white : Colors.black,
                    controller: controller,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkTheme ? Colors.white30 : Colors.black38,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
