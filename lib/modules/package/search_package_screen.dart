import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';
import 'package_controller.dart';
import 'package_model.dart';

class SearchPackageScreen extends StatefulWidget {
  const SearchPackageScreen({super.key});

  @override
  State<SearchPackageScreen> createState() => _SearchPackageScreenState();
}

class _SearchPackageScreenState extends State<SearchPackageScreen> {
  final PackageController controller = Get.put(PackageController());

  String _searchKeyword = '';
  BottomNavType _currentNav = BottomNavType.HOME;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('keyword')) {
      _searchKeyword = args['keyword'] ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchKeyword.isNotEmpty) {
        controller.searchPackagesList(_searchKeyword);
      } else {
        // clear search explicitly if empty
        controller.searchResults.clear();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _searchKeyword = keyword.trim();
      });
      if (_searchKeyword.isNotEmpty) {
        controller.searchPackagesList(_searchKeyword);
      } else {
        controller.searchResults.clear();
      }
    });
  }

  void _onSearchSubmitted(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (!mounted) return;
    setState(() {
      _searchKeyword = keyword.trim();
    });
    if (_searchKeyword.isNotEmpty) {
      controller.searchPackagesList(_searchKeyword);
    } else {
      controller.searchResults.clear();
    }
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
          HeaderWidget(
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: _onSearchSubmitted,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ผลลัพธ์การค้นหา “ $_searchKeyword ”',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final isLoading = controller.isSearchLoading.value;
      final error = controller.searchErrorMessage.value;
      final List<PackageModel> items = controller.searchResults;

      if (isLoading) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4CAF93)),
              SizedBox(height: 12),
              Text(
                'กำลังค้นหาแพ็กเกจ...',
                style: TextStyle(color: Colors.grey),
              ),
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
                  if (_searchKeyword.isNotEmpty) {
                    controller.searchPackagesList(_searchKeyword);
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
                _searchKeyword.isNotEmpty
                    ? 'ไม่พบแพ็กเกจที่ค้นหา "$_searchKeyword"'
                    : 'กรุณาใส่คำค้นหา',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF4CAF93),
        onRefresh: () async {
          if (_searchKeyword.isNotEmpty) {
            await controller.searchPackagesList(_searchKeyword);
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
