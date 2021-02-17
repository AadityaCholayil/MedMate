import 'package:medmate/model/medicine.dart';
import 'medicine_event.dart';

class SetMedicines extends MedicineEvent {
  List<Medicine> medicineList;

  SetMedicines(List<Medicine> medicine) {
    medicineList = medicine;
  }
}