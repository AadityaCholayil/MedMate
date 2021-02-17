import 'package:flutter/cupertino.dart';
import 'package:medmate/db/database_provider.dart';
import 'package:medmate/events/delete_medicine.dart';
import 'package:medmate/events/set_medicine.dart';
import 'package:medmate/events/update_medicine.dart';
import 'package:medmate/main.dart';
import 'package:medmate/medicine_form.dart';
import 'package:medmate/model/LocalNotifyManager.dart';
import 'package:medmate/model/custom_theme.dart';
import 'package:medmate/model/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmate/bloc/medicine_bloc.dart';
import 'package:medmate/model/time.dart';
import 'home_page.dart';

class TakenPage extends StatefulWidget {
  @override
  _TakenPageState createState() => _TakenPageState();
}

class _TakenPageState extends State<TakenPage> {

  Medicine medicine;

  Image imageTablet, imageCapsule, imageSyrup, imageHome;

  @override
  void initState(){
    super.initState();
    _getData();
    imageTablet = Image.asset(
      'assets/Tablet.png',
      height: 160,
      width: 160,
    );
    imageCapsule = Image.asset(
      'assets/Capsule.png',
      height: 160,
      width: 160,
    );
    imageSyrup = Image.asset(
      'assets/Syrup.png',
      height: 160,
      width: 160,
    );
    imageHome = Image.asset(
      'assets/icon_home.png',
      height: 160,
      width: 160,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(imageTablet.image, context);
    precacheImage(imageCapsule.image, context);
    precacheImage(imageSyrup.image, context);
    precacheImage(imageHome.image, context);
  }

  Future<void> _getData() async {
    setState(() {
      DatabaseProvider.db.getMedicines().then(
            (medicineList) {
          BlocProvider.of<MedicineBloc>(context).add(SetMedicines(medicineList));
        },
      );
    });
  }

  Container smallCircle(Medicine medicine, int type){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.5),
      height: 20,
      width: 14,
      decoration: BoxDecoration(
        color: medicine.frequency[type]=='0'?Colors.grey:medicine.isTaken[type]=='1'?Colors.green:Colors.redAccent,
        borderRadius: BorderRadius.circular(5)
      ),
    );
  }

  Widget takenIndicator(Medicine medicine, int type){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          smallCircle(medicine, 0),
          smallCircle(medicine, 1),
          smallCircle(medicine, 2),
          smallCircle(medicine, 3),
        ],
      ),
    );
  }

  Widget customCard(BuildContext context, Medicine medicine, int index, int type){
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 15),
      height: 120,
      child: Card(
        semanticContainer: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,10,15,10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    medicine.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    'Time: ${convertToTimeStr12(medicine.time.substring(type*4, type*4+4))}',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20,
                    ),
                  ),
                  takenIndicator(medicine, type),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close),
                iconSize: 30,
                onPressed: () {
                  medicine.isTaken = medicine.isTaken.replaceRange(type, type + 1, '0');
                  DatabaseProvider.db.update(medicine).then((storedMedicine) =>
                      BlocProvider.of<MedicineBloc>(context)
                          .add(UpdateMedicine(index, medicine),
                      ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _getData,
        child: Container(
          //constraints: BoxConstraints.expand(),
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: BlocConsumer<MedicineBloc, List<Medicine>>(
            builder: (context, medicineList) {
              return Column(
                children: [
                  Container(
                    child: Text(
                      'Taken Page',
                      style: TextStyle(

                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        Medicine medicine = medicineList[index];
                        for(int i=0; i<4; i++){
                          if(medicine.isTaken[i]=='1'){
                            return customCard(context, medicine, index, i);
                            //return Text(medicine.name);
                          }
                        }
                        return SizedBox.shrink();
                      },
                      itemCount: medicineList.length,
                    ),
                  ),
                ],
              );
            },
            listener: (BuildContext context, medicineList) {},
          ),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.6,
              colors: [
                Theme.of(context).backgroundColor,
                Theme.of(context).colorScheme.surface,
              ],
              //tileMode: TileMode.repeated,
            )
          ),
        ),
      );
  }
}
