import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:medmate/db/database_provider.dart';
import 'package:medmate/events/set_medicine.dart';
import 'package:medmate/medicine_form.dart';
import 'package:medmate/model/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmate/bloc/medicine_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:medmate/pages/home_page.dart';
import 'package:medmate/pages/taken_page.dart';
import 'package:medmate/themes/light_theme.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'main.dart';

class MedicineList extends StatefulWidget {
  final int medicineIndex;
  MedicineList({this.medicineIndex});

  @override
  _MedicineListState createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {

  @override
  void initState() {
    super.initState();
  }

  PreloadPageController pageController = PreloadPageController(initialPage: 0);
  int pageNo = 0;

  showThemeDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Theme'),
          content: Container(
            child: SwitchListTile(
              title: Text(
                'Light theme?',
                style: TextStyle(
                  fontSize: 23,
                  //color: HexColor(tColor1),
                  fontWeight: FontWeight.w300,
                ),
              ),
              value: themeStatus,
              onChanged: (bool value) => setState((){
                themeStatus = value;
              })
            ),
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //extendBodyBehindAppBar: true,
      // resizeToAvoidBottomPadding: false,
      // resizeToAvoidBottomInset: false,

      body: PreloadPageView(
        preloadPagesCount: 2,
        controller: pageController,
        onPageChanged: (int) {
          print('Page Changes to index $int');
          pageNo = int;
        },
        children: <Widget>[
          HomePage(),
          TakenPage(),
        ],
        //physics: NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 75,
        width: 75,
        child: FittedBox(
          child: OpenContainer(
            transitionDuration: Duration(milliseconds: 400),
            openBuilder: (context, closedContainer){
              return MedicineForm();
            },
            closedShape: CircleBorder(),
            closedBuilder: (context, openContainer){
              return FloatingActionButton(
                elevation: 2,
                child: Icon(Icons.add,
                  size: 33,
                ),
                onPressed: () {
                  openContainer();
                },
              );
            },
          )
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 27),
          child: Row(
            //mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(
                  Icons.home_outlined,
                  color: pageNo==0?Theme.of(context).primaryColorDark:Theme.of(context).colorScheme.onSurface,
                  size: 30.0,
                ),
                label: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: pageNo==0?Theme.of(context).primaryColorDark:Theme.of(context).colorScheme.onSurface,
                    //fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    pageNo=0;
                    pageController.animateToPage(0, duration: Duration(milliseconds: 600) , curve: Curves.ease);
                  });
                },
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.check,
                  color: pageNo==1?Theme.of(context).primaryColorDark:Theme.of(context).colorScheme.onSurface,
                  size: 30.0,
                ),
                label: Text(
                  'Taken',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: pageNo==1?Theme.of(context).primaryColorDark:Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    pageNo=1;
                    pageController.animateToPage(1, duration: Duration(milliseconds: 600) , curve: Curves.ease);
                  });
                },
              ),
              // IconButton(
              //   icon: Icon(Icons.more_vert_rounded),
              //   onPressed: () {
              //     setState(() {
              //       showThemeDialog(context);
              //     });
              //   },
              // ),
            ],
          ),
        ),
        //clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 10,
        //color: Colors.blueGrey,
      ),
    );
  }
}

