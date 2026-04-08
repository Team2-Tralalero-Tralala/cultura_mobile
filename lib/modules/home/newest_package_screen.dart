import 'package:flutter/material.dart';
import 'package:cultura_mobile/services/api_service.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';

// Model 
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

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://cultura-api-mobile.onrender.com';

    List<String> parseTags(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) {
          if (e is Map && e['tag'] is Map) {
            return e['tag']['name']?.toString() ?? '';
          }
          return e.toString();
        }).where((t) => t.isNotEmpty).toList();
      }
      return [];
    }

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
      bookingStart: parseDate(json['bookingStartDate'] ?? json['booking_start']),
      bookingEnd: parseDate(json['bookingEndDate'] ?? json['booking_end']),
      booked: (json['booked'] ?? json['booked_count'] ?? 0) as int,
      capacity: (json['capacity'] ?? json['max_capacity'] ?? 50) as int,
      tags: parseTags(json['tags']),
      priceTHB: double.tryParse((json['price'] ?? json['price_thb'] ?? 0).toString()) ?? 0,
    );
  }
}

// NewPackagesScreen
class NewPackagesScreen extends StatefulWidget {
  const NewPackagesScreen({super.key});

  @override
  State<NewPackagesScreen> createState() => _NewPackagesScreenState();
}

class _NewPackagesScreenState extends State<NewPackagesScreen> {
  List<PackageModel> _packages = [];
  List<PackageModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchKeyword = '';
  BottomNavType _currentNav = BottomNavType.NEW;

  @override
  void initState() {
    super.initState();
    _loadNewPackages();
  }

  /*
   * คำอธิบาย : โหลดแพ็กเกจจาก API และอัปเดต state
   */
  Future<void> _loadNewPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await getPackages(filter: 'newest');

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
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(onSearchChanged: _onSearchChanged),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'แพ็กเกจมาใหม่',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF93)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _loadNewPackages, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNewPackages,
      color: const Color(0xFF4CAF93),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
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