import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ui_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Account Settings',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.asset(
                    'assets/settings_bg.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'profile',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: const AssetImage('assets/icon.png'),
                            backgroundColor: Colors.white,
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12),
                        const Text(
                          'Super User',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsHeader(label: 'Experience'),
                  _SettingsTile(icon: Icons.palette_outlined, title: 'Theme Mode', trailing: 'Dynamic'),
                  _SettingsTile(icon: Icons.animation_rounded, title: 'Animations', trailing: 'High Performance'),
                  _SettingsTile(icon: Icons.notifications_active_outlined, title: 'Global Reminders', trailing: 'Enabled'),
                  const SizedBox(height: 32),
                  _SettingsHeader(label: 'Data Management'),
                  _SettingsTile(icon: Icons.cloud_done_outlined, title: 'Local Sync', trailing: 'Hive Active'),
                  _SettingsTile(icon: Icons.security_rounded, title: 'Encryption', trailing: 'AES-256'),
                  const SizedBox(height: 32),
                  _SettingsHeader(label: 'App Info'),
                  _SettingsTile(icon: Icons.info_outline, title: 'Version', trailing: '1.0.0+Premium'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String label;
  const _SettingsHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _SettingsTile({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[700]),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            trailing,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
