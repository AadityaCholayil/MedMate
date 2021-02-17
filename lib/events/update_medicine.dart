import 'package:medmate/model/medicine.dart';
import 'medicine_event.dart';

class UpdateMedicine extends MedicineEvent {
  Medicine newMedicine;
  int medicineIndex;

  UpdateMedicine(int index, Medicine medicine) {
    newMedicine = medicine;
    medicineIndex = index;
  }
}