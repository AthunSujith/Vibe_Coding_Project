import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina_finance/core/widgets/glass_container.dart';
import 'package:lumina_finance/data/models/models.dart' as models;

class RecentTransactionsList extends StatelessWidget {
  final List<models.Transaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No transactions yet. Tap + to add one!',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.type == 'Income';

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 20,
            opacity: 0.05,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isIncome ? Colors.green : Colors.purple).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isIncome ? Icons.trending_up : Icons.shopping_bag_outlined,
                    color: isIncome ? Colors.greenAccent : Colors.purpleAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.merchant.isNotEmpty ? tx.merchant : 'Transaction',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(DateTime.parse(tx.date)),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isIncome ? Colors.greenAccent : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
