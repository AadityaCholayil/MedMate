import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CustomTheme{
  static ThemeData get customTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: HexColor('#40e0d0'),
      accentColor: HexColor('#a4fff9'),
      buttonColor: HexColor('#40e0d0'),
      bottomAppBarColor: HexColor('#d1fffc'),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: HexColor('#40e0d0'),
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(fontWeight: FontWeight.w300),
      ),
      textButtonTheme: TextButtonThemeData(),
      iconTheme: IconThemeData(),
      buttonTheme: ButtonThemeData(
        buttonColor: HexColor('#40e0d0')
      )
    );
  }
}
