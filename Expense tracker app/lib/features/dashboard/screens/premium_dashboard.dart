import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lumina_finance/core/widgets/glass_container.dart';
import 'package:lumina_finance/core/widgets/mesh_background.dart';
import 'package:lumina_finance/data/repositories/finance_repository.dart';
import 'package:lumina_finance/features/transactions/screens/add_transaction_screen.dart';
import 'package:lumina_finance/features/accounts/screens/accounts_screen.dart';
import 'package:lumina_finance/features/reports/screens/reports_screen.dart';
import 'package:lumina_finance/features/transactions/widgets/recent_transactions_list.dart';

class PremiumDashboard extends StatelessWidget {
  const PremiumDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR');

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Lumina Finance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/app_icon.png',
                height: 36,
                width: 36,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<FinanceRepository>(
          builder: (context, repo, child) {
            return RefreshIndicator(
              onRefresh: () => repo.init(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Worth',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(repo.totalBalance),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 32),
                    
                    // Main Chart Area (Placeholder for now)
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Optimization Engine',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: repo.optimizationScore > 50 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Score: ${repo.optimizationScore.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: repo.optimizationScore > 50 ? Colors.greenAccent : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildClassBar('Asset Building', repo.totalsByAccountingClass['Asset Building']!, Colors.cyanAccent, repo),
                          const SizedBox(height: 12),
                          _buildClassBar('Liability Reduction', repo.totalsByAccountingClass['Liability Reduction']!, Colors.purpleAccent, repo),
                          const SizedBox(height: 12),
                          _buildClassBar('Consumption', repo.totalsByAccountingClass['Consumption']!, Colors.white70, repo),
                          const SizedBox(height: 16),
                          Text(
                            repo.optimizationScore > 50 
                              ? "You are building wealth. Keep it up!" 
                              : "Warning: High consumption detected. Optimize assets.",
                            style: TextStyle(
                              fontSize: 12, 
                              fontStyle: FontStyle.italic,
                              color: repo.optimizationScore > 50 ? Colors.greenAccent.withOpacity(0.7) : Colors.orangeAccent.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RecentTransactionsList(transactions: repo.transactions),
                  ],
                ),
              ),
            );
          },
        ),
        drawer: _buildDrawer(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildClassBar(String label, double amount, Color color, FinanceRepository repo) {
    final total = repo.totalsByAccountingClass.values.fold(0.0, (sum, val) => sum + val);
    final percentage = total > 0 ? amount / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.white60)),
            Text(NumberFormat.simpleCurrency().format(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF24243E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF9D50BB)),
            child: Text(
              'Lumina Finance',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Accounts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
            },
          ),
          const Divider(color: Colors.white24),
          const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
