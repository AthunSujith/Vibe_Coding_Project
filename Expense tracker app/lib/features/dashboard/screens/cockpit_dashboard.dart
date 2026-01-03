import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina_finance/core/widgets/glass_container.dart';
import 'package:lumina_finance/core/widgets/mesh_background.dart';
import 'package:lumina_finance/core/widgets/budget_radar.dart';
import 'package:lumina_finance/data/repositories/finance_repository.dart';
import 'package:lumina_finance/features/transactions/screens/add_transaction_screen.dart';
import 'package:lumina_finance/features/reports/screens/flow_map_screen.dart';
import 'package:lumina_finance/core/themes/app_theme.dart';
import 'package:lumina_finance/features/accounts/screens/accounts_screen.dart';
import 'package:lumina_finance/features/reports/screens/reports_screen.dart';
import 'package:lumina_finance/features/transactions/widgets/recent_transactions_list.dart';

class CockpitDashboard extends StatelessWidget {
  const CockpitDashboard({super.key});

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
            'CONTROL ROOM',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.hub_outlined, color: Colors.cyanAccent),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlowMapScreen())),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/app_icon.png', height: 36, width: 36),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<FinanceRepository>(
          builder: (context, repo, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COMMAND DECK ---
                  _buildCommandDeck(context, repo, currencyFormat),
                  
                  const SizedBox(height: 24),
                  
                  // --- THE ACTION RAIL ---
                  _buildActionRail(context),
                  
                  const SizedBox(height: 24),

                  // --- INTELLIGENCE PANEL ---
                  _buildIntelligencePanel(context, repo),

                  const SizedBox(height: 24),

                  // --- BUDGET RADAR ---
                  const Text(
                    'BUDGET RADAR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: BudgetRadar(
                      categorySpending: repo.totalsByAccountingClass, // Simplified for now
                    ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
                  ),

                  const SizedBox(height: 32),
                  
                  // --- RECENT FLOW ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENT FLOW',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white54),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('FULL STREAM', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  RecentTransactionsList(transactions: repo.transactions),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 2.seconds, color: Colors.white30),
      ),
    );
  }

  Widget _buildCommandDeck(BuildContext context, FinanceRepository repo, NumberFormat format) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET WORTH', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    format.format(repo.totalBalance),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.assetGreen),
                  ).animate().fadeIn().slideX(),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.assetGreen.withOpacity(0.1),
                ),
                child: const Icon(Icons.sensors, color: AppTheme.assetGreen),
              ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds, curve: Curves.easeInOut),
            ],
          ),
          const SizedBox(height: 30),
          // Growth Arc Placeholder
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10, width: 2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '+12.5%',
                    style: TextStyle(color: AppTheme.assetGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRail(BuildContext context) {
    final actions = [
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'ACCOUNTS', 'screen': const AccountsScreen()},
      {'icon': Icons.bar_chart_outlined, 'label': 'REPORTS', 'screen': const ReportsScreen()},
      {'icon': Icons.hub_outlined, 'label': 'FLOW', 'screen': const FlowMapScreen()},
      {'icon': Icons.settings_outlined, 'label': 'DECK', 'screen': null},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => GestureDetector(
        onTap: a['screen'] != null ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => a['screen'] as Widget)) : null,
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(15),
              borderRadius: 15,
              child: Icon(a['icon'] as IconData, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(a['label'] as String, style: const TextStyle(fontSize: 9, color: Colors.white38)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildIntelligencePanel(BuildContext context, FinanceRepository repo) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, color: Colors.purpleAccent, size: 40)
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 3.seconds),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI INTELLIGENCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  repo.optimizationScore > 50 
                    ? 'Wealth optimization active. Zero leak detected in utilities.'
                    : 'Critical leak detected in entertainment. Re-allocate 12% to assets.',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
