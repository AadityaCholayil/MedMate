import 'package:flutter/material.dart';
import 'package:medmate/model/medicine.dart';

void dueCheck(Medicine medicine) {
  TimeOfDay actualCurrentTime;
  actualCurrentTime=TimeOfDay.now();
  int hour, minute;
  for (int i=0; i<4; i++) {
    if (medicine.frequency[i]=='1') {
      hour=int.parse(medicine.time.substring(i*4,i*4+2));
      minute=int.parse(medicine.time.substring(i*4+2,i*4+4));
      if (hour == actualCurrentTime.hour) {
        if (minute <= actualCurrentTime.minute) {
          medicine.isDue=medicine.isDue.replaceRange(i, i+1, '1');
        }
      } else if (hour < actualCurrentTime.hour) {
        medicine.isDue=medicine.isDue.replaceRange(i, i+1, '1');
      }
    }
  }
}

String convertToTimeStr24(TimeOfDay pickedTime) {
  String time;
  if (pickedTime!=null) {
    if (pickedTime.minute < 10) {
      if (pickedTime.hour < 10) {
        time = '0${pickedTime.hour}0${pickedTime.minute}';
      } else {
        time = '${pickedTime.hour}0${pickedTime.minute}';
      }
    } else if (pickedTime.hour < 10) {
      time = '0${pickedTime.hour}${pickedTime.minute}';
    } else {
      time = '${pickedTime.hour}${pickedTime.minute}';
    }
  }else{
    time=null;
  }
  return time;
}

String convertToTimeStr12(String pickedTime){
  String time;
  bool _isPM=false;
  if (pickedTime!=null) {
    int hour = int.tryParse(pickedTime.substring(0,2));
    String minutes = pickedTime.substring(2,4);
    if(minutes=='0'){
      minutes='00';
    }
    if(hour==12){
      _isPM=true;
    }
    if(hour==0){
      hour=12;
      _isPM=false;
    }
    if(hour>12){
      hour=hour-12;
      _isPM=true;
    }
    if(_isPM==false){
      if(hour<10){
        time='0$hour:$minutes AM';
      }else{
        time='$hour:$minutes AM';
      }
    } else {
      if(hour<10){
        time='0$hour:$minutes PM';
      }else{
        time='$hour:$minutes PM';
      }
    }
  }
  else{
    return '00:00 PM';
  }
  return time;
}

void incrementDate(Medicine medicine){
  DateTime today = DateTime.now();
  if (medicine.date!=today.day){
    for (int i=0; i<4; i++) {
      medicine.isTaken=medicine.isTaken.replaceRange(i, i+1, '0');
    }
    medicine.date=today.day;
  }
}

bool timeConditionCheck(String time, int type){
  switch(type){
    case 0: if(int.tryParse(time)>=300 && int.tryParse(time)<1100)
              return true;
            break;
    case 1: if(int.tryParse(time)>=1100 && int.tryParse(time)<1700)
              return true;
            break;
    case 2: if(int.tryParse(time)>=1700 && int.tryParse(time)<2000)
              return true;
            break;
    case 3: if(int.tryParse(time)>=2000 || int.tryParse(time)<300)
              return true;
            break;
  }
  return false;
}

