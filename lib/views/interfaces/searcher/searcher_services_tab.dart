import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/service_card.dart';
import '../../../services/service_service.dart';
import '../../../models/service.dart';
import '../../../models/user.dart';
import '../../../utils/location_utils.dart';

class SearcherServicesTab extends StatefulWidget {
  const SearcherServicesTab({super.key});

  @override
  State<SearcherServicesTab> createState() => _SearcherServicesTabState();
}

class _SearcherServicesTabState extends State<SearcherServicesTab> {
  String? _selectedCategory;
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  List<Map<String, dynamic>> _servicesWithProviders = [];
  List<Map<String, dynamic>> _filteredServicesWithProviders = [];
  bool _isLoading = true;
  double _radius = 5.0; // Default radius
  final TextEditingController _searchController = TextEditingController();
  bool _useEnhancedSearch = true; // Flag to use enhanced search

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
    // Add a small delay to ensure the widget is fully mounted before fetching
    Future.delayed(Duration.zero, () {
      if (_useEnhancedSearch) {
        _fetchServicesWithProviders();
      } else {
        _fetchServices();
      }
    });
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
      try {
        final servicesStream = serviceService.getNearestServices(
          latitude: position.latitude,
          longitude: position.longitude,
          radius: searchRadius,
        );
        final services = await servicesStream.first;
        if (mounted) {
          setState(() {
            _services = services;
            _filteredServices = services;
            _isLoading = false;
          });
          // Debug information removed
        }
      } catch (e) {
        // Error logged
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Error fetching nearby services: $e');
        }
      }
    } else {
      try {
        final allServicesStream = serviceService.getAllServices();
        final services = await allServicesStream.first;
        if (mounted) {
          setState(() {
            _services = services;
            _filteredServices = services;
            _isLoading = false;
          });
          _showSnackBar('Location not available, showing all services.');
        }
      } catch (e) {
        // Error logged
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Error fetching services: $e');
        }
      }
    }
  }

  // Helper method to show snack bar safely
  void _showSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    final context = this.context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration ?? const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _filterServices(String query) {
    if (_useEnhancedSearch) {
      _filterServicesWithProviders(query);
    } else {
      _filterBasicServices(query);
    }
  }

  void _filterBasicServices(String query) {
    String lowerCaseQuery = query.toLowerCase();
    List<ServiceModel> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = _services
          .where((service) =>
              service.title!.toLowerCase().contains(lowerCaseQuery) ||
              service.description!.toLowerCase().contains(lowerCaseQuery) ||
              (service.category?.toLowerCase().contains(lowerCaseQuery) ??
                  false))
          .toList();
    } else {
      filteredList = List.from(_services);
    }
    setState(() {
      _filteredServices = filteredList;
    });
  }

  void _filterServicesWithProviders(String query) {
    String lowerCaseQuery = query.toLowerCase();
    List<Map<String, dynamic>> filteredList = [];

    if (query.isNotEmpty) {
      filteredList = _servicesWithProviders.where((item) {
        ServiceModel service = item['service'];
        UserModel? provider = item['provider'];

        // Search in service title, description, and category
        bool matchesService =
            (service.title?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
                (service.description?.toLowerCase().contains(lowerCaseQuery) ??
                    false) ||
                (service.category?.toLowerCase().contains(lowerCaseQuery) ??
                    false);

        // Search in provider name if available
        bool matchesProvider = provider != null &&
            (provider.name?.toLowerCase().contains(lowerCaseQuery) ?? false);

        return matchesService || matchesProvider;
      }).toList();
    } else {
      filteredList = List.from(_servicesWithProviders);
    }

    setState(() {
      _filteredServicesWithProviders = filteredList;
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
            builder: (BuildContext context, StateSetter setState) {
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
                      setState(() {
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
                  _radius = tempRadius; // Update radius with temp value
                });
                // Re-fetch services with new radius
                _fetchServices(radius: _radius);
                Navigator.of(context).pop();

                // Show a confirmation message
                _showSnackBar(
                  'Showing services within ${_radius.toStringAsFixed(1)} km',
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Fetch services with provider details for enhanced search
  Future<void> _fetchServicesWithProviders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceService = ServiceService();
      final servicesWithProviders =
          await serviceService.getServicesWithProviderDetails();

      if (mounted) {
        setState(() {
          _servicesWithProviders = servicesWithProviders;
          _filteredServicesWithProviders = servicesWithProviders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error fetching services: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // Filter and Refresh Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter button
                  ElevatedButton.icon(
                    onPressed: () => _showFilterDialog(context),
                    icon: const Icon(Icons.filter_list),
                    label: Text('${_radius.toStringAsFixed(1)} km'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      if (_useEnhancedSearch) {
                        _fetchServicesWithProviders();
                      } else {
                        _fetchServices(radius: _radius);
                      }
                    },
                    tooltip: 'Refresh services',
                  ),
                ],
              ),
            ),
            // Categories Horizontal Listview
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                scrollDirection: Axis.horizontal,
                itemCount: _getLocalizedCategories(context).length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _getLocalizedCategories(context)[index];
                  return FilterChip(
                    avatar: Icon(category['icon'] as IconData),
                    label: Text(category['name'] as String),
                    selected: _selectedCategory == category['value'],
                    onSelected: (bool selected) async {
                      setState(() {
                        _selectedCategory =
                            selected ? category['value'] as String : null;
                        _isLoading = true;
                      });

                      if (selected) {
                        final position = await LocationUtils.getCurrentPosition(
                            context); // Pass context
                        if (position != null) {
                          try {
                            final services = await ServiceService()
                                .getServicesByCategoryAndLocation(
                                  category: category['value'],
                                  latitude: position.latitude,
                                  longitude: position.longitude,
                                  radius:
                                      _radius, // Use the current radius setting
                                )
                                .first;
                            if (mounted) {
                              setState(() {
                                _filteredServices = services;
                                _isLoading = false;
                              });
                              // Show a confirmation message
                              final message =
                                  'Showing ${category['name']} services within ${_radius.toStringAsFixed(1)} km';
                              _showSnackBar(message,
                                  duration: const Duration(seconds: 2));
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                              _showSnackBar('Error fetching services: $e');
                            }
                          }
                        } else {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            _showSnackBar('Location not available.');
                          }
                        }
                      } else {
                        _fetchServices();
                      }
                    },
                  );
                },
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.searchServices,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged:
                    _filterServices, // Call _filterServices on text change
              ),
            ),
            // Filtered Services List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Loading indicator
                  : _useEnhancedSearch
                      ? ListView.builder(
                          itemCount: _filteredServicesWithProviders.length,
                          itemBuilder: (context, index) {
                            final item = _filteredServicesWithProviders[index];
                            final service = item['service'] as ServiceModel;
                            final provider = item['provider'] as UserModel?;
                            return ServiceCard(
                              service: service,
                              providerName: provider?.name,
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: _filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = _filteredServices[index];
                            return ServiceCard(service: service);
                          },
                        ),
            ),
          ],
        ),
      ],
    );
  }
}
