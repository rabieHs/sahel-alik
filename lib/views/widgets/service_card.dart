import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sahel_alik/models/service.dart';
import 'package:sahel_alik/views/interfaces/provider/service_details_page.dart';
import 'package:sahel_alik/views/interfaces/searcher/service_details_page.dart'; // Import ServiceDetailsPage

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isProvider;
  const ServiceCard(
      {super.key, required this.service, this.isProvider = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Wrap Card with InkWell for tap action
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isProvider
                ? ProviderServiceDetailsPage(service: service)
                : ServiceDetailsPage(
                    service: service), // Navigate to service details page
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                    Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.asset('assets/placeholder-image.png',
                        fit: BoxFit.cover), // Placeholder asset
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withAlpha(153), // 0.6 opacity
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title ?? 'Service Title',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            service.price != null
                                ? AppLocalizations.of(context)!.pricePerHour(service.price!)
                                : 'Price not available',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
