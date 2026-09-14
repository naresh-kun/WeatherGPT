/// WeatherGPT — Location Search Screen
/// Allows users to search for a city via the backend.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/models/location.dart';
import 'package:weathergpt_app/providers/location_provider.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    required this.locationProvider,
  });

  final LocationProvider locationProvider;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  LocationProvider get _loc => widget.locationProvider;

  @override
  void initState() {
    super.initState();
    _loc.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _loc.removeListener(_onProviderChange);
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loc.search(query);
    });
  }

  void _onResultTap(LocationSearchResult result) {
    _loc.selectLocation(result);
    Navigator.of(context).pop(true); // signal that a location was selected
  }

  Future<void> _useCurrentLocation() async {
    await _loc.useCurrentLocation();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.changeLocation ?? 'Search Location'),
        actions: [
          IconButton(
            icon: _loc.gpsLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: l10n?.useCurrentLocation ?? 'Use current location',
            onPressed: _loc.gpsLoading ? null : _useCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search city (e.g. Chennai, Mumbai)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _loc.search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_loc.isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          Expanded(
            child: _loc.searchResults.isEmpty
                ? ListView(
                    children: [
                      ListTile(
                        leading: _loc.gpsLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, color: AppColors.primary),
                        title: Text(l10n?.useCurrentLocation ?? 'Use current location'),
                        subtitle: Text(
                          _loc.selectedLocation.displayName.isNotEmpty
                              ? '${l10n?.activeLocation ?? 'Active'}: ${_loc.selectedLocation.displayName}'
                              : 'Fetch current GPS position',
                        ),
                        onTap: _loc.gpsLoading ? null : _useCurrentLocation,
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Center(
                          child: Text(
                            _controller.text.isEmpty
                                ? 'Type a city name to search'
                                : 'No results found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: _loc.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = _loc.searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(r.name),
                        subtitle: Text('${r.region}, ${r.country}'),
                        trailing: Text(
                          '${r.lat.toStringAsFixed(2)}, ${r.lon.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => _onResultTap(r),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
