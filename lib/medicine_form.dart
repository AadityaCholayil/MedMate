import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:medmate/bloc/medicine_bloc.dart';
import 'package:medmate/db/database_provider.dart';
import 'package:medmate/events/add_medicine.dart';
import 'package:medmate/events/delete_medicine.dart';
import 'package:medmate/events/update_medicine.dart';
import 'package:medmate/model/custom_theme.dart';
import 'package:medmate/model/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmate/model/time.dart';
import 'package:medmate/themes/light_theme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class MedicineForm extends StatefulWidget {
  final Medicine medicine;
  final int medicineIndex;

  MedicineForm({this.medicine, this.medicineIndex});
  @override
  State<StatefulWidget> createState() {
    return MedicineFormState();
  }
}

class MedicineFormState extends State<MedicineForm> {
  // TODO: Add new states
  String _name;
  String _time='0000000000000000';
  String _isDue = '0000';
  String _isTaken = '0000';
  String _medType = 'Tablet';
  String _dosage = '1';
  int _date=0;
  String _frequency='0000';
  TimeOfDay currentTime;
  TimeOfDay actualCurrentTime;
  TimeOfDay pickedTime;
  String pickedTime24;
  bool customTime=false;
  var timeArr = [0, 0, 0, 0];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(
          labelText: 'Name',
        labelStyle: TextStyle(
          fontSize: 25.0,
        )
      ),
      maxLength: 15,
      style: TextStyle(
          fontSize: 25.0,
          //color: HexColor(tColor1),
          fontWeight: FontWeight.w300),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }
        return null;
      },
      onSaved: (String value) {
        _name = value;
      },
    );
  }

  Widget _buildMedType(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Medicine Type:',
              style: TextStyle(
                //color: HexColor(tColor3),
                  fontSize: 25,
                  fontWeight: FontWeight.w300
              ),
            ),
          ),
          DropdownButton<String>(
            value: _medType,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            dropdownColor: HexColor('#d1fffc'),
            style: TextStyle(
              //color: HexColor(tColor1),
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
            underline: Container(
              height: 2,
              //color: HexColor(color3),
            ),
            onChanged: (String newValue) {
              setState(() {
                _medType = newValue;
              });
            },
            items: <String>['Tablet', 'Capsule', 'Syrup']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildDosage() {
    return _medType=='Syrup'?
    TextFormField(
      initialValue: _dosage,
      decoration: InputDecoration(
          labelText: 'Dosage (ml)',
        labelStyle: TextStyle(fontSize: 25)
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
      validator: (String value) {
        int dosage = int.tryParse(value);
        if (dosage == null || dosage <= 0) {
          return 'Dosage must be greater than 0';
        }
        return null;
      },
      onSaved: (String value) {
        _dosage = value;
      },
    ):Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Dosage:',
              style: TextStyle(
                //color: HexColor(tColor3),
                fontSize: 25,
                  fontWeight: FontWeight.w300
              ),
            ),
          ),
          DropdownButton<String>(
            value: (int.tryParse(_dosage)>5)?('1'):_dosage,
            icon: Icon(Icons.arrow_drop_down),
            dropdownColor: Theme.of(context).backgroundColor,
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              //color: HexColor(tColor1),
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
            underline: Container(
              height: 3,
              //color: HexColor(color3),
            ),
            onChanged: (String newValue) {
              setState(() {
                _dosage = newValue;
              });
            },
            items: <String>['1','2','3','4','5']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                    value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget timeCard(int type, bool custom){
    String timePic, displayTime;
    if(type==0){
      timePic='Morning';
      displayTime='09:00 AM';
    }else if (type==1){
      timePic='Afternoon';
      displayTime='01:00 PM';
    }else if (type==2){
      timePic='Evening';
      displayTime='05:00 PM';
    }else {
      timePic='Night';
      displayTime='09:00 PM';
    }
    return Expanded(
      child: InkWell(
        onTap: () {
          if (custom==false) {
            setState(() {
              if(timeArr[type]==0){
                timeArr[type]=1;
              }else{
                timeArr[type]=0;
              }
              for(int i=0;i<4;i++){
                _frequency=_frequency.replaceRange(i, i+1, timeArr[i].toString());
              }
              int i = type;
              if(_frequency.substring(i, i+1)=='1'){
                switch(type){
                  case 0: _time=_time.replaceRange(i*4, i*4+4, '0900');
                  break;
                  case 1: _time=_time.replaceRange(i*4, i*4+4, '1300');
                  break;
                  case 2: _time=_time.replaceRange(i*4, i*4+4, '1700');
                  break;
                  case 3: _time=_time.replaceRange(i*4, i*4+4, '2100');
                  break;
                }
              } else {
                _time=_time.replaceRange(i*4, i*4+4, '0000');
              }
              final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
              _date=now.day;
              print('Time - $_time, Frequency - $_frequency');
            });
          }
        },
        //splashColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            color: timeArr[type]==1?Theme.of(context).toggleableActiveColor:Theme.of(context).splashColor,
          ),
          height: 120,
          child: Stack(
            //fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Image.asset(
                    'assets/$timePic${timeArr[type]}.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              customTime==false?
              Container(
                color: Theme.of(context).highlightColor,
                child: Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ):_time.substring(type*4, type*4+4)=='0000'?ElevatedButton.icon(
                onPressed: () {
                  selectTime(context, type);
                },
                icon: Icon(Icons.add_alarm,),
                label: Text(
                  'Set Time',
                  style: TextStyle(
                    fontSize: 20,
                    //color: HexColor(tColor2),
                  ),
                ),
              ):ElevatedButton.icon(
                onPressed: () {
                  selectTime(context, type);
                },
                icon: Icon(Icons.add_alarm,),
                label: Text(
                  convertToTimeStr12(_time.substring(type*4, type*4+4)),
                  style: TextStyle(
                    fontSize: 20,
                    //color: HexColor(tColor2),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTime() {
    return Card(
      elevation: 4,
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 2.0, 2.0, 0.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Custom time?',
                style: TextStyle(
                  fontSize: 23,
                  //color: HexColor(tColor1),
                  fontWeight: FontWeight.w300,
                ),
              ),
              value: customTime,
              onChanged: (bool newValue) => setState(() {
                customTime=newValue;
                _time='0000000000000000';
                _frequency='0000';
                timeArr=[0,0,0,0];
              }),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      timeCard(0, customTime),
                      timeCard(1, customTime),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      timeCard(2, customTime),
                      timeCard(3, customTime),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("The selected time doesn't fit the time period."),
                Row(
                  children: [
                    Text("Morning\nAfternoon"
                        "\nEvening\nNight"),
                    Text('- 03 AM to 10:59 AM\n- 11 AM to 04:59 PM'
                        '\n- 05 PM to 07:59 PM\n- 08 PM to 02:59 AM')
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> selectTime (BuildContext context, int type) async {
    while (true) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );
      if (pickedTime != null) {
        pickedTime24=convertToTimeStr24(pickedTime);
        if (timeConditionCheck(pickedTime24, type)==true) {
          _time=_time.replaceRange(type*4, type*4+4, pickedTime24);
          final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          _date=now.day;
          _frequency=_frequency.replaceRange(type, type+1, '1');
          timeArr[type]=1;
          print('Time - $_time, Frequency - $_frequency');
          setState(() {
            currentTime = pickedTime;
          });
          break;
        } else {
          await _showDialog();
          continue;
        }
      }
      break;
    }
  }
  
  SnackBar showCustomSnackBar(String message){
    return SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // TODO: Add new states
    if (widget.medicine != null) {
      _name = widget.medicine.name;
      _time = widget.medicine.time;
      //_isDue = widget.medicine.isDue;
      //_isTaken = widget.medicine.isTaken;
      _medType = widget.medicine.medType;
      _dosage = widget.medicine.dosage;
      _date = widget.medicine.date;
      _frequency = widget.medicine.frequency;
      for(int i=0;i<4;i++){
        timeArr[i]=int.tryParse(_frequency[i]);
      }
    }
    currentTime = TimeOfDay.now();
    actualCurrentTime = TimeOfDay.now();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
            "Medicine Form",
          style: TextStyle(
            //color: HexColor(tColor1),
            fontSize: 28,
            fontWeight: FontWeight.w300
          ),
        ),
        centerTitle: true,
        backgroundColor: HexColor('#d1fffc'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              //color: HexColor(color4)
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        //margin: EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildName(),
                SizedBox(height: 1),
                _buildMedType(),
                _buildDosage(),
                SizedBox(height: 1),
                _buildTime(),
                SizedBox(height: 0),
                widget.medicine == null ?
                Builder(builder: (context) => RaisedButton(
                  child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    if(_frequency=='0000') {
                      Scaffold.of(context).showSnackBar(showCustomSnackBar('Select atleast one Period!'));
                      return;
                    }
                    _formKey.currentState.save();
                    // TODO: Add new states
                    Medicine medicine = Medicine(
                      name: _name,
                      time: _time,
                      isDue: _isDue,
                      isTaken: _isTaken,
                      medType: _medType,
                      dosage: _dosage,
                      date: _date,
                      frequency: _frequency,
                    );

                    DatabaseProvider.db.insert(medicine).then(
                          (storedMedicine) => BlocProvider.of<MedicineBloc>(context).add(
                        AddMedicine(storedMedicine),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ))
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(
                        "Update",
                        style: TextStyle( fontSize: 16),
                      ),
                      onPressed: () async{
                        if (!_formKey.currentState.validate()) {
                          print("form");
                          return;
                        }

                        _formKey.currentState.save();
                        // TODO: Add new states
                        Medicine medicine = Medicine(
                          //id: widget.medicineIndex,
                          name: _name,
                          time: _time,
                          isDue: _isDue,
                          isTaken: _isTaken,
                          medType: _medType,
                          dosage: _dosage,
                          date: _date,
                          frequency: _frequency,
                        );
                        print(widget.medicineIndex);
                        print(widget.medicine.id);
                        print('$_name, $_time, $_isDue, $_isTaken, $_medType, $_dosage, $_date, $_frequency');
                        await DatabaseProvider.db.delete(widget.medicine.id).then((_) {
                          BlocProvider.of<MedicineBloc>(context).add(
                            DeleteMedicine(widget.medicineIndex),
                          );
                        });
                        print('b/w 2 await');
                        await DatabaseProvider.db.insert(medicine).then(
                              (storedMedicine) => BlocProvider.of<MedicineBloc>(context).add(
                            AddMedicine(storedMedicine),
                          ),
                        );
                        print('after both await');
                        // await DatabaseProvider.db.update(widget.medicine).then(
                        //       (storedMedicine) => BlocProvider.of<MedicineBloc>(context).add(
                        //     UpdateMedicine(widget.medicine.id, medicine),
                        //   ),
                        // );
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,
                Colors.white,
                HexColor('#d1fffc'),
              ],
              tileMode: TileMode.repeated,
            )
        ),
      ),
    );
  }
}
