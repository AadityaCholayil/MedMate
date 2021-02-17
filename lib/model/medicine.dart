import 'package:flutter/material.dart';
import 'package:medmate/db/database_provider.dart';

class Medicine {
  int id;
  String name;
  String time;
  String isDue;
  String isTaken;
  String medType;
  String dosage;
  int date;
  String frequency;
  // TODO: Add new states
  Medicine({this.id, this.name, this.time, this.isDue, this.isTaken,
    this.medType, this.dosage, this.date, this.frequency});
  // TODO: Add new states
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_NAME: name,
      DatabaseProvider.COLUMN_TIME: time,
      DatabaseProvider.COLUMN_DUE: isDue,
      DatabaseProvider.COLUMN_TAKEN: isTaken,
      DatabaseProvider.COLUMN_MEDTYPE: medType,
      DatabaseProvider.COLUMN_DOSAGE: dosage,
      DatabaseProvider.COLUMN_DATE: date,
      DatabaseProvider.COLUMN_FREQUENCY: frequency,
    };
    if(id != null){
      map[DatabaseProvider.COLUMN_ID] = id;
    }
    return map;
  }
  // TODO: Add new states
  Medicine.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    name = map[DatabaseProvider.COLUMN_NAME];
    time = map[DatabaseProvider.COLUMN_TIME];
    isDue = map[DatabaseProvider.COLUMN_DUE];
    isTaken = map[DatabaseProvider.COLUMN_TAKEN];
    medType = map[DatabaseProvider.COLUMN_MEDTYPE];
    dosage = map[DatabaseProvider.COLUMN_DOSAGE];
    date = map[DatabaseProvider.COLUMN_DATE];
    frequency = map[DatabaseProvider.COLUMN_FREQUENCY];
  }

  void printDetails(){
    print('${this.id}, ${this.name}, ${this.time}, ${this.isDue}, ${this.isTaken}, '
        '${this.medType}, ${this.dosage}, ${this.date}, ${this.frequency}');
  }

  void dueCheck() {
    TimeOfDay actualCurrentTime;
    actualCurrentTime=TimeOfDay.now();
    int hour, minute;
    for (int i=0; i<4; i++) {
      if (this.frequency[i]=='1') {
        hour=int.parse(this.time.substring(i*4,i*4+2));
        minute=int.parse(this.time.substring(i*4+2,i*4+4));
        if (hour == actualCurrentTime.hour) {
          if (minute <= actualCurrentTime.minute) {
            this.isDue=this.isDue.replaceRange(i, i+1, '1');
          }
        } else if (hour < actualCurrentTime.hour) {
          this.isDue=this.isDue.replaceRange(i, i+1, '1');
        }
      }
    }
  }
}
