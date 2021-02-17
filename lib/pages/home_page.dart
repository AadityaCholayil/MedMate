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

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Medicine medicine;

  Image imageTablet;
  Image imageCapsule;
  Image imageSyrup;
  Image imageHome;

  @override
  void initState() {
    super.initState();
    _getData();
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
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

  Future<void> _getData() async {
    setState(() {
      DatabaseProvider.db.getMedicines().then(
            (medicineList) {
          BlocProvider.of<MedicineBloc>(context).add(SetMedicines(medicineList));
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(imageTablet.image, context);
    precacheImage(imageCapsule.image, context);
    precacheImage(imageSyrup.image, context);
    precacheImage(imageHome.image, context);
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('Notification Received: ${notification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

  Container smallCircle(Medicine medicine, int type){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      height: 25,
      width: 12,
      decoration: BoxDecoration(
          color: medicine.frequency[type]=='0'?Colors.grey:medicine.isTaken[type]=='1'?Colors.green:Colors.deepOrangeAccent,
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

  double cardHeight = 200;
  Widget _buildList(Medicine medicine, int type, BuildContext context, List<Medicine> medicineList, int tabType){
    //1-Morning, 2-Afternoon, 3-Evening, 4-Night, tabType - 0 for untaken, 1 for taken
    if(medicineList.isEmpty){
      return Container(
        height: cardHeight,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            'No Medicines due! :)'
          ),
        ),
      );
    }
    return Container(
      height: cardHeight,
      width: double.infinity,
      //margin: EdgeInsets.fromLTRB(0, 1, 0, 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          Medicine medicine = medicineList[index];
          if(medicine.isTaken[type]=='$tabType' && medicine.frequency.substring(type,type+1)=='1') {
            medicine.printDetails();
            return Container(
                width: 190,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                //height: cardHeight,
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: medicine.isDue[type] == '1' ? 5 : 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: medicine.isDue[type] == '1' ? Colors.white : Colors.white70,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Opacity(
                          opacity: 0.20,
                          child: medicine.medType=='Tablet'?imageTablet:medicine.medType=='Capsule'?imageCapsule:imageSyrup,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${medicine.name.length<12?medicine.name:medicine.name.replaceRange(10, medicine.name.length, '..')}',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            Text(
                              'Time: ${convertToTimeStr12(medicine.time.substring(type * 4, type * 4 + 4))}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                //decoration: TextDecoration.overline
                              ),
                            ),
                            Text(
                              'Dosage: ${medicine.dosage} ${(medicine.medType =='Syrup') ? "ml" : ""}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: 24,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Flexible(
                                  flex: 2,
                                  child: takenIndicator(medicine, type)
                                ),
                                Flexible(
                                  flex: 1,
                                  child: medicine.isDue[type] == '1' ?
                                  IconButton(
                                    icon: Icon(Icons.check),
                                    //color: HexColor(tColor2),
                                    //color: Colors.black,
                                    iconSize: 30,
                                    onPressed: () {
                                      print(index);
                                      medicine.isTaken = medicine.isTaken.replaceRange(type, type + 1, '1');
                                      DatabaseProvider.db.update(medicine).then((storedMedicine) =>
                                          BlocProvider.of<MedicineBloc>(context)
                                              .add(UpdateMedicine(index, medicine),
                                          ),
                                      );
                                    },
                                  ) : SizedBox(),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: IconButton(
                                    icon: Icon(Icons.more_vert),
                                    //color: HexColor(tColor2),
                                    //color: Colors.black,
                                    iconSize: 30,
                                    onPressed: () {
                                      showMedicineDialog(
                                          context, medicine, index, type);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            );
          }
          return SizedBox.shrink();
        },
        itemCount: medicineList.length,
      ),
    );
  }

  showMedicineDialog(BuildContext context, Medicine medicine, int index, int type){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(medicine.name),
          content: Container(
            height: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type: ${medicine.medType}"),
                SizedBox(height: 4),
                Text('Time: ${convertToTimeStr12(medicine.time.substring(type*4, type*4+4))}'),
                SizedBox(height: 3),
                Text('Dosage: ${medicine.dosage} ${(medicine.medType=='Syrup')?"ml":""}'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                localNotifyManager.cancelNotification(medicine.id, medicine.name);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineForm(medicine: medicine, medicineIndex: index),
                  ),
                );
              },
              child: Text('Update'),
            ),
            FlatButton(
              onPressed: () => DatabaseProvider.db.delete(medicine.id).then((_) {
                BlocProvider.of<MedicineBloc>(context).add(
                  DeleteMedicine(index),
                );
                localNotifyManager.cancelNotification(medicine.id, medicine.name);
                Navigator.pop(context);
              }
              ),
              child: Text('Delete'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            )
          ],
        )
    );
  }

  void setNotification(Medicine medicine){
    if(medicine.frequency[0]=='1'){
      localNotifyManager.showDailyAtTimeNotification(medicine.name, medicine.id*4+0, int.parse(medicine.time.substring(0,2)), int.parse(medicine.time.substring(2,4)));
    }
    if(medicine.frequency[1]=='1'){
      localNotifyManager.showDailyAtTimeNotification(medicine.name, medicine.id*4+1, int.parse(medicine.time.substring(4,6)), int.parse(medicine.time.substring(6,8)));
    }
    if(medicine.frequency[2]=='1'){
      localNotifyManager.showDailyAtTimeNotification(medicine.name, medicine.id*4+2, int.parse(medicine.time.substring(8,10)), int.parse(medicine.time.substring(10,12)));
    }
    if(medicine.frequency[3]=='1'){
      localNotifyManager.showDailyAtTimeNotification(medicine.name, medicine.id*4+3, int.parse(medicine.time.substring(12,14)), int.parse(medicine.time.substring(14,16)));
    }
  }

  Container midText(String text){
    return Container(
      padding: EdgeInsets.fromLTRB(28, 5, 0, 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w400,
          //fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget pageHead(){
    return Container(
      height: 300,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 12, 0, 0),
            width: 70,
            child: imageHome,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(15, 25, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MedMate',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w300,
                    //color: HexColor(tColor1),
                  ),
                ),
                Text(
                  'Your medicine reminder.',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    //color: HexColor(tColor1),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: _getData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: BlocConsumer<MedicineBloc, List<Medicine>>(
              builder: (context, medicineList) {
                print('in home page');
                List<Medicine> medicineListM = List<Medicine>();
                List<Medicine> medicineListA = List<Medicine>();
                List<Medicine> medicineListE = List<Medicine>();
                List<Medicine> medicineListN = List<Medicine>();
                for (Medicine medicine in medicineList){
                  setNotification(medicine);
                  incrementDate(medicine);
                  medicine.dueCheck();
                  medicine.printDetails();
                  // DatabaseProvider.db.update(medicine).then((storedMedicine) =>
                  //     BlocProvider.of<MedicineBloc>(context)
                  //         .add(UpdateMedicine(medicine.id, medicine),
                  //     ),
                  // );
                  if(medicine.frequency[0]=='1'){
                    medicineListM.add(medicine);
                    medicineListM.sort((a, b) => a.time.substring(0,4).compareTo(b.time.substring(0,4)));
                  }
                  if(medicine.frequency[1]=='1'){
                    medicineListA.add(medicine);
                    medicineListA.sort((a, b) => a.time.substring(4,8).compareTo(b.time.substring(4,8)));
                  }
                  if(medicine.frequency[2]=='1'){
                    medicineListE.add(medicine);
                    medicineListE.sort((a, b) => a.time.substring(8,12).compareTo(b.time.substring(8,12)));
                  }
                  if(medicine.frequency[3]=='1'){
                    medicineListN.add(medicine);
                    medicineListN.sort((a, b) => a.time.substring(12,16).compareTo(b.time.substring(12,16)));
                  }
                }
                return medicineList.length!=0?Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageHead(),
                    midText('Morning'),
                    _buildList(medicine, 0, context, medicineListM, 0),
                    midText('Afternoon'),
                    _buildList(medicine, 1, context, medicineListA, 0),
                    midText('Evening'),
                    _buildList(medicine, 2, context, medicineListE, 0),
                    midText('Night'),
                    _buildList(medicine, 3, context, medicineListN, 0),
                    SizedBox(height: 55,),
                  ],
                ):
                Center(
                  heightFactor: 18,
                  child: Text(
                    "You have not added any medicines yet.\nClick on the button below to add new Medicine",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17
                    ),
                  ),
                );
              },
              listener: (BuildContext context, medicineList) {},
            ),
            decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.6,
                  colors: [
                    Theme.of(context).backgroundColor,
                    Theme.of(context).colorScheme.surface,
                  ],
                  //tileMode: TileMode.repeated,
                )
            ),
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage('assets/bg.png'),
            //     fit: BoxFit.cover
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}
