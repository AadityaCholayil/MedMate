import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:medmate/model/medicine.dart';

class DatabaseProvider{
  // TODO: Add new states
  static const String TABLE_MEDICINE = "medicine";
  static const String COLUMN_ID = "id";
  static const String COLUMN_NAME = "name";
  static const String COLUMN_TIME = "time";
  static const String COLUMN_DUE = "isDue";
  static const String COLUMN_TAKEN = "isTaken";
  static const String COLUMN_MEDTYPE = "medType";
  static const String COLUMN_DOSAGE = "dosage";
  static const String COLUMN_DATE = "date";
  static const String COLUMN_FREQUENCY = "frequency";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    print('database getter called');
    if(_database != null){
      return _database;
    }
    _database = await createDatabase();
    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'medicineDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print('creating db');
        // TODO: Add new states
        await database.execute(
          "CREATE TABLE $TABLE_MEDICINE ("
          "$COLUMN_ID INTEGER PRIMARY KEY,"
          "$COLUMN_NAME TEXT,"
          "$COLUMN_TIME TEXT,"
          "$COLUMN_DUE TEXT,"
          "$COLUMN_TAKEN TEXT,"
          "$COLUMN_MEDTYPE TEXT,"
          "$COLUMN_DOSAGE TEXT,"
          "$COLUMN_DATE INTEGER,"
          "$COLUMN_FREQUENCY TEXT"
          ")",
        );
      },
    );
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    // TODO: Add new states
    var medicines = await db.query(
      TABLE_MEDICINE,
      columns: [COLUMN_ID, COLUMN_NAME, COLUMN_TIME, COLUMN_DUE, COLUMN_TAKEN,
        COLUMN_MEDTYPE, COLUMN_DOSAGE, COLUMN_DATE, COLUMN_FREQUENCY]
    );
    List<Medicine> medicineList = List<Medicine> ();
    medicines.forEach((currentMedicine) {
      Medicine medicine = Medicine.fromMap(currentMedicine);
      medicineList.add(medicine);
    });
    return medicineList;
  }

  Future<Medicine> insert (Medicine medicine) async {
    final db = await database;
    medicine.id = await db.insert(TABLE_MEDICINE, medicine.toMap());
    print('Added ${medicine.id}, ${medicine.name}');
    return medicine;
  }

  Future<int> delete (int id) async {
    final db = await database;
    print('yeeted');
    return await db.delete(
      TABLE_MEDICINE,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(Medicine medicine) async {
    final db = await database;
    return await db.update(
      TABLE_MEDICINE,
      medicine.toMap(),
      where: "id = ?",
      whereArgs: [medicine.id],
    );
  }
}