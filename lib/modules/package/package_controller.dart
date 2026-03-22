import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package_model.dart';

class PackageController extends GetxController {
  // ==================== Detail State ====================
  var isDetailLoading = false.obs;
  var packageData = Rxn<Map<String, dynamic>>();
  var detailErrorMessage = Rxn<String>();

  // ==================== List States ====================
  var newPackages = <PackageModel>[].obs;
  var isNewLoading = false.obs;
  var newErrorMessage = Rxn<String>();

  var popularPackages = <PackageModel>[].obs;
  var isPopularLoading = false.obs;
  var popularErrorMessage = Rxn<String>();

  var searchResults = <PackageModel>[].obs;
  var isSearchLoading = false.obs;
  var searchErrorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is int) {
        fetchPackage(args);
      } else if (args is Map && args['packageId'] != null) {
        fetchPackage(args['packageId'] as int);
      }
    }
  }

  // ==================== Detail Methods ====================

  Future<void> fetchPackage(int packageId) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = null;
    try {
      final response = await getPackageById(packageId);
      if (response.success) {
        final rawData = response.data;
        if (rawData is Map) {
          if (rawData.containsKey('data') && rawData['data'] is Map) {
            packageData.value = rawData['data'] as Map<String, dynamic>;
          } else {
            packageData.value = rawData as Map<String, dynamic>;
          }
        } else {
          packageData.value = null;
        }
      } else {
        detailErrorMessage.value = response.message ?? 'โหลดข้อมูลไม่สำเร็จ';
      }
    } catch (e) {
      detailErrorMessage.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  String formatPrice(num price) {
    return NumberFormat('#,##0').format(price);
  }

  String formatThaiDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final year = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $year';
  }

  void bookPackage() {
    Get.snackbar(
      'กำลังจอง',
      'อยู่ระหว่างการพัฒนาระบบจอง',
      backgroundColor: Colors.yellow,
      colorText: Colors.black,
    );
  }

  // ==================== List Methods ====================

  List<PackageModel> _parsePacakgesFromResponse(dynamic raw) {
    List<dynamic> list = [];
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      list = raw['data'] ?? raw['packages'] ?? raw['items'] ?? [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PackageModel.fromJson(e))
        .toList();
  }

  Future<void> fetchNewPackages() async {
    isNewLoading.value = true;
    newErrorMessage.value = null;
    try {
      final result = await getPackages(filter: 'newest');
      if (result.success) {
        newPackages.value = _parsePacakgesFromResponse(result.data);
      } else {
        newErrorMessage.value = result.message ?? 'โหลดข้อมูลไม่สำเร็จ';
      }
    } catch (e) {
      newErrorMessage.value = 'ไม่สามารถแปลงข้อมูลได้: $e';
    } finally {
      isNewLoading.value = false;
    }
  }

  Future<void> fetchPopularPackages() async {
    isPopularLoading.value = true;
    popularErrorMessage.value = null;
    try {
      final result = await getPackages(filter: 'popular');
      if (result.success) {
        popularPackages.value = _parsePacakgesFromResponse(result.data);
      } else {
        popularErrorMessage.value = result.message ?? 'โหลดข้อมูลไม่สำเร็จ';
      }
    } catch (e) {
      popularErrorMessage.value = 'ไม่สามารถแปลงข้อมูลได้: $e';
    } finally {
      isPopularLoading.value = false;
    }
  }

  Future<void> searchPackagesList(String keyword) async {
    isSearchLoading.value = true;
    searchErrorMessage.value = null;
    try {
      final result = await searchPackages(keyword);
      if (result.success) {
        searchResults.value = _parsePacakgesFromResponse(result.data);
      } else {
        searchErrorMessage.value = result.message ?? 'ค้นหาไม่สำเร็จ';
      }
    } catch (e) {
      searchErrorMessage.value = 'ไม่สามารถแปลงข้อมูลการค้นหาได้: $e';
    } finally {
      isSearchLoading.value = false;
    }
  }
}
