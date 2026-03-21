import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class PackageDetailController extends GetxController {
  var isLoading = false.obs;
  var packageData = Rxn<Map<String, dynamic>>();
  var errorMessage = Rxn<String>();

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

  Future<void> fetchPackage(int packageId) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await getPackageById(packageId);
      if (response.success) {
        final rawData = response.data;
        if (rawData is Map) {
          // หาก API มี wrapper 'data' ซ้อนอยู่ด้านใน ก็ให้ดึงข้างในมาใช้งาน
          if (rawData.containsKey('data') && rawData['data'] is Map) {
            packageData.value = rawData['data'] as Map<String, dynamic>;
          } else {
            // ถ้าเป็น object package เลย
            packageData.value = rawData as Map<String, dynamic>;
          }
        } else {
          packageData.value = null;
        }
      } else {
        errorMessage.value = response.message ?? 'โหลดข้อมูลไม่สำเร็จ';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
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
}
