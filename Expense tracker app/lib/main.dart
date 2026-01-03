import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lumina_finance/core/themes/app_theme.dart';
import 'package:lumina_finance/data/repositories/finance_repository.dart';
import 'package:lumina_finance/features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final financeRepository = FinanceRepository();
  await financeRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: financeRepository),
      ],
      child: const LuminaFinanceApp(),
    ),
  );
}

class LuminaFinanceApp extends StatelessWidget {
  const LuminaFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
