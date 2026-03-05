import 'package:sqflite/sqflite.dart';

import '../core/db/app_database.dart';
import '../models/local/local_beneficiary.dart';

class LocalBeneficiariesRepository {
  LocalBeneficiariesRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> addBeneficiary(LocalBeneficiary beneficiary) async {
    final db = await _database.database;
    return db.insert(
      AppDatabase.beneficiariesTable,
      beneficiary.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalBeneficiary>> getBeneficiariesByAccountId(int accountId) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.beneficiariesTable,
      where: 'account_id = ? AND is_active = 1',
      whereArgs: [accountId],
      orderBy: 'id DESC',
    );

    return rows.map(LocalBeneficiary.fromMap).toList();
  }

  Future<int> updateBeneficiary(LocalBeneficiary beneficiary) async {
    final db = await _database.database;
    if (beneficiary.id == null) return 0;

    return db.update(
      AppDatabase.beneficiariesTable,
      beneficiary.toMap()..remove('created_at'),
      where: 'id = ?',
      whereArgs: [beneficiary.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteBeneficiary(int beneficiaryId) async {
    final db = await _database.database;
    return db.update(
      AppDatabase.beneficiariesTable,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [beneficiaryId],
    );
  }

  Future<int> countActiveBeneficiaries(int accountId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.beneficiariesTable} WHERE account_id = ? AND is_active = 1',
      [accountId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }
}
