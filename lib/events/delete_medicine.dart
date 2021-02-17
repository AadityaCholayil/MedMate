import 'medicine_event.dart';

class DeleteMedicine extends MedicineEvent {
  int medicineIndex;

  DeleteMedicine(int index) {
    medicineIndex = index;
  }
}