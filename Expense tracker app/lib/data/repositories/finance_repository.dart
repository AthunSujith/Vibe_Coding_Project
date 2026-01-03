import 'package:flutter/material.dart';
import 'package:lumina_finance/data/database_helper.dart';
import 'package:lumina_finance/data/models/models.dart';

class FinanceRepository extends ChangeNotifier {
  final _dbHelper = DatabaseHelper.instance;

  List<Category> _categories = [];
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];

  List<Category> get categories => _categories;
  List<Account> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;

  double get totalBalance {
    double assets = 0;
    double liabilities = 0;
    for (var account in _accounts) {
      if (account.accountingClass == 'Liability') {
        liabilities += account.balance;
      } else {
        assets += account.balance;
      }
    }
    return assets - liabilities;
  }

  Map<String, double> get totalsByAccountingClass {
    final Map<String, double> totals = {
      'Asset Building': 0,
      'Liability Reduction': 0,
      'Consumption': 0,
    };

    for (var tx in _transactions) {
      if (tx.type == 'Expense') {
        final category = _categories.firstWhere(
          (c) => c.id == tx.categoryId,
          orElse: () => Category(name: 'Unknown', icon: '', color: 0),
        );
        if (category.accountingClass != null) {
          totals[category.accountingClass!] = (totals[category.accountingClass] ?? 0) + tx.amount;
        }
      }
    }
    return totals;
  }

  double get optimizationScore {
    final totals = totalsByAccountingClass;
    final totalExpense = totals.values.fold(0.0, (sum, val) => sum + val);
    if (totalExpense == 0) return 100; // Perfect score if no expenses
    
    final positiveSpending = totals['Asset Building']! + totals['Liability Reduction']!;
    return (positiveSpending / totalExpense) * 100;
  }

  Future<void> init() async {
    await fetchCategories();
    await fetchAccounts();
    await fetchTransactions();
  }

  Future<void> fetchCategories() async {
    final db = await _dbHelper.database;
    final result = await db.query('categories');
    _categories = result.map((json) => Category.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> fetchAccounts() async {
    final db = await _dbHelper.database;
    final result = await db.query('accounts');
    _accounts = result.map((json) => Account.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    final db = await _dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC, time DESC');
    _transactions = result.map((json) => Transaction.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', transaction.toMap());
    
    // Update account balance
    final account = _accounts.firstWhere((a) => a.id == transaction.accountId);
    double newBalance = account.balance;
    if (transaction.type == 'Expense') {
      newBalance -= transaction.amount;
    } else if (transaction.type == 'Income') {
      newBalance += transaction.amount;
    }
    
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [transaction.accountId],
    );

    await fetchAccounts();
    await fetchTransactions();
  }

  Future<void> addAccount(Account account) async {
    final db = await _dbHelper.database;
    await db.insert('accounts', account.toMap());
    await fetchAccounts();
  }
}
