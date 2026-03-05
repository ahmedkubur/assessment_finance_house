import 'package:sqflite/sqflite.dart';

import '../core/db/app_database.dart';
import '../models/local/local_account.dart';
import '../models/local/local_beneficiary.dart';
import '../models/local/local_top_up_transaction.dart';
import '../utils/constants.dart';

class LocalTopUpRepository {
  LocalTopUpRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<LocalBeneficiary>> getActiveBeneficiaries(int accountId) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.beneficiariesTable,
      where: 'account_id = ? AND is_active = 1',
      whereArgs: [accountId],
      orderBy: 'id DESC',
    );

    return rows.map(LocalBeneficiary.fromMap).toList();
  }

  Future<int> countActiveBeneficiaries(int accountId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.beneficiariesTable} WHERE account_id = ? AND is_active = 1',
      [accountId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<LocalAccount?> getAccount(int accountId) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.accountsTable,
      where: 'id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalAccount.fromMap(rows.first);
  }

  Future<LocalBeneficiary?> getBeneficiaryById(int beneficiaryId) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.beneficiariesTable,
      where: 'id = ?',
      whereArgs: [beneficiaryId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalBeneficiary.fromMap(rows.first);
  }

  Future<int> getOrCreateDirectRechargeBeneficiary({
    required int accountId,
    required String phoneNumber,
    required String providerName,
    required String providerLogoUrl,
  }) async {
    final db = await _database.database;
    final normalizedPhone = phoneNumber.trim();

    final existingRows = await db.query(
      AppDatabase.beneficiariesTable,
      columns: ['id'],
      where: 'account_id = ? AND phone_number = ?',
      whereArgs: [accountId, normalizedPhone],
      orderBy: 'is_active DESC, id DESC',
      limit: 1,
    );

    if (existingRows.isNotEmpty) {
      return existingRows.first['id'] as int;
    }

    return db.insert(
      AppDatabase.beneficiariesTable,
      LocalBeneficiary(
        accountId: accountId,
        nickname: 'Direct Recharge',
        phoneNumber: normalizedPhone,
        providerName: providerName,
        providerLogoUrl: providerLogoUrl,
        isActive: false,
      ).toMap()
        ..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<double> monthlyBeneficiaryTopUpTotal({
    required int accountId,
    required int beneficiaryId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppDatabase.topUpTransactionsTable} '
      'WHERE account_id = ? AND beneficiary_id = ? AND created_at >= ? AND created_at < ?',
      [
        accountId,
        beneficiaryId,
        from.toIso8601String(),
        to.toIso8601String(),
      ],
    );

    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> monthlyAccountTopUpTotal({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppDatabase.topUpTransactionsTable} '
      'WHERE account_id = ? AND created_at >= ? AND created_at < ?',
      [
        accountId,
        from.toIso8601String(),
        to.toIso8601String(),
      ],
    );

    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> createTopUpTransaction({
    required LocalTopUpTransaction transaction,
  }) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      final accountRows = await txn.query(
        AppDatabase.accountsTable,
        where: 'id = ?',
        whereArgs: [transaction.accountId],
        limit: 1,
      );

      if (accountRows.isEmpty) {
        throw Exception(AppTopUpTextConstants.accountNotFound);
      }

      final account = LocalAccount.fromMap(accountRows.first);
      final nextBalance = account.balance - transaction.total;
      if (nextBalance < 0) {
        throw Exception('Insufficient balance');
      }

      await txn.insert(
        AppDatabase.topUpTransactionsTable,
        transaction.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await txn.update(
        AppDatabase.accountsTable,
        {'balance': nextBalance},
        where: 'id = ?',
        whereArgs: [transaction.accountId],
      );

      return nextBalance;
    });
  }

  Future<List<Map<String, dynamic>>> getAccountTransactions(int accountId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        t.id,
        'top_up' AS type,
        t.amount,
        t.charge,
        t.total,
        t.sim_provider_name AS reference,
        t.created_at,
        CASE
          WHEN b.is_active = 0 THEN 'direct'
          ELSE 'beneficiary'
        END AS recharge_method,
        b.nickname AS beneficiary_name,
        b.phone_number AS phone_number
      FROM ${AppDatabase.topUpTransactionsTable} t
      INNER JOIN ${AppDatabase.beneficiariesTable} b ON b.id = t.beneficiary_id
      WHERE t.account_id = ?
      UNION ALL
      SELECT
        id,
        'add_balance' AS type,
        amount,
        0 AS charge,
        amount AS total,
        'Wallet Balance' AS reference,
        created_at,
        '' AS recharge_method,
        '' AS beneficiary_name,
        '' AS phone_number
      FROM ${AppDatabase.addBalanceTransactionsTable}
      WHERE account_id = ?
      ORDER BY created_at DESC, id DESC
      ''',
      [accountId, accountId],
    );

    return rows;
  }
}
