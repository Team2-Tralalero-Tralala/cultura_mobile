import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart' as api;
import '../home/home_screen.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final storage = const FlutterSecureStorage();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด',
        'กรุณากรอกข้อมูลให้ครบถ้วน',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await api.login(username, password);

      if (result.success) {
        Get.snackbar(
          'สำเร็จ',
          'เข้าสู่ระบบสำเร็จ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          margin: const EdgeInsets.all(16),
        );

        final data = result.data;
        if (data != null) {
          String? token;
          if (data is Map &&
              data['data'] is Map &&
              data['data']['token'] != null) {
            token = data['data']['token'];
          } else if (data is Map && data['token'] != null) {
            token = data['token'];
          }

          if (token != null) {
            await storage.write(key: 'auth_token', value: token);
          }
        }

        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          'ข้อผิดพลาด',
          result.message ?? 'เกิดข้อผิดพลาด',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
