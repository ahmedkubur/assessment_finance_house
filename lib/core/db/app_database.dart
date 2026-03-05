import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'mock_top_up.db';
  static const int _dbVersion = 3;

  static const String accountsTable = 'accounts';
  static const String loginInfoTable = 'login_info';
  static const String beneficiariesTable = 'beneficiaries';
  static const String topUpTransactionsTable = 'top_up_transactions';
  static const String addBalanceTransactionsTable = 'add_balance_transactions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $accountsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        email TEXT,
        password TEXT NOT NULL,
        image_url TEXT,
        balance REAL NOT NULL DEFAULT 0,
        is_verified INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $loginInfoTable (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        account_id INTEGER,
        phone TEXT,
        password TEXT,
        is_logged_in INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $beneficiariesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        nickname TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        provider_name TEXT NOT NULL,
        provider_logo_url TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE CASCADE,
        UNIQUE(account_id, phone_number),
        CHECK (LENGTH(nickname) <= 20)
      )
    ''');

    await db.execute('''
      CREATE TABLE $topUpTransactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        beneficiary_id INTEGER NOT NULL,
        sim_provider_name TEXT NOT NULL,
        amount REAL NOT NULL,
        charge REAL NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE CASCADE,
        FOREIGN KEY (beneficiary_id) REFERENCES $beneficiariesTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $addBalanceTransactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_beneficiaries_account_id ON $beneficiariesTable(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_top_up_account_id ON $topUpTransactionsTable(account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_top_up_beneficiary_id ON $topUpTransactionsTable(beneficiary_id)',
    );
    await db.execute(
      'CREATE INDEX idx_add_balance_account_id ON $addBalanceTransactionsTable(account_id)',
    );

    await db.insert(loginInfoTable, {
      'id': 1,
      'account_id': null,
      'phone': null,
      'password': null,
      'is_logged_in': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $accountsTable ADD COLUMN is_verified INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $beneficiariesTable ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $topUpTransactionsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL,
          beneficiary_id INTEGER NOT NULL,
          sim_provider_name TEXT NOT NULL,
          amount REAL NOT NULL,
          charge REAL NOT NULL,
          total REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE CASCADE,
          FOREIGN KEY (beneficiary_id) REFERENCES $beneficiariesTable(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_top_up_account_id ON $topUpTransactionsTable(account_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_top_up_beneficiary_id ON $topUpTransactionsTable(beneficiary_id)',
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $addBalanceTransactionsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (account_id) REFERENCES $accountsTable(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_add_balance_account_id ON $addBalanceTransactionsTable(account_id)',
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
