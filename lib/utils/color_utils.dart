import 'package:flutter/material.dart';

class ColorUtils {
 // static Color friendColor = Color(0xFFF0C868);
static Color friendColor = Colors.white;
// #D7AF4F 
  // static Color defaultColor = Color(0xFFFFF491);
  static Color defaultColor = Color(0xFFD7AF4F);
  static Color getSectionColor(String preferences) {
    if (preferences == "friend") return friendColor;
    return defaultColor;     
  }
}
