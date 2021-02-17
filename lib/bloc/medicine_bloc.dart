import 'package:medmate/events/add_medicine.dart';
import 'package:medmate/events/delete_medicine.dart';
import 'package:medmate/events/medicine_event.dart';
import 'package:medmate/events/set_medicine.dart';
import 'package:medmate/events/update_medicine.dart';
import 'package:medmate/model/medicine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicineBloc extends Bloc<MedicineEvent, List<Medicine>> {
  @override
  List<Medicine> get initialState => List<Medicine>();

  @override
  Stream<List<Medicine>> mapEventToState(MedicineEvent event) async* {
    if (event is SetMedicines) {
      yield event.medicineList;
    } else if (event is AddMedicine) {
      List<Medicine> newState = List.from(state);
      if (event.newMedicine != null) {
        newState.add(event.newMedicine);
      }
      yield newState;
    } else if (event is DeleteMedicine) {
      List<Medicine> newState = List.from(state);
      newState.removeAt(event.medicineIndex);
      yield newState;
    } else if (event is UpdateMedicine) {
      List<Medicine> newState = List.from(state);
      newState[event.medicineIndex] = event.newMedicine;
      yield newState;
    }
  }
}