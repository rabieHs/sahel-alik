import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sahel_alik/models/service.dart';
import 'package:sahel_alik/views/interfaces/provider/service_details_page.dart';
import 'package:sahel_alik/views/interfaces/searcher/service_details_page.dart'; // Import ServiceDetailsPage

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isProvider;
  final String? providerName;
  const ServiceCard(
      {super.key,
      required this.service,
      this.isProvider = false,
      this.providerName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isProvider
                ? ProviderServiceDetailsPage(service: service)
                : ServiceDetailsPage(service: service),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 opacity
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  // Service Image
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: service.imageUrl != null &&
                            service.imageUrl!.isNotEmpty
                        ? Image.network(
                            service.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(26), // 0.1 opacity
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(26), // 0.1 opacity
                            child: Center(
                              child: Icon(
                                Icons.home_repair_service_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 40,
                              ),
                            ),
                          ),
                  ),

                  // Category Badge
                  if (service.category != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.category!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Rating Badge
                  if (service.rating != null && service.rating! > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              service.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      service.title ?? 'Service Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Provider Name
                    if (providerName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(153), // 0.6 opacity
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              providerName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153), // 0.6 opacity
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Price and Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          service.price != null
                              ? AppLocalizations.of(context)!
                                  .pricePerHour(service.price!)
                              : 'Price not available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        // View Details Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(26), // 0.1 opacity
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.viewDetails,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
