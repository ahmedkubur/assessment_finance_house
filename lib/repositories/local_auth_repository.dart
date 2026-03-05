import 'package:sqflite/sqflite.dart';

import '../core/db/app_database.dart';
import '../models/local/local_account.dart';
import '../models/local/local_login_info.dart';
import '../utils/app_validators.dart';
import '../utils/constants.dart';

class LocalAuthRepository {
  LocalAuthRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createAccount(LocalAccount account) async {
    final db = await _database.database;
    return db.insert(
      AppDatabase.accountsTable,
      account.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<LocalAccount?> getAccountByPhone(String phone) async {
    final db = await _database.database;
    final phoneCandidates = _phoneLookupCandidates(phone);
    final placeholders = List.filled(phoneCandidates.length, '?').join(', ');
    final rows = await db.query(
      AppDatabase.accountsTable,
      where: 'phone IN ($placeholders)',
      whereArgs: phoneCandidates,
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return LocalAccount.fromMap(rows.first);
  }

  Future<LocalAccount?> getAccountById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.accountsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return LocalAccount.fromMap(rows.first);
  }

  Future<LocalAccount?> login({
    required String phone,
    required String password,
    bool rememberCredentials = true,
  }) async {
    final db = await _database.database;
    final phoneCandidates = _phoneLookupCandidates(phone);
    final placeholders = List.filled(phoneCandidates.length, '?').join(', ');
    final whereArgs = <Object>[...phoneCandidates, password];

    final rows = await db.query(
      AppDatabase.accountsTable,
      where: 'phone IN ($placeholders) AND password = ?',
      whereArgs: whereArgs,
      limit: 1,
    );

    if (rows.isEmpty) {
      await saveLoginInfo(
        LocalLoginInfo(
          accountId: null,
          phone: rememberCredentials ? phone : null,
          password: rememberCredentials ? password : null,
          isLoggedIn: false,
        ),
      );
      return null;
    }

    final account = LocalAccount.fromMap(rows.first);
    await saveLoginInfo(
      LocalLoginInfo(
        accountId: account.id,
        phone: rememberCredentials ? phone : null,
        password: rememberCredentials ? password : null,
        isLoggedIn: true,
      ),
    );

    return account;
  }

  Future<void> saveLoginInfo(LocalLoginInfo info) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.loginInfoTable,
      info.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LocalLoginInfo?> getLoginInfo() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.loginInfoTable,
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return LocalLoginInfo.fromMap(rows.first);
  }

  Future<void> logout({bool clearSavedCredentials = false}) async {
    final db = await _database.database;

    final current = await getLoginInfo();

    await saveLoginInfo(
      LocalLoginInfo(
        accountId: null,
        phone: clearSavedCredentials ? null : current?.phone,
        password: clearSavedCredentials ? null : current?.password,
        isLoggedIn: false,
      ),
    );
  }

  Future<bool> isPhoneAlreadyRegistered(String phone) async {
    final account = await getAccountByPhone(phone);
    return account != null;
  }

  Future<bool> changePassword({
    required int accountId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword == newPassword) return false;

    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.accountsTable,
      where: 'id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (rows.isEmpty) return false;

    final account = LocalAccount.fromMap(rows.first);
    if (account.password != currentPassword) return false;

    final updated = await db.update(
      AppDatabase.accountsTable,
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [accountId],
    );

    final loginInfo = await getLoginInfo();
    if (updated > 0 && loginInfo?.accountId == accountId) {
      await saveLoginInfo(
        LocalLoginInfo(
          accountId: loginInfo?.accountId,
          phone: loginInfo?.phone,
          password: newPassword,
          isLoggedIn: loginInfo?.isLoggedIn ?? false,
        ),
      );
    }

    return updated > 0;
  }

  Future<bool> addBalance({
    required int accountId,
    required double amount,
  }) async {
    if (amount <= 0) return false;

    final db = await _database.database;
    return db.transaction((txn) async {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final monthlyRows = await txn.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppDatabase.addBalanceTransactionsTable} '
        'WHERE account_id = ? AND created_at >= ? AND created_at < ?',
        [
          accountId,
          monthStart.toIso8601String(),
          monthEnd.toIso8601String(),
        ],
      );
      final monthlyTotal = (monthlyRows.first['total'] as num?)?.toDouble() ?? 0;
      if (monthlyTotal + amount > AppLimits.addBalanceMonthlyLimit) {
        return false;
      }

      final accountRows = await txn.query(
        AppDatabase.accountsTable,
        where: 'id = ?',
        whereArgs: [accountId],
        limit: 1,
      );
      if (accountRows.isEmpty) return false;

      final account = LocalAccount.fromMap(accountRows.first);
      final nextBalance = account.balance + amount;

      final updated = await txn.update(
        AppDatabase.accountsTable,
        {'balance': nextBalance},
        where: 'id = ?',
        whereArgs: [accountId],
      );
      if (updated <= 0) return false;

      await txn.insert(
        AppDatabase.addBalanceTransactionsTable,
        {
          'account_id': accountId,
          'amount': amount,
          'created_at': now.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return true;
    });
  }

  Future<double> monthlyAddBalanceTotal({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppDatabase.addBalanceTransactionsTable} '
      'WHERE account_id = ? AND created_at >= ? AND created_at < ?',
      [
        accountId,
        from.toIso8601String(),
        to.toIso8601String(),
      ],
    );

    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<bool> verifyUser({
    required int accountId,
    required String selfieImageUrl,
  }) async {
    final db = await _database.database;
    final updated = await db.update(
      AppDatabase.accountsTable,
      {
        'is_verified': 1,
        'image_url': selfieImageUrl.trim(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );

    return updated > 0;
  }

  Future<bool> updateProfileImage({
    required int accountId,
    required String imagePath,
  }) async {
    final db = await _database.database;
    final updated = await db.update(
      AppDatabase.accountsTable,
      {
        'image_url': imagePath.trim(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );

    return updated > 0;
  }

  List<String> _phoneLookupCandidates(String inputPhone) {
    final local = AppValidators.normalizeUaeLocalPhone(inputPhone.trim());
    final normalized = AppValidators.toUaePhoneE164(local);
    return <String>{
      normalized,
      local,
      '0$local',
    }.where((value) => value.isNotEmpty).toList();
  }
}
