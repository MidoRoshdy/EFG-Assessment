import 'package:currency_converter/core/network/connectivity_providers.dart';
import 'package:currency_converter/core/widgets/app_offline_banner.dart';
import 'package:currency_converter/features/converter/presentation/pages/converter_page.dart';
import 'package:currency_converter/features/history/presentation/pages/history_page.dart';
import 'package:currency_converter/features/home/presentation/providers/home_tab_provider.dart';
import 'package:currency_converter/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final isOffline = ref.watch(isOnlineProvider).value == false;

    return Scaffold(
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: isOffline
                ? const AppOfflineBanner()
                : const SizedBox(width: double.infinity),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: isOffline,
              child: IndexedStack(
                index: tab.index,
                children: const [
                  ConverterPage(),
                  HistoryPage(),
                  SettingsPage(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) =>
            ref.read(homeTabProvider.notifier).select(HomeTab.values[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            selectedIcon: Icon(Icons.currency_exchange),
            label: 'Converter',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
