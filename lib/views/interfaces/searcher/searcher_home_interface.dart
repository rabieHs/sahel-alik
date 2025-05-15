import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sahel_alik/views/interfaces/searcher/chatbot_screen.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_orders_tab.dart';
import 'package:sahel_alik/views/interfaces/searcher/searcher_services_tab.dart';

import '../../widgets/service_card.dart';
import '../../widgets/language_switcher.dart';
import '../../../services/service_service.dart';
import '../../../models/service.dart';
import '../profile_interface.dart';
import '../../../utils/location_utils.dart';

class SearcherHomeInterface extends StatefulWidget {
  const SearcherHomeInterface({Key? key}) : super(key: key);

  @override
  State<SearcherHomeInterface> createState() => _SearcherHomeInterfaceState();
}

class _SearcherHomeInterfaceState extends State<SearcherHomeInterface> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  bool _isLoading = true;
  double _radius = 5.0; // Default radius

  List<Map<String, dynamic>> _getLocalizedCategories(BuildContext context) {
    return [
      {
        'name': AppLocalizations.of(context)!.categoryMaid,
        'icon': Icons.home_work,
        'value': 'Maid'
      },
      {
        'name': AppLocalizations.of(context)!.categoryCleaner,
        'icon': Icons.cleaning_services,
        'value': 'Cleaner'
      },
      {
        'name': AppLocalizations.of(context)!.categoryMechanic,
        'icon': Icons.build,
        'value': 'Mechanic'
      },
      {
        'name': AppLocalizations.of(context)!.categoryBarber,
        'icon': Icons.content_cut,
        'value': 'Barber'
      },
      {
        'name': AppLocalizations.of(context)!.categoryPlumber,
        'icon': Icons.plumbing,
        'value': 'Plumber'
      },
      {
        'name': AppLocalizations.of(context)!.categoryElectrician,
        'icon': Icons.electrical_services,
        'value': 'Electrician'
      },
      {
        'name': AppLocalizations.of(context)!.categoryCarpenter,
        'icon': Icons.carpenter,
        'value': 'Carpenter'
      },
      {
        'name': AppLocalizations.of(context)!.categoryPainter,
        'icon': Icons.format_paint,
        'value': 'Painter'
      },
      {
        'name': AppLocalizations.of(context)!.categoryGardener,
        'icon': Icons.nature,
        'value': 'Gardener'
      },
      {
        'name': AppLocalizations.of(context)!.categoryChef,
        'icon': Icons.restaurant,
        'value': 'Chef'
      },
      {
        'name': AppLocalizations.of(context)!.categoryTutor,
        'icon': Icons.school,
        'value': 'Tutor'
      },
      {
        'name': AppLocalizations.of(context)!.categoryDriver,
        'icon': Icons.drive_eta,
        'value': 'Driver'
      },
      {
        'name': AppLocalizations.of(context)!.categoryMore,
        'icon': Icons.category,
        'value': 'More'
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices({double? radius}) async {
    setState(() {
      _isLoading = true;
    });
    final serviceService = ServiceService();
    final position =
        await LocationUtils.getCurrentPosition(context); // Pass context
    double searchRadius = radius ?? _radius; // Use provided radius or default

    if (position != null) {
      final servicesStream = serviceService.getNearestServices(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: searchRadius,
      );
      servicesStream.first.then((services) {
        setState(() {
          _services = services;
          _filteredServices = services;
          _isLoading = false;
        });
      });
    } else {
      final allServicesStream = serviceService.getAllServices();
      allServicesStream.first.then((services) {
        setState(() {
          _services = services;
          _filteredServices = services;
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.locationNotAvailable)),
          );
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _filterServices(String query) {
    String lowerCaseQuery = query.toLowerCase();
    List<ServiceModel> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = _services
          .where((service) =>
              service.title!.toLowerCase().contains(lowerCaseQuery) ||
              service.description!.toLowerCase().contains(lowerCaseQuery))
          .toList();
    } else {
      filteredList = List.from(_services);
    }
    setState(() {
      _filteredServices = filteredList;
    });
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    double tempRadius = _radius; // Temporary radius value for the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.filterByRadius),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.selectRadius),
                  Slider(
                    value: tempRadius,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: tempRadius.round().toString(),
                    onChanged: (double value) {
                      dialogSetState(() {
                        tempRadius = value;
                      });
                    },
                  ),
                  Text('${tempRadius.toStringAsFixed(1)} km'),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.apply),
              onPressed: () {
                setState(() {
                  _radius = tempRadius;
                });
                _fetchServices(radius: _radius);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      // Services Tab - Modified to include Categories and Service List
      SearcherServicesTab(),
      SearcherOrdersTab(),
      const ProfileInterface(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, size: 24),
            SizedBox(width: 8),
            Text(
              'Sahel Alik',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
            tooltip: AppLocalizations.of(context)!.filterByRadius,
          ),
          const LanguageSwitcher(),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.services,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: AppLocalizations.of(context)!.orders,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        child: const Icon(Icons.chat),
        tooltip: 'Chat Assistant',
        elevation: 4,
      ),
    );
  }
}
