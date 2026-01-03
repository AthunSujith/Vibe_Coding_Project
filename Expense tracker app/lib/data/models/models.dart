class Category {
  final int? id;
  final String name;
  final int? parentId;
  final String icon;
  final int color;
  final String? accountingClass; // Asset Building, Liability Reduction, Consumption

  Category({
    this.id,
    required this.name,
    this.parentId,
    required this.icon,
    required this.color,
    this.accountingClass,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon': icon,
      'color': color,
      'accounting_class': accountingClass,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      icon: map['icon'],
      color: map['color'],
      accountingClass: map['accounting_class'],
    );
  }
}

class Account {
  final int? id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String icon;
  final int color;
  final String accountingClass; // Asset or Liability
  final String? behavior;
  final String? liquidity;
  final String? risk;

  Account({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.color,
    required this.accountingClass,
    this.behavior,
    this.liquidity,
    this.risk,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'accounting_class': accountingClass,
      'behavior': behavior,
      'liquidity': liquidity,
      'risk': risk,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: map['balance'],
      currency: map['currency'],
      icon: map['icon'],
      color: map['color'],
      accountingClass: map['accounting_class'] ?? 'Asset',
      behavior: map['behavior'],
      liquidity: map['liquidity'],
      risk: map['risk'],
    );
  }
}

class Transaction {
  final int? id;
  final double amount;
  final String currency;
  final String type;
  final int categoryId;
  final int accountId;
  final String date;
  final String time;
  final String location;
  final String merchant;
  final String notes;
  final bool isRecurring;
  final String? attachmentPath;

  Transaction({
    this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.time,
    required this.location,
    required this.merchant,
    required this.notes,
    required this.isRecurring,
    this.attachmentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'type': type,
      'category_id': categoryId,
      'account_id': accountId,
      'date': date,
      'time': time,
      'location': location,
      'merchant': merchant,
      'notes': notes,
      'is_recurring': isRecurring ? 1 : 0,
      'attachment_path': attachmentPath,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      currency: map['currency'],
      type: map['type'],
      categoryId: map['category_id'],
      accountId: map['account_id'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      merchant: map['merchant'],
      notes: map['notes'],
      isRecurring: map['is_recurring'] == 1,
      attachmentPath: map['attachment_path'],
    );
  }
}
