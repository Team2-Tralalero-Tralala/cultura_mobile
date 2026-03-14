import 'package:flutter/material.dart';
import 'package:cultura_mobile/services/api_service.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';

// ==================== Model ====================

class PackageModel {
  final int id;
  final String title;
  final String location;
  final String imageUrl;
  final DateTime? bookingStart;
  final DateTime? bookingEnd;
  final int booked;
  final int capacity;
  final List<String> tags;
  final double priceTHB;

  PackageModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    this.bookingStart,
    this.bookingEnd,
    this.booked = 0,
    this.capacity = 50,
    this.tags = const [],
    this.priceTHB = 0,
  });

  /*
   * คำอธิบาย : แปลง JSON จาก API ให้เป็น PackageModel
   * Input : json (Map<String, dynamic>) - ข้อมูลจาก API
   * Output : PackageModel
   */
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://cultura-api-mobile.onrender.com';

    // ดึง tags จาก tags[].tag.name
    List<String> parseTags(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((e) {
              if (e is Map && e['tag'] is Map) {
                return e['tag']['name']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((t) => t.isNotEmpty)
            .toList();
      }
      return [];
    }

    // ดึงรูป COVER จาก images[] แล้วเติม baseUrl
    String parseImageUrl(dynamic raw) {
      if (raw == null) return '';
      if (raw is List) {
        final cover = raw.firstWhere(
          (e) => e is Map && e['type'] == 'COVER',
          orElse: () => raw.isNotEmpty ? raw.first : null,
        );
        if (cover != null && cover is Map) {
          final path = cover['filepath']?.toString() ?? '';
          return path.isNotEmpty ? '$baseUrl$path' : '';
        }
      }
      return '';
    }

    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    return PackageModel(
      id: json['id'] ?? json['package_id'] ?? 0,
      title: json['name'] ?? json['title'] ?? json['package_name'] ?? '',
      location: json['address'] ?? json['location'] ?? json['place'] ?? '',
      imageUrl: parseImageUrl(json['images']),
      bookingStart: parseDate(
        json['bookingStartDate'] ?? json['booking_start'],
      ),
      bookingEnd: parseDate(json['bookingEndDate'] ?? json['booking_end']),
      booked: (json['booked'] ?? json['booked_count'] ?? 0) as int,
      capacity: (json['capacity'] ?? json['max_capacity'] ?? 50) as int,
      tags: parseTags(json['tags']),
      priceTHB:
          double.tryParse(
            (json['price'] ?? json['price_thb'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}

// ==================== PackagesScreen ====================

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<PackageModel> _packages = [];
  List<PackageModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchKeyword = '';
  BottomNavType _currentNav = BottomNavType.POPULAR;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  /*
   * คำอธิบาย : โหลดแพ็กเกจจาก API และอัปเดต state
   */
  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await getPackages(filter: 'popular');

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _error = result.message ?? 'โหลดข้อมูลไม่สำเร็จ';
      });
      return;
    }

    try {
      final raw = result.data;
      List<dynamic> list = [];

      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list = raw['data'] ?? raw['packages'] ?? raw['items'] ?? [];
      }

      final packages = list
          .whereType<Map<String, dynamic>>()
          .map((e) => PackageModel.fromJson(e))
          .toList();

      setState(() {
        _packages = packages;
        _filtered = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'ไม่สามารถแปลงข้อมูลได้: $e';
      });
    }
  }

  /*
   * คำอธิบาย : กรองแพ็กเกจตาม keyword ที่พิมพ์ใน search bar
   */
  void _onSearchChanged(String keyword) {
    setState(() {
      _searchKeyword = keyword.trim().toLowerCase();
      if (_searchKeyword.isEmpty) {
        _filtered = _packages;
      } else {
        _filtered = _packages.where((p) {
          return p.title.toLowerCase().contains(_searchKeyword) ||
              p.location.toLowerCase().contains(_searchKeyword) ||
              p.tags.any((t) => t.toLowerCase().contains(_searchKeyword));
        }).toList();
      }
    });
  }

  /*
   * คำอธิบาย : จัดการการเปลี่ยน tab ใน BottomNavigate
   */
  void _onNavChanged(BottomNavType type) {
    setState(() {
      _currentNav = type;
    });
    // TODO: navigate ไปหน้าอื่นตาม type
    // switch (type) {
    //   case BottomNavType.NEW:
    //     Get.to(() => const NewPackagesScreen());
    //     break;
    //   case BottomNavType.HOME:
    //     Get.to(() => const HomeScreen());
    //     break;
    //   case BottomNavType.POPULAR:
    //     break; // อยู่หน้านี้แล้ว
    // }
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
          colors: [Color(0xFF4CAF93), Color(0xFF2E7D5E)],
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
    if (_isLoading) {
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

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPackages,
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

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _searchKeyword.isNotEmpty
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
      onRefresh: _loadPackages,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 168 / 221,
        ),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final p = _filtered[index];
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
              // TODO: Navigate to package detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เปิดแพ็กเกจ: ${p.title}')),
              );
            },
          );
        },
      ),
    );
  }
}
