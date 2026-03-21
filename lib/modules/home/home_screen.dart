import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cultura_mobile/services/api_service.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/carousel.dart';
import 'package:cultura_mobile/widgets/category.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/tag.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BottomNavType _currentPage = BottomNavType.HOME;
  bool _isLoading = true;
  List<dynamic> _newestPackages = [];
  List<dynamic> _popularPackages = [];
  List<String> _recommendedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    final response = await getHome();
    if (response.success && response.data != null) {
      if (mounted) {
        setState(() {
          if (response.data is Map && response.data['data'] is Map) {
            _newestPackages = response.data['data']['newPackages'] ?? [];
            _popularPackages = response.data['data']['popularPackages'] ?? [];
            final tagData = response.data['data']['tag'];
            if (tagData is List) {
              _recommendedTags = tagData
                  .map((e) => e['name'].toString())
                  .toList();
            }
          } else if (response.data is Map) {
            _newestPackages = response.data['newPackages'] ?? [];
            _popularPackages = response.data['popularPackages'] ?? [];
            final tagData = response.data['tag'];
            if (tagData is List) {
              _recommendedTags = tagData
                  .map((e) => e['name'].toString())
                  .toList();
            }
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6BCEAE), Color(0xFF429170)],
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    HeaderWidget(
                      onSearchSubmitted: (keyword) {
                        if (keyword.isNotEmpty) {
                          Get.toNamed(
                            '/searchPackages',
                            arguments: {'keyword': keyword},
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const CategoryWidget(),
                  ],
                ),
              ),
              CustomCarousel(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'แพ็กเกจมาใหม่',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _newestPackages.length,
                        itemBuilder: (context, index) {
                          final pkg = _newestPackages[index];

                          // Map image from images array (prefer COVER type)
                          String? imageUrl;
                          if (pkg['images'] is List &&
                              (pkg['images'] as List).isNotEmpty) {
                            final images = pkg['images'] as List;
                            final coverImage = images.firstWhere(
                              (img) => img['type'] == 'COVER',
                              orElse: () => images.first,
                            );
                            String rawPath = coverImage['filepath'] ?? '';
                            if (rawPath.isNotEmpty) {
                              imageUrl =
                                  'https://cultura-api-mobile.onrender.com$rawPath';
                            }
                          }
                          final image =
                              imageUrl ?? 'https://via.placeholder.com/150';

                          final title = pkg['name'] ?? 'ไม่ระบุชื่อแพ็กเกจ';
                          final location = pkg['address'] ?? 'ไม่ระบุสถานที่';

                          final priceRaw = pkg['price'];
                          final price = priceRaw is num
                              ? priceRaw.toDouble()
                              : 0.0;

                          // We don't have capacity and booked in this response, so we provide default values
                          final capacity = pkg['capacity'] is int
                              ? pkg['capacity']
                              : 50;
                          final booked = pkg['booked'] is int
                              ? pkg['booked']
                              : 0;

                          final String? startRaw = pkg['bookingStartDate'];
                          final String? endRaw = pkg['bookingEndDate'];
                          final DateTime? start = startRaw != null
                              ? DateTime.tryParse(startRaw)
                              : null;
                          final DateTime? end = endRaw != null
                              ? DateTime.tryParse(endRaw)
                              : null;

                          final List<String> tags = [];
                          if (pkg['tags'] is List) {
                            for (var t in pkg['tags']) {
                              if (t is Map &&
                                  t['tag'] is Map &&
                                  t['tag']['name'] != null) {
                                tags.add(t['tag']['name'].toString());
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: PackageCard(
                              image: image,
                              title: title,
                              location: location,
                              priceTHB: price,
                              capacity: capacity,
                              booked: booked,
                              bookingStart: start,
                              bookingEnd: end,
                              tags: tags,
                              onClick: () {
                                final pId = pkg['id'] ?? pkg['package_id'];
                                if (pId != null) {
                                  Get.toNamed('/packageDetail', arguments: pId);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/popularPackage');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ดูเพิ่มเติม',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'แพ็กเกจยอดนิยม',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _popularPackages.length,
                        itemBuilder: (context, index) {
                          final pkg = _popularPackages[index];

                          // Map image from images array (prefer COVER type)
                          String? imageUrl;
                          if (pkg['images'] is List &&
                              (pkg['images'] as List).isNotEmpty) {
                            final images = pkg['images'] as List;
                            final coverImage = images.firstWhere(
                              (img) => img['type'] == 'COVER',
                              orElse: () => images.first,
                            );
                            String rawPath = coverImage['filepath'] ?? '';
                            if (rawPath.isNotEmpty) {
                              imageUrl =
                                  'https://cultura-api-mobile.onrender.com$rawPath';
                            }
                          }
                          final image =
                              imageUrl ?? 'https://via.placeholder.com/150';

                          final title = pkg['name'] ?? 'ไม่ระบุชื่อแพ็กเกจ';
                          final location = pkg['address'] ?? 'ไม่ระบุสถานที่';

                          final priceRaw = pkg['price'];
                          final price = priceRaw is num
                              ? priceRaw.toDouble()
                              : 0.0;

                          // We don't have capacity and booked in this response, so we provide default values
                          final capacity = pkg['capacity'] is int
                              ? pkg['capacity']
                              : 50;
                          final booked = pkg['booked'] is int
                              ? pkg['booked']
                              : 0;

                          final String? startRaw = pkg['bookingStartDate'];
                          final String? endRaw = pkg['bookingEndDate'];
                          final DateTime? start = startRaw != null
                              ? DateTime.tryParse(startRaw)
                              : null;
                          final DateTime? end = endRaw != null
                              ? DateTime.tryParse(endRaw)
                              : null;

                          final List<String> tags = [];
                          if (pkg['tags'] is List) {
                            for (var t in pkg['tags']) {
                              if (t is Map &&
                                  t['tag'] is Map &&
                                  t['tag']['name'] != null) {
                                tags.add(t['tag']['name'].toString());
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: PackageCard(
                              image: image,
                              title: title,
                              location: location,
                              priceTHB: price,
                              capacity: capacity,
                              booked: booked,
                              bookingStart: start,
                              bookingEnd: end,
                              tags: tags,
                              onClick: () {
                                final pId = pkg['id'] ?? pkg['package_id'];
                                if (pId != null) {
                                  Get.toNamed('/packageDetail', arguments: pId);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to popular packages
                      Get.toNamed('/packages?filter=popular');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ดูเพิ่มเติม',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'กิจกรรมที่แนะนำ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (!_isLoading && _recommendedTags.isNotEmpty)
                TagsSection(
                  props: TagsSectionProps(
                    tags: _recommendedTags,
                    onTagClick: (tag) {
                      // Handle tag click
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigate(
        current: _currentPage,
        onChanged: (type) {
          setState(() {
            _currentPage = type;
          });
        },
      ),
    );
  }
}
