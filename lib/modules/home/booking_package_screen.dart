import 'package:flutter/material.dart';
import 'package:cultura_mobile/services/api_service.dart';
import 'package:cultura_mobile/widgets/card_package.dart';
import 'package:cultura_mobile/widgets/header.dart';
import 'package:cultura_mobile/widgets/bottom_navigation_bar.dart';

// ==================== Model ====================
class BookingModel {
  final String title;
  final String location;
  final String imageUrl;
  final DateTime? bookingStart;
  final DateTime? bookingEnd;
  final int booked;
  final int capacity;
  final List<String> tags;
  final double priceTHB;

  BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://cultura-api-mobile.onrender.com';

    // ข้อมูลจาก API ประวัติการจอง จะซ้อนอยู่ใน Object "package" อีกที
    final packageData = json['package'] ?? {};

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

    return BookingModel(
      title: packageData['name'] ?? packageData['title'] ?? 'ไม่ระบุชื่อ',
      location: packageData['address'] ?? packageData['location'] ?? '',
      imageUrl: parseImageUrl(packageData['images']),
      bookingStart: parseDate(packageData['bookingStartDate']),
      bookingEnd: parseDate(packageData['bookingEndDate']),
      booked: (packageData['booked'] ?? 0) as int,
      capacity: (packageData['capacity'] ?? 50) as int,
      tags: parseTags(packageData['tags']),
      priceTHB: double.tryParse((packageData['price'] ?? 0).toString()) ?? 0,
    );
  }
}

// ==================== Screen ====================
class BookingPackageScreen extends StatefulWidget {
  const BookingPackageScreen({super.key});

  @override
  State<BookingPackageScreen> createState() => _BookingPackageScreenState();
}

class _BookingPackageScreenState extends State<BookingPackageScreen> {
  List<BookingModel> _bookings = [];
  List<BookingModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchKeyword = '';

  // หมายเหตุ: ต้องมี BottomNavType.BOOKING ในไฟล์ bottom_navigation_bar.dart ตามที่แก้ไปก่อนหน้านี้
  BottomNavType _currentNav = BottomNavType.BOOKING;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  /*
   * คำอธิบาย : โหลดประวัติการจองจาก API และอัปเดต state
   */
  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await getBookingHistory();

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
        list = raw['data'] ?? [];
      }

      final bookings = list
          .whereType<Map<String, dynamic>>()
          .map((e) => BookingModel.fromJson(e))
          .toList();

      setState(() {
        _bookings = bookings;
        _filtered = bookings;
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
   * คำอธิบาย : กรองรายการจองตาม keyword ที่พิมพ์ใน search bar
   */
  void _onSearchChanged(String keyword) {
    setState(() {
      _searchKeyword = keyword.trim().toLowerCase();
      if (_searchKeyword.isEmpty) {
        _filtered = _bookings;
      } else {
        _filtered = _bookings.where((b) {
          return b.title.toLowerCase().contains(_searchKeyword) ||
              b.location.toLowerCase().contains(_searchKeyword) ||
              b.tags.any((t) => t.toLowerCase().contains(_searchKeyword));
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
    // TODO: navigate ไปหน้าอื่นตาม type แบบเดียวกับหน้าเพื่อน
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
          colors: [
            Color(0xFF4CAF93),
            Color(0xFF2E7D5E),
          ], // ใช้สี Gradient เดียวกับเพื่อน
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
                  'การจองทั้งหมด',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // ปรับสีตัวอักษรให้ตัดกับพื้นหลัง Gradient เข้ม
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors
                        .amber
                        .shade700, // เปลี่ยนป้ายเป็นสีอำพันให้เข้ากับเรื่องการจอง
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'History',
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF93)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _loadBookings, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Text('ไม่พบประวัติการจอง', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFF4CAF93),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75, // อัตราส่วนการ์ดเท่ากับโค้ดเพื่อน
        ),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final b = _filtered[index];
          // ดึง PackageCard มาใช้ได้ตรงๆ เลย
          return PackageCard(
            image: b.imageUrl,
            title: b.title,
            location: b.location,
            bookingStart: b.bookingStart,
            bookingEnd: b.bookingEnd,
            booked: b.booked,
            capacity: b.capacity,
            tags: b.tags,
            priceTHB: b.priceTHB,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('รายละเอียดการจอง: ${b.title}')),
              );
            },
          );
        },
      ),
    );
  }
}
