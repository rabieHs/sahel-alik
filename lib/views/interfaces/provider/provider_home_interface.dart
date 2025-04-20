import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sahel_alik/views/widgets/custom_button.dart';
import '../profile_interface.dart';
import 'add_service_interface.dart';
import 'orders_interface.dart';
import 'service_list_interface.dart';
import '../../widgets/language_switcher.dart';

class ProviderHomeInterface extends StatefulWidget {
  const ProviderHomeInterface({super.key});

  @override
  State<ProviderHomeInterface> createState() => _ProviderHomeInterfaceState();
}

class _ProviderHomeInterfaceState extends State<ProviderHomeInterface> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [
    ServiceListInterface(),
    ProviderOrdersInterface(),
    const ProfileInterface(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.providerHome),
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          if (_selectedIndex == 0) // Show FAB only on Services screen
            Positioned(
              bottom: 20,
              right: 20,
              child: CustomButton(
                // Use CustomButton for FloatingActionButton
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddServiceInterface()),
                  );
                },
                text: AppLocalizations.of(context)!.addService,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.miscellaneous_services),
            label: AppLocalizations.of(context)!.services,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: AppLocalizations.of(context)!.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.grey[700],
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
      ),
    );
  }
}
