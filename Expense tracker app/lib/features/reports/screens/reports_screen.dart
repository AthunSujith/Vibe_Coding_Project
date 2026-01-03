import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:lumina_finance/core/widgets/glass_container.dart';
import 'package:lumina_finance/core/widgets/mesh_background.dart';
import 'package:lumina_finance/data/repositories/finance_repository.dart';
import 'package:lumina_finance/core/widgets/category_explorer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Financial Insights'),
        ),
        body: Consumer<FinanceRepository>(
          builder: (context, repo, child) {
            final data = _getCategoryData(repo);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GlassContainer(
                    height: 350,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Spending by Category',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              sections: data,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    height: 350,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Brutal Reality Breakdown',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              sections: _getClassData(repo),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    height: 450,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Category Explorer (Bubbles)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: CategoryExplorer(
                            categorySpending: repo.totalsByAccountingClass, // Simplified for now
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategoryData(FinanceRepository repo) {
    final Map<int, double> categorySums = {};
    for (final tx in repo.transactions) {
      if (tx.type == 'Expense') {
        categorySums[tx.categoryId] = (categorySums[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    if (categorySums.isEmpty) return [];

    return categorySums.entries.map((entry) {
      final category = repo.categories.firstWhere((c) => c.id == entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '${category.name}\n\$${entry.value.toStringAsFixed(0)}',
        color: Color(category.color),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> _getClassData(FinanceRepository repo) {
    final totals = repo.totalsByAccountingClass;
    if (totals.values.every((v) => v == 0)) return [];
    
    final classes = [
      {'name': 'Asset Building', 'color': Colors.cyanAccent},
      {'name': 'Liability Reduction', 'color': Colors.purpleAccent},
      {'name': 'Consumption', 'color': Colors.white},
    ];

    return classes.map((c) {
      final val = totals[c['name']]!;
      if (val == 0) return PieChartSectionData(value: 0, title: '', radius: 0);
      return PieChartSectionData(
        value: val,
        title: '${c['name']}\n\$${val.toStringAsFixed(0)}',
        color: (c['color'] as Color).withOpacity(0.8),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
