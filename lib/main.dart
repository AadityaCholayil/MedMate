import 'package:flutter/material.dart';
import 'package:medmate/medicine_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmate/bloc/medicine_bloc.dart';
import 'package:medmate/themes/light_theme.dart';
import 'package:medmate/themes/dark_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MedicineBloc>(
      create: (context) => MedicineBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedMate',
        //theme: CustomTheme.customTheme,
        theme: lightTheme,
        home: MedicineList(),
      ),
    );
  }
}
bool themeStatus = true;
