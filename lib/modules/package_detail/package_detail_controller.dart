import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart' as api;

class PackageDetailController extends GetxController {
  late final int packageId;
  
  final isLoading = true.obs;
  final packageData = Rx<Map<String, dynamic>?>(null);
  final errorMessage = Rx<String?>(null);

  // ตัวแปรสำหรับจัดการจำนวนคน
  final passengerCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // ดึง packageId จาก Get.arguments หรือ default เป็น 1
    packageId = Get.arguments ?? 1;
    
    fetchPackageDetail();
  }

  Future<void> fetchPackageDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final result = await api.getPackageById(packageId);
      
      if (result.success) {
        final responseData = result.data;
        if (responseData is Map && responseData['data'] != null) {
          packageData.value = responseData['data'];
        } else {
          errorMessage.value = 'รูปแบบข้อมูลไม่ถูกต้อง';
        }
      } else {
        errorMessage.value = result.message ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล';
      }
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชันเพิ่มจำนวนคน
  void incrementCount() {
    passengerCount.value++;
  }

  // ฟังก์ชันลดจำนวนคน
  void decrementCount() {
    if (passengerCount.value > 1) {
      passengerCount.value--;
    }
  }

  // คำนวณราคาสุทธิ
  double get totalPrice {
    final price = packageData.value?['price'] ?? 0;
    return (price is int ? price.toDouble() : price as double) * passengerCount.value;
  }

  void bookPackage() {
    Get.snackbar(
      'สำเร็จ',
      'กำลังดำเนินการจองแพ็คเกจสำหรับ ${passengerCount.value} ท่าน',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF00C853).withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final yearBE = date.year + 543;
    return '${date.day} ${months[date.month]} $yearBE';
  }

  // ฟังก์ชัน format แบบเต็มสำหรับแถบสีเขียว
  String formatFullThaiDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final yearBE = date.year + 543;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]} $yearBE เวลา $hour:$minute';
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match match) => ',',
    );
  }
}