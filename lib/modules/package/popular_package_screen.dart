import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';
import 'package_controller.dart';
import 'package_model.dart';

class PopularPackageScreen extends StatefulWidget {
  const PopularPackageScreen({super.key});

  @override
  State<PopularPackageScreen> createState() => _PopularPackageScreenState();
}

class _PopularPackageScreenState extends State<PopularPackageScreen> {
  final PackageController controller = Get.put(PackageController());

  String _searchKeyword = '';
  BottomNavType _currentNav = BottomNavType.POPULAR;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPopularPackages();
    });
  }

  Future<void> _performSearch(String keyword) async {
    final query = keyword.trim().toLowerCase();
    setState(() {
      _searchKeyword = query;
    });

    if (query.isNotEmpty) {
      await controller.searchPackagesList(query);
    }
  }

  void _onSearchChanged(String keyword) {
    _performSearch(keyword);
  }

  void _onNavChanged(BottomNavType type) {
    setState(() {
      _currentNav = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigate(
        current: _currentNav,
        onChanged: _onNavChanged,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6BCEAE), Color(0xFF429170)],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(onSearchChanged: _onSearchChanged),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'แพ็กเกจยอดนิยม',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final bool isSearching = _searchKeyword.isNotEmpty;
      final bool isLoading = isSearching
          ? controller.isSearchLoading.value
          : controller.isPopularLoading.value;
      final String? error = isSearching
          ? controller.searchErrorMessage.value
          : controller.popularErrorMessage.value;
      final List<PackageModel> items = isSearching
          ? controller.searchResults
          : controller.popularPackages;

      if (isLoading) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4CAF93)),
              SizedBox(height: 12),
              Text('กำลังโหลดแพ็กเกจ...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      if (error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (isSearching) {
                    controller.searchPackagesList(_searchKeyword);
                  } else {
                    controller.fetchPopularPackages();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF93),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                isSearching
                    ? 'ไม่พบแพ็กเกจที่ค้นหา "$_searchKeyword"'
                    : 'ยังไม่มีแพ็กเกจในขณะนี้',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF4CAF93),
        onRefresh: () async {
          if (isSearching) {
            await controller.searchPackagesList(_searchKeyword);
          } else {
            await controller.fetchPopularPackages();
          }
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 168 / 221,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index];
            return PackageCard(
              image: p.imageUrl,
              title: p.title,
              location: p.location,
              bookingStart: p.bookingStart,
              bookingEnd: p.bookingEnd,
              booked: p.booked,
              capacity: p.capacity,
              tags: p.tags,
              priceTHB: p.priceTHB,
              onClick: () {
                if (p.id > 0) {
                  Get.toNamed('/packageDetail', arguments: p.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('รหัสแพ็กเกจไม่ถูกต้อง')),
                  );
                }
              },
            );
          },
        ),
      );
    });
  }
}
