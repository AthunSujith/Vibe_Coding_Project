import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lumina_finance/core/widgets/glass_container.dart';
import 'package:lumina_finance/core/widgets/mesh_background.dart';
import 'package:lumina_finance/data/models/models.dart' as models;
import 'package:lumina_finance/data/repositories/finance_repository.dart';
import 'package:lumina_finance/data/ai_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'Expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _merchantController.addListener(_onMerchantChanged);
  }

  void _onMerchantChanged() {
    if (_merchantController.text.length > 3) {
      final repo = context.read<FinanceRepository>();
      final suggestedId = AIService.suggestCategory(_merchantController.text, repo.categories);
      if (suggestedId != null && _selectedCategoryId == null) {
        setState(() => _selectedCategoryId = suggestedId);
      }
    }
  }

  @override
  void dispose() {
    _merchantController.removeListener(_onMerchantChanged);
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('New Transaction'),
        ),
        body: Consumer<FinanceRepository>(
          builder: (context, repo, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              prefixText: '₹ ',
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 32),
                          _buildTypeSelector(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.category_outlined,
                            title: 'Category',
                            subtitle: _selectedCategoryId == null 
                                ? 'Select Category' 
                                : repo.categories.firstWhere((c) => c.id == _selectedCategoryId).name,
                            onTap: () => _showCategoryPicker(context, repo),
                          ),
                          _buildListTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Account',
                            subtitle: _selectedAccountId == null 
                                ? 'Select Account' 
                                : repo.accounts.firstWhere((a) => a.id == _selectedAccountId).name,
                            onTap: () => _showAccountPicker(context, repo),
                          ),
                          _buildListTile(
                            icon: Icons.calendar_today_outlined,
                            title: 'Date',
                            subtitle: DateFormat.yMMMMd().format(_selectedDate),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setState(() => _selectedDate = date);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _merchantController,
                            decoration: const InputDecoration(
                              hintText: 'Merchant / Description',
                              border: InputBorder.none,
                              icon: Icon(Icons.store_outlined, color: Colors.white60),
                            ),
                          ),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              hintText: 'Add Notes',
                              border: InputBorder.none,
                              icon: Icon(Icons.notes, color: Colors.white60),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Save Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Income', 'Expense', 'Transfer', 'Investment'].map((type) {
        final isSelected = _type == type;
        return GestureDetector(
          onTap: () => setState(() => _type = type),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white60)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }

  void _showCategoryPicker(BuildContext context, FinanceRepository repo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF24243E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final parents = repo.categories.where((c) => c.parentId == null).toList();
        return ListView.builder(
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final parent = parents[index];
            final children = repo.categories.where((c) => c.parentId == parent.id).toList();
            return ExpansionTile(
              title: Text(parent.name),
              leading: const Icon(Icons.category_outlined),
              children: children.map((child) => ListTile(
                title: Text(child.name),
                onTap: () {
                  setState(() => _selectedCategoryId = child.id);
                  Navigator.pop(context);
                },
              )).toList(),
            );
          },
        );
      },
    );
  }

  void _showAccountPicker(BuildContext context, FinanceRepository repo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF24243E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return ListView.builder(
          itemCount: repo.accounts.length,
          itemBuilder: (context, index) {
            final account = repo.accounts[index];
            return ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(account.name),
              subtitle: Text(account.type),
              onTap: () {
                setState(() => _selectedAccountId = account.id);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _submit() {
    if (_amountController.text.isEmpty || _selectedCategoryId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all mandatory fields')),
      );
      return;
    }

    final tx = models.Transaction(
      amount: double.parse(_amountController.text),
      currency: 'INR',
      type: _type,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      date: _selectedDate.toIso8601String(),
      time: '${_selectedTime.hour}:${_selectedTime.minute}',
      location: '',
      merchant: _merchantController.text,
      notes: _notesController.text,
      isRecurring: false,
    );

    context.read<FinanceRepository>().addTransaction(tx);
    Navigator.pop(context);
  }
}
