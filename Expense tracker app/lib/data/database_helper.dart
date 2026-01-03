import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lumina_finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS budgets');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS accounts');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        name $textType,
        type $textType,
        balance $realType,
        currency $textType,
        icon $textType,
        color $integerType,
        accounting_class $textType,
        behavior TEXT,
        liquidity TEXT,
        risk TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        parent_id INTEGER,
        icon $textType,
        color $integerType,
        accounting_class TEXT,
        FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        amount $realType,
        currency $textType,
        type $textType,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        date $textType,
        time $textType,
        location $textType,
        merchant $textType,
        notes $textType,
        is_recurring $boolType,
        attachment_path TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        category_id INTEGER NOT NULL,
        amount $realType,
        period $textType,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    // Seed Accounts based on Behavior Matrix
    final accountsSeed = [
      {'name': 'Main Cash', 'type': 'Cash', 'class': 'Asset', 'liquidity': 'Immediate', 'risk': 'High', 'icon': 'payments', 'color': 0xFF4CAF50},
      {'name': 'HDFC Bank', 'type': 'Bank Account', 'class': 'Asset', 'liquidity': 'High', 'risk': 'Low', 'icon': 'account_balance', 'color': 0xFF2193B0},
      {'name': 'ICICI Credit Card', 'type': 'Credit Card', 'class': 'Liability', 'liquidity': 'Medium', 'risk': 'Medium', 'icon': 'credit_card', 'color': 0xFFF44336},
      {'name': 'Paytm Wallet', 'type': 'Digital Wallet', 'class': 'Asset', 'liquidity': 'High', 'risk': 'Medium', 'icon': 'account_balance_wallet', 'color': 0xFF00B9F1},
      {'name': 'Emergency Fund', 'type': 'Savings Account', 'class': 'Asset', 'liquidity': 'Medium', 'risk': 'Low', 'icon': 'savings', 'color': 0xFFFFC107},
      {'name': 'Home Loan', 'type': 'Loan Account', 'class': 'Liability', 'liquidity': 'Low', 'risk': 'High', 'icon': 'home', 'color': 0xFF795548},
      {'name': 'Zerodha Portfolio', 'type': 'Investment Account', 'class': 'Asset', 'liquidity': 'Low', 'risk': 'Market Risk', 'icon': 'show_chart', 'color': 0xFF9C27B0},
      {'name': 'Business Primary', 'type': 'Business Account', 'class': 'Asset', 'liquidity': 'High', 'risk': 'Medium', 'icon': 'business', 'color': 0xFF607D8B},
      {'name': 'Office Petty Cash', 'type': 'Petty Cash', 'class': 'Asset', 'liquidity': 'High', 'risk': 'Very High', 'icon': 'monetization_on', 'color': 0xFFFF9800},
      {'name': 'USD Holdings', 'type': 'Foreign Currency Account', 'class': 'Asset', 'liquidity': 'High', 'risk': 'FX Risk', 'icon': 'language', 'color': 0xFF3F51B5},
    ];

    for (var acc in accountsSeed) {
      await db.insert('accounts', {
        'name': acc['name'],
        'type': acc['type'],
        'balance': 0.0,
        'currency': 'INR',
        'icon': acc['icon'],
        'color': acc['color'],
        'accounting_class': acc['class'],
        'liquidity': acc['liquidity'],
        'risk': acc['risk'],
        'behavior': 'Standard behavior for ${acc['type']}'
      });
    }

    final Map<String, Map<String, String>> categoriesData = {
      'Living': {
        'Rent': 'Consumption',
        'Maintenance': 'Consumption',
        'Property Tax': 'Consumption',
        'Furniture': 'Asset Building',
        'Repairs': 'Consumption',
      },
      'Utilities': {
        'Electricity': 'Consumption',
        'Water': 'Consumption',
        'Gas': 'Consumption',
        'Internet': 'Consumption',
        'Mobile Recharge': 'Consumption',
      },
      'Food': {
        'Groceries': 'Consumption',
        'Restaurants': 'Consumption',
        'Fast Food': 'Consumption',
        'Office Food': 'Consumption',
        'Delivery': 'Consumption',
      },
      'Transportation': {
        'Fuel': 'Consumption',
        'Public Transport': 'Consumption',
        'Taxi': 'Consumption',
        'Parking': 'Consumption',
        'Vehicle Maintenance': 'Consumption',
      },
      'Healthcare': {
        'Medicine': 'Consumption',
        'Doctor': 'Consumption',
        'Insurance': 'Consumption',
        'Tests': 'Consumption',
        'Fitness': 'Consumption',
      },
      'Education': {
        'Tuition': 'Asset Building',
        'Courses': 'Asset Building',
        'Books': 'Asset Building',
        'Exams': 'Asset Building',
        'Certifications': 'Asset Building',
      },
      'Shopping': {
        'Clothes': 'Consumption',
        'Electronics': 'Consumption',
        'Accessories': 'Consumption',
        'Home Appliances': 'Consumption',
      },
      'Entertainment': {
        'Movies': 'Consumption',
        'Subscriptions': 'Consumption',
        'Gaming': 'Consumption',
        'Travel': 'Consumption',
      },
      'Finance': {
        'Loan EMI': 'Liability Reduction',
        'Credit Card Bill': 'Liability Reduction',
        'Bank Fees': 'Consumption',
        'Investments': 'Asset Building',
        'Taxes': 'Liability Reduction',
      },
      'Business': {
        'Office Rent': 'Consumption',
        'Salaries': 'Consumption',
        'Marketing': 'Consumption',
        'SaaS Tools': 'Consumption',
        'Equipment': 'Asset Building',
      },
    };

    for (var parentName in categoriesData.keys) {
      final parentId = await db.insert('categories', {
        'name': parentName,
        'parent_id': null,
        'icon': 'category',
        'color': 0xFF9D50BB,
        'accounting_class': null
      });

      final children = categoriesData[parentName]!;
      for (var childName in children.keys) {
        await db.insert('categories', {
          'name': childName,
          'parent_id': parentId,
          'icon': 'subdirectory_arrow_right',
          'color': 0xFF6E48AA,
          'accounting_class': children[childName]
        });
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
