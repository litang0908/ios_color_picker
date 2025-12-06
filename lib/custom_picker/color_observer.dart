import 'package:flutter/material.dart';

ColorController colorController = ColorController(Colors.red);

///Observer Class
class ColorController extends ValueNotifier<Color> {
  ColorController(super._value);

  void updateColor(Color newColor) {
    value = newColor;
  }

  void updateOpacity(double opacity) {
    value = value.withAlpha((opacity * 255).toInt());
  }

  double get colorAlpha {
    return value.alpha / 255.0;
  }
}
