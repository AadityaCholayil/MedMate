import 'package:medmate/model/medicine.dart';
import 'medicine_event.dart';

class AddMedicine extends MedicineEvent {
  Medicine newMedicine;

  AddMedicine(Medicine medicine){
    newMedicine = medicine;
  }
}