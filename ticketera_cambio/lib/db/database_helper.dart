import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/operation.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'ticketera.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE operations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha_hora TEXT NOT NULL,
            tipo TEXT NOT NULL,
            moneda_origen TEXT NOT NULL,
            moneda_destino TEXT NOT NULL,
            monto REAL NOT NULL,
            tipo_cambio REAL NOT NULL,
            resultado REAL NOT NULL,
            cliente TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertOperation(Operation op) async {
    final db = await database;
    final map = op.toMap()..remove('id');
    return db.insert('operations', map);
  }

  Future<List<Operation>> getOperations({String? day}) async {
    final db = await database;
    List<Map<String, dynamic>> rows;
    if (day != null) {
      rows = await db.query(
        'operations',
        where: 'fecha_hora LIKE ?',
        whereArgs: ['$day%'],
        orderBy: 'fecha_hora DESC',
      );
    } else {
      rows = await db.query('operations', orderBy: 'fecha_hora DESC');
    }
    return rows.map((r) => Operation.fromMap(r)).toList();
  }

  Future<int> deleteOperation(int id) async {
    final db = await database;
    return db.delete('operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getDailyTotals(String day) async {
    final ops = await getOperations(day: day);
    double compras = 0;
    double ventas = 0;
    for (final op in ops) {
      if (op.tipo == 'Compra') {
        compras += op.resultado;
      } else {
        ventas += op.resultado;
      }
    }
    return {'compras': compras, 'ventas': ventas};
  }
}
